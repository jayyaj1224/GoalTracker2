//
//  CalendarViewController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 22/09/2022.
//

import UIKit
import RxSwift
import RxCocoa


/*
 [CalendarViewController]
  ⎿ MonthsMenuCollectionView
  ⎿ goalTableView
        ⎿ GoalMonthlyCell
            ⎿ GoalMonthlyTileCell
 */

class CalendarViewController: UIViewController {
    // UI Components
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
        tableView.register(GoalMonthlyCell.self, forCellReuseIdentifier: "GoalMonthlyCell")
        
        return tableView
    }()
    
    // Logic
    var isInitialSettingDone = false
    
    private let calendarViewModel = CalendarViewModel()
    
    private let disposeBag = DisposeBag()
    
    private let thisMonth: Int = {
        let thisMonthString = Date().stringFormat(of: .M)
        return Int(thisMonthString) ?? 2
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialUiSetting()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isInitialSettingDone == false {
            monthsMenuCollectionView.selectItem(at: IndexPath(row: thisMonth-1, section: 0), animated: false, scrollPosition: .centeredHorizontally)
            monthsMenuCollectionView.layoutSubviews()
            
            isInitialSettingDone = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
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
        
        present(yearSelectViewController, animated: false)
    }
    
    //MARK: - ui setting
    private func initialUiSetting() {
        view.backgroundColor = .crayon
        
        layout()
        addButtonTargets()
        bind()
        setYear()
    }
    
    private func setYear() {
        let attributtedTitle = AttributedString(
            "\(Date().stringFormat(of: .yyyy)) 􀆈",
            attributes: AttributeContainer([
                .font: UIFont.sfPro(size: 12, family: .Medium),
                .foregroundColor: UIColor.grayC
            ])
        )
        
        yearButton.configuration?.attributedTitle = attributtedTitle
    }
    
    private func bind() {
        calendarViewModel
            .goalsMonthlyRelay
            .bind(to: goalTableView.rx.items) { tv, row, goalMonthly in
                guard let cell = tv.dequeueReusableCell(withIdentifier: "GoalMonthlyCell", for: IndexPath(row: row, section: 0)) as? GoalMonthlyCell else { return UITableViewCell() }
                
                cell.configure(goalMonthly: goalMonthly)
                
                return cell
            }
            .disposed(by: disposeBag)
        
        goalTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        monthsMenuCollectionView.itemSelectedSignal
            .emit { [weak self] indexPath in
                let selectedMonthString = String(format: "%02d", indexPath.row+1)
                self?.calendarViewModel.selectedMonth = selectedMonthString
                self?.calendarViewModel.setGoalCalendar()
            }
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
            make.width.equalTo(70)
        }
    }
    
    private func layout() {
        setCustomNavigationBar()
        
        [monthsMenuCollectionView, goalTableView, topNavigationView]
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
    }
}

extension CalendarViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
