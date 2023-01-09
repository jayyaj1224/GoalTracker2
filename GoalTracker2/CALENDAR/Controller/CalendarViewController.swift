//
//  CalendarViewController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 22/09/2022.
//

import UIKit
import RxSwift
import RxCocoa

class CalendarViewController: UIViewController {
    //MARK: UI Components
    private let topNavigationView = UIView()
    
    private let backButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(named: "back.bracket")
        configuration.imagePadding = 8
        let button = UIButton()
        button.configuration = configuration
        return button
    }()
    
    private let todayButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(named: "calendar.neumorphism")
        configuration.imagePlacement = .leading
        configuration.titleAlignment = .trailing
        configuration.imagePadding = 6
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        
        let attributtedTitle = AttributedString(
            "Today",
            attributes: AttributeContainer([
                .font: UIFont.sfPro(size: 10, family: .Medium),
                .foregroundColor: UIColor.grayC
            ])
        )
        configuration.attributedTitle = attributtedTitle
        let button = UIButton()
        button.configuration = configuration
        return button
    }()
    
    private let yearButton: UIButton = {
        let button = UIButton()
        button.configuration = UIButton.Configuration.plain()
        return button
    }()
    
    private let monthsMenuCollectionView = MonthsMenuCollectionView()
    
    private let goalTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .crayon
        tableView.separatorStyle = .none
        tableView.register(GoalMonthCell.self, forCellReuseIdentifier: "GoalMonthCell")
        return tableView
    }()
    
    private let scrollShadowImageView = UIImageView(imageName: "bar.scrollshadow")
    
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "􀎸 Empty."
        label.textColor = .grayA
        label.font = .sfPro(size: 20, family: .Semibold)
        label.isHidden = true
        return label
    }()
    
    //MARK: Logic
    var isInitialSettingDone = false
    
    let calendarViewModel = CalendarViewModel()
    
    /// - PublishSubject<String> goal identifier
    let goalDeletedSubject = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    private let thisMonth: Int = {
        let thisMonthString = Date().stringFormat(of: .M)
        return Int(thisMonthString) ?? 2
    }()

    //MARK: ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialUiSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        calendarViewModel.displaySelected()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        showCalendarTutorialIfNeeded()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isInitialSettingDone == false {
            monthsMenuCollectionView.selectItem(at: IndexPath(row: thisMonth-1, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            monthsMenuCollectionView.layoutSubviews()
            
            isInitialSettingDone = true
        }
    }
    
    //MARK: Button Actions
    @objc private func todayButtonTapped(_ sender: UIButton) {
        monthsMenuCollectionView.selectItem(at: IndexPath(row: thisMonth-1, section: 0), animated: false, scrollPosition: .centeredHorizontally)
        monthsMenuCollectionView.layoutSubviews()
    }
    
    @objc private func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func yearButtonTapped(_ sender: UIButton) {
        let yearSelectViewController = YearSelectViewController()
        yearSelectViewController.modalPresentationStyle = .overFullScreen
        yearSelectViewController.years = calendarViewModel.yearsRange
        yearSelectViewController.selectedYear = calendarViewModel.selectedYear
        
        yearSelectViewController.yearSelectedSubject
            .bind { [weak self] year in
                self?.yearSelected(year)
            }
            .disposed(by: disposeBag)
        
        present(yearSelectViewController, animated: false)
    }
    
    private func yearSelected(_ selectedYear: String) {
        let thisYear = Date().stringFormat(of: .yyyy)
        
        var indexPath: IndexPath!
        var selectedMonth: Int!
        
        if selectedYear < thisYear {
            selectedMonth = 12
            indexPath = IndexPath(row: selectedMonth-1, section: 0)
            
        } else if selectedYear > thisYear {
            selectedMonth = 1
            indexPath = IndexPath(row: selectedMonth-1, section: 0)
            
        } else if selectedYear == thisYear {
            selectedMonth = thisMonth
            indexPath = IndexPath(row: thisMonth-1, section: 0)
        }
        
        calendarViewModel.selectedMonth = String(format: "%02d", selectedMonth)
        calendarViewModel.selectedYear = selectedYear
        calendarViewModel.displaySelected()
        
        setYear(selectedYear)
        
        monthsMenuCollectionView.selectItem(at: indexPath, animated: false, scrollPosition: .centeredHorizontally)
    }
    
    private func showCalendarTutorialIfNeeded() {
        let shownNumber = UserDefaults.standard.integer(forKey: Keys.toolTip_Calendar)
        
        guard shownNumber < 2, !calendarViewModel.isEmpty else { return }
        
//        UserDefaults.standard.set(shownNumber+1, forKey: Keys.toolTip_Calendar)
        
        TutorialBalloon
            .make(
                message: """
                👉 Swipe right to delete goal
                👆 Tap each ⬜️ Tile to toggle
                """,
                tailPosition: .top,
                time: 4,
                locate: {[weak self] balloon in
                    guard let self = self else { return }
                    
                    self.view.addSubview(balloon)
                    
                    balloon.snp.makeConstraints { make in
                        make.top.equalTo(self.goalTableView).offset(100)
                        make.leading.equalToSuperview().inset(50)
                    }
                }
            )
            .show()
    }
}

extension CalendarViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {

        return PresentationController(contentHeight: K.screenHeight*0.7, presentedViewController: presented, presenting: presenting)
    }
}

//MARK: UITableViewDelegate
extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.swipeDeleteAction(at: indexPath.row)
            
            success(true)
        })
        deleteAction.image =  UIImage(systemName: "trash")?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
        deleteAction.backgroundColor = .crayon
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    private func swipeDeleteAction(at row: Int) {
        let id = calendarViewModel.goalIdentifier(at: row)
        let title = calendarViewModel.goalTitle(at: row)
        
        GTAlertViewController()
            .make(
                title: "Delete Goal",
                titleFont: .sfPro(size: 14, family: .Medium),
                subTitle: "\(title.filter({ !$0.isNewline }))",
                subTitleFont: .sfPro(size: 14, family: .Light),
                text: "** Deleted goals can not be recovered.",
                textFont: .sfPro(size: 12, family: .Light),
                buttonText: "Delete",
                cancelButtonText: "Cancel",
                buttonTextColor: .redA
            )
            .addAction {
                self.goalDeletedSubject.onNext(id)
                
                self.calendarViewModel.deleteGoal(with: id)
            }
            .show()
    }
}

//MARK: RxExtensions
extension Reactive where Base: CalendarViewController {
    var tileCellSelected: Binder<(goalAt: Int, dayAt: Int, goalMonth: GoalMonth)> {
        Binder(base) { base, binder in
            let goalMonth = binder.goalMonth
            let day = goalMonth.days[binder.dayAt]
                
            let dateString = Date
                .inAnyFormat(dateString: day.date)
                .stringFormat(of: .ddMMMEEEE_Comma_Space)
            
            var selected: GoalStatus!
            
            GTAlertViewController()
                .make(
                    title: "\(dateString)",
                    titleFont: .sfPro(size: 14, family: .Medium),
                    subTitle: "\(binder.goalMonth.title)",
                    subTitleFont: .sfPro(size: 14, family: .Light),
                    text: "** Current status: \(day.status)",
                    textFont: .sfPro(size: 12, family: .Light),
                    buttonText: "Fail",
                    cancelButtonText: "Success",
                    buttonTextColor: .redA,
                    backgroundDismiss: true
                )
                .addAction {
                    selected = .fail
                }
                .addCancelAction {
                    selected = .success
                }
                .onCompletion {
                    base.calendarViewModel.fixGoal(
                        goalAt: binder.goalAt,
                        dayAt: binder.dayAt,
                        status: selected,
                        goalMonth: goalMonth
                    )
                }
                .show()
        }
    }
}

//MARK: - Initial UI Setting
extension CalendarViewController{
    private func initialUiSetting() {
        view.backgroundColor = .crayon
        goalTableView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 0)
        
        layout()
        addButtonTargets()
        bind()
        setYear(Date().stringFormat(of: .yyyy))
    }

    private func setYear(_ year: String) {
        let attributtedTitle = AttributedString(
            "  \(year) 􀆈",
            attributes: AttributeContainer([
                .font: UIFont.sfPro(size: 13, family: .Medium),
                .foregroundColor: UIColor.grayC
            ])
        )
        
        yearButton.configuration?.attributedTitle = attributtedTitle
    }
    
    private func bind() {
        calendarViewModel
            .tableViewDatasourceRelay
            .bind(to: goalTableView.rx.items) { tv, row, goalMonth in
                guard let cell = tv.dequeueReusableCell(withIdentifier: "GoalMonthCell", for: IndexPath(row: row, section: 0)) as? GoalMonthCell else { return UITableViewCell() }
                
                cell.configure(with: goalMonth, tableViewRow: row)
                
                cell.dayInGoalMonthSelectedSignal
                    .emit(to: self.rx.tileCellSelected)
                    .disposed(by: cell.reuseBag)
                
                return cell
            }
            .disposed(by: disposeBag)
        
        goalTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        monthsMenuCollectionView.itemSelectedSignal
            .emit { [weak self] indexPath in
                self?.calendarViewModel.selectedMonth = String(format: "%02d", indexPath.row+1)
                self?.calendarViewModel.displaySelected()
            }
            .disposed(by: disposeBag)
        
        calendarViewModel
            .tableViewDatasourceRelay
            .subscribe(onNext: { [weak self] datasource in
                self?.emptyLabel.isHidden = !datasource.isEmpty
            })
            .disposed(by: disposeBag)
    }
    
    private func addButtonTargets()  {
        todayButton.addTarget(self, action: #selector(todayButtonTapped(_:)), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backButtonTapped(_:)), for: .touchUpInside)
        yearButton.addTarget(self, action: #selector(yearButtonTapped(_:)), for: .touchUpInside)
    }
    
    private func setCustomNavigationBar() {
        [backButton, yearButton, todayButton]
            .forEach(topNavigationView.addSubview)
        
        backButton.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
            make.width.equalTo(35)
        }
        
        todayButton.snp.makeConstraints { make in
            make.top.bottom.trailing.equalToSuperview()
        }
        
        yearButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(2)
            make.top.bottom.equalToSuperview()
            make.width.equalTo(80)
        }
    }
    
    private func layout() {
        setCustomNavigationBar()
        
        [monthsMenuCollectionView, goalTableView, topNavigationView, scrollShadowImageView, emptyLabel]
            .forEach(view.addSubview)
        
        topNavigationView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(35)
        }
        
        monthsMenuCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(40)
            make.top.equalTo(topNavigationView.snp.bottom)
        }
        
        goalTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(monthsMenuCollectionView.snp.bottom).offset(10)
        }
        
        scrollShadowImageView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(goalTableView)
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(goalTableView).offset(130)
        }
    }
}
