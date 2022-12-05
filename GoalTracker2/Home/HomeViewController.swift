//
//  HomeViewController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 12/09/2022.
//

import UIKit
import RxSwift
import RxCocoa
import Lottie

/*
 Home
 - progress board analysis
 - message bar more function -> + Memo
 
 Additional
 - plusButtonTapped 쪼개기
 
 flatmap, flatmap latest concat 등 rx 모르는것 다 끝내고 가기
 
 Calendar
 - MemoEdit
 - day-Fix
 */


class HomeViewController: UIViewController {
    //MARK: - UI Components
    let goalCircularCollectionView = CircularCollectionView()
    
    let plusRotatingButton: NeumorphicButton = {
        let button = NeumorphicButton(color: .crayon, type: .large)
        button.layer.cornerRadius = 20
        return button
    }()
    
    lazy var plusRotatingButtonInsideImageView: UIImageView = {
        let imageView = UIImageView(imageName: "plus.neumorphism")
        plusRotatingButton.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(22)
        }
        return imageView
    }()

    fileprivate let messageBar = MessageBar()
    
    private let topTransparentScreenView = UIView()
    
    private let bottomTransparentScreenView = UIView()
    
    private let settingsButton: NeumorphicButton = {
        let button = NeumorphicButton(color: .crayon, type: .medium)
        button.layer.cornerRadius = 18
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(named: "gear.neumorphism")
        button.configuration = configuration
        return button
    }()
    
    private let bottomDateCalendarButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(named: "calendar.neumorphism")
        configuration.imagePlacement = .leading
        configuration.titleAlignment = .trailing
        configuration.imagePadding = 6
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        let button = UIButton()
        button.configuration = configuration
        button.backgroundColor = .crayon.withAlphaComponent(0.6)
        button.layer.cornerRadius = 10
        return button
    }()
    
    let pageIndicator = DotPageIndicator(pageSize: K.singleRowHeight)
    
    let checkButton: UIButton = {
        let button = UIButton()
        button.tintColor = .clear
        button.configuration = UIButton.Configuration.borderless()
        button.configurationUpdateHandler = { button in
            switch button.state {
            case [.normal]:
                button.configuration?.image = UIImage(named: "check.neumorphism")
            case .selected:
                button.configuration?.image = UIImage(named: "thumbs.up.neumorphism")
            case .disabled:
                button.configuration?.image = UIImage(named: "check.neumorphism.disabled")
            default:
                break
            }
        }
        return button
    }()
    
    let scrollBackButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(named: "back.neumorphism")
        let button = UIButton()
        button.configuration = configuration
        button.alpha = 0
        return button
    }()
    
    let topScreenView: UIView = {
        let view = UIView()
        view.backgroundColor = .crayon
        view.alpha = 0
        return view
    }()
    
    let bottomScreenView: UIView = {
        let view = UIView()
        view.backgroundColor = .crayon
        view.alpha = 0
        return view
    }()
    
    private let lottieContainingBlurView: UIView = {
        let containView = UIView()
        containView.backgroundColor = .crayon.withAlphaComponent(0.7)
        containView.isHidden = true
        return containView
    }()
    
    private let thumbsUpLottieView: AnimationView = {
        let animationView = AnimationView.init(name: "thumbs-up-burst")
        animationView.contentMode = .scaleToFill
        animationView.loopMode = .playOnce
        animationView.animationSpeed = 2
        return animationView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "􀎸 Empty."
        label.textColor = .grayA
        label.font = .sfPro(size: 20, family: .Semibold)
        label.isHidden = true
        return label
    }()
    
    //MARK: - Logics
    let homeViewModel = HomeViewModel()
    
    /// - .isScrolling  :     didScroll
    /// - .stopped      :     didEndDecelerating, didEndDragging
    private let circularCvScrollStautsRelay = BehaviorRelay<ScrollInfo>(value: (status: .stopped, y: 0))
    
    fileprivate let scrollStoppedAtRelay = BehaviorRelay<CGFloat>(value: 0)
    
    private let scrollStartedAtRelay = BehaviorRelay<CGFloat>(value: 0)
    
    private let disposeBag = DisposeBag()
    
    typealias ScrollInfo = (status: ScrollStatus, y: CGFloat)
    
    enum ScrollStatus { case  isScorlling, stopped }
    
    private var initialSettingDone = false
    
    var horizontalDidStartScrollBuzzed = false
    
    // Calendar data preperation
    var calendarModel: CalendarModel?
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        configure()
        layoutComponents()
        addButtonTargets()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindings()
        
        prepareCalendarViewModelData()
        
//        pageIndicator.currentIndex = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        plusIconImageRotate180Degree()
        
        if initialSettingDone == false {
            addGradient()
            
            initialSettingDone = true
        }
    }

//MARK: -  Button Actions
    // selector functions
    @objc private func plusButtonTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let plusMenuViewController = PlusMenuViewController()
        plusMenuViewController.modalPresentationStyle = .overFullScreen
        plusMenuViewController.presentCalendarViewCompletion = { [weak self] in
            self?.calenderButtonsTapped()
        }
        
        let row = Int(goalCircularCollectionView.contentOffset.y/K.singleRowHeight)
        let goals = self.homeViewModel.goalViewModelsRelay.value.map { $0.goal }
        
        if goals.count != 0 {
            let goal = goals[row]
            plusMenuViewController.selectedGoalIdentifier = goal.identifier
            plusMenuViewController.selectedGoalTitle = goal.title
        }
        
        let newGoalSaved = plusMenuViewController.newGoalSavedSubject
        
        newGoalSaved
            .bind(to: homeViewModel.rx.relayAcceptNewGoal)
            .disposed(by: plusMenuViewController.disposeBag)
        
        newGoalSaved
            .subscribe(onNext: { [weak self] goal in
                guard let self = self else { return }
                self.messageBar.setNewGoalPlaceHolderMessage()
                
                DispatchQueue.global(qos: .userInteractive).async {
                    self.calendarModel?.addGoalByMonth(goal: goal)
                }
            })
            .disposed(by: plusMenuViewController.disposeBag)
        
        plusMenuViewController.goalDeletedIdentifierSubject
            .bind(to: self.rx.deleteGoalWithIdentifier)
            .disposed(by: plusMenuViewController.disposeBag)
        
        let plusMenuDismissed = plusMenuViewController.viewDismissSubject
        
        Observable
            .merge(
                newGoalSaved.map { _ in }.asObservable(),
                plusMenuDismissed.asObservable()
            )
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    self.plusRotatingButtonInsideImageView.alpha = 1
                }
            })
            .disposed(by: plusMenuViewController.disposeBag)
        
        Observable
            .zip(newGoalSaved.asObservable(), plusMenuDismissed.asObservable())
            .flatMap { _ in return Observable.just(()) }
            .subscribe(self.rx.scrollToAddedGoal)
            .disposed(by: plusMenuViewController.disposeBag)
       
        present(plusMenuViewController, animated: false) {
            DispatchQueue.main.async {
                self.plusRotatingButtonInsideImageView.alpha = 0
            }
        }
    }
    
    @objc private func checkButtonTapped(_ sender: Any) {
        if sender is UITapGestureRecognizer && checkButton.isSelected {
            return
        }
        
        guard !homeViewModel.goalViewModelsRelay.value.isEmpty else {
            return
        }
        
        let page = pageIndicator.currentIndex

        if checkButton.isSelected == false {
            dayCheckLottieAnimation()
            dayCheckToast()
            homeViewModel.dayCheck(at: page)
        } else {
            homeViewModel.dayUncheck(at: page)
        }

        checkButton.isSelected.toggle()
    }
    
    @objc private func lottieBlurViewTapped() {
        DispatchQueue.main.async {
            self.lottieDismissAnimation()
            
            GtToast.hideAllToast()
        }
    }
    
    @objc private func messageBarTapped() {
        let row = Int(goalCircularCollectionView.contentOffset.y/K.singleRowHeight)
        let identifier = homeViewModel.goalIdentifier(at: row)
        
        let noteViewController = UserNoteViewController(goalIdentifier: identifier)
        noteViewController.modalPresentationStyle = .custom
        noteViewController.transitioningDelegate = self
        noteViewController.noteViewModel.userNoteSubject
            .subscribe(onNext: { [weak self] noteArray in
                self?.messageBar.configure(with: noteArray)
            })
            .disposed(by: noteViewController.disposeBag)
        
        present(noteViewController, animated: true)
    }
    
    private func dayCheckLottieAnimation() {
        lottieContainingBlurView.isHidden = false
        
        thumbsUpLottieView.play(completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                self.lottieDismissAnimation()
            }
        })
    }
    
    private func lottieDismissAnimation() {
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.lottieContainingBlurView.alpha = 0
        } completion: { _ in
            self.lottieContainingBlurView.isHidden = true
            self.lottieContainingBlurView.alpha = 1
        }
    }
    
    private func dayCheckToast() {
        GtToast
            .make(
                titleText: "Success +1",
                subTitleText: "Good Job!",
                imageName: "hands.clap",
                position: .Bottom,
                time: 1.3
            )
            .show()
    }
    
    private func plusIconImageRotate180Degree() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            self.plusRotatingButtonInsideImageView.transform = CGAffineTransform(rotationAngle: 180.pi.cgFloat)
        } completion: { _ in
            self.plusRotatingButtonInsideImageView.transform = .identity
        }
    }
    
    @objc private func calenderButtonsTapped() {
        let calendarViewController = CalendarViewController()
        calendarViewController.calendarViewModel.calendarModel = calendarModel
        
        calendarViewController.goalDeletedSubject
            .bind(to: self.rx.deleteGoalWithIdentifier)
            .disposed(by: calendarViewController.disposeBag)
        
        navigationController?.pushViewController(calendarViewController, animated: true)
        
        scrollBackButton.sendActions(for: .touchUpInside)
    }
    
    @objc private func settingsButtonsTapped(_ sender: UIButton) {
        let settingsViewController = SettingsViewController()
        settingsViewController.settingsDelegate = self
        
        navigationController?.pushViewController(settingsViewController, animated: true)
        
        scrollBackButton.sendActions(for: .touchUpInside)
    }
    
    fileprivate func emptySettingsIfNeeded() {
        if homeViewModel.goalViewModelsRelay.value.isEmpty {
            messageBar.setGoalEmptyMessage()
            emptyLabel.isHidden = false
            checkButton.isEnabled = false
        } else {
            emptyLabel.isHidden = true
            checkButton.isEnabled = true
        }
    }
}

extension HomeViewController: SettingsProtocol {
    func dataHasReset() {
        homeViewModel.goalViewModelsRelay.accept([])
        
        messageBar.setGoalEmptyMessage()
    }
}

extension HomeViewController {
    private func prepareCalendarViewModelData() {
        let calendarModel = CalendarModel()
        calendarModel.setData()
        
        self.calendarModel = calendarModel
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {

        return PresentationController(contentHeight: K.screenHeight*0.7, presentedViewController: presented, presenting: presenting)
    }
}

//MARK: - Reative Extension
extension Reactive where Base: HomeViewController {
    var scrolledToXUIChange: Binder<CGFloat> {
        Binder(base) {base, x in
            var alpha: CGFloat = 0
            
            switch x {
            case -30..<50:
                alpha = 0
            case 50...300:
                alpha = (x+50)/300
            case 300...500:
                alpha = 1
            default:
                return
            }
            
            let showing = [base.topScreenView, base.bottomScreenView, base.scrollBackButton]
            let hiding = [base.checkButton, base.plusRotatingButton]
            let hidingFast = [base.pageIndicator]
            
            DispatchQueue.main.async {
                showing.forEach { $0.alpha = alpha}
                hiding.forEach { $0.alpha = 1 - alpha }
                hidingFast.forEach { $0.alpha = 1 - alpha*2.5 }
            }
        }
    }
    
    var viewModelDidChange: Binder<[GoalViewModel]> {
        Binder(base) { base, viewModels in
            base.emptySettingsIfNeeded()
        }
    }
    
    var buzzToScrollOffsetX: Binder<CGFloat> {
        Binder(base) { base, x in
            switch x {
            case 0...50:
                if base.horizontalDidStartScrollBuzzed == false {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    base.horizontalDidStartScrollBuzzed = true
                }
            default:
                base.horizontalDidStartScrollBuzzed = false
            }
        }
    }
    
    var scrollToAddedGoal: Binder<Void> {
        Binder(base) {base, goal in
            let y = base.goalCircularCollectionView.contentSize.height
            let rect = CGRect(x: 0, y: y-K.singleRowHeight, width: 10, height: K.singleRowHeight)
            
            DispatchQueue.main.async {
                base.goalCircularCollectionView.scrollRectToVisible(rect, animated: true)
            }
            base.pageIndicator.currentIndex = base.homeViewModel.goalViewModelsRelay.value.count-1
        }
    }
    
    var deleteGoalWithIdentifier: Binder<String> {
        Binder(base) { base, identifier in
            let numberOfItems = base.homeViewModel.goalViewModelsRelay.value.count
            
            var isFistItemDelete = false
            
            DispatchQueue.main.async {
                let y = base.goalCircularCollectionView.contentOffset.y
                let oneRowBefore = CGPoint(x: 0, y: y-K.singleRowHeight)
                
                if oneRowBefore.y >= 0 {
                    base.goalCircularCollectionView.setContentOffset(oneRowBefore, animated: true)
                    
                } else if oneRowBefore.y < 0 {
                    guard  numberOfItems > 1 else { return }
                    
                    isFistItemDelete = true
                    
                    let oneRowAfter = CGPoint(x: 0, y: y+K.singleRowHeight)
                    base.goalCircularCollectionView.setContentOffset(oneRowAfter, animated: true)
                }
            }
            
            let delay = (numberOfItems==1) ? 0.0 : 0.6
            
            DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
                if isFistItemDelete {
                    base.goalCircularCollectionView.setContentOffset(.zero, animated: false)
                }
                
                let goalVmsFiltered = base.homeViewModel
                    .goalViewModelsRelay.value
                    .filter { $0.goal.identifier != identifier }
                
                base.homeViewModel.goalViewModelsRelay
                    .accept(goalVmsFiltered)
                
                base.calendarModel?.deleteGoal(with: identifier, completion: nil)
            }
        }
    }
    
    var setMessageBar: Binder<CGFloat> {
        Binder(base) {base, offsetY in
            let page = Int(offsetY/K.singleRowHeight)
            let id = base.homeViewModel.goalIdentifier(at: page)
            if let userNotes = UserNoteManager.shared.userNotesDictionary[id] {
                base.messageBar.configure(with: userNotes)
            }
        }
    }
}


//MARK: - Initial UI Setting
extension HomeViewController {
    private func configure() {
        view.backgroundColor = .crayon
        edgesForExtendedLayout = [.top, .bottom]
        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .automatic
        
        setDateCalendarButtonTitle()
    }
    
    private func addButtonTargets() {
        plusRotatingButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsButtonsTapped), for: .touchUpInside)
        bottomDateCalendarButton.addTarget(self, action: #selector(calenderButtonsTapped), for: .touchUpInside)
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        messageBar.addTarget(self, action: #selector(messageBarTapped), for: .touchUpInside)

        let cvtapGestureRecognizer = UITapGestureRecognizer()
        cvtapGestureRecognizer.numberOfTapsRequired = 2
        cvtapGestureRecognizer.addTarget(self, action: #selector(checkButtonTapped))
        goalCircularCollectionView.addGestureRecognizer(cvtapGestureRecognizer)
        
        let lottieTapGestureRecognizer = UITapGestureRecognizer()
        lottieTapGestureRecognizer.addTarget(self, action: #selector(lottieBlurViewTapped))
        lottieContainingBlurView.addGestureRecognizer(lottieTapGestureRecognizer)
    }
    
    private func bindings() {
        bindScrollStatusRelay()
        bindCollectionView()
        scrollStatusBind()
        messageBarBind()
        pageIndicatorBind()
    }

    
    private func setDateCalendarButtonTitle() {
        let attributtedTitle = AttributedString(
            Date().stringFormat(of: .ddMMMEEEE_Comma_Space),
            attributes: AttributeContainer([
                .font: UIFont.outFit(size: 13, family: .Medium),
                .foregroundColor: UIColor.grayC
            ])
        )
        bottomDateCalendarButton.configuration?.attributedTitle = attributtedTitle
    }
    
    private func bindScrollStatusRelay() {
        let scrollStatusChanged = Observable
            .merge(
                goalCircularCollectionView.rx.didScroll.map { ScrollStatus.isScorlling },
                goalCircularCollectionView.rx.didEndDragging.map { _ in ScrollStatus.stopped },
                goalCircularCollectionView.rx.didEndDecelerating.map { ScrollStatus.stopped }
            )
            .distinctUntilChanged()
        
        scrollStatusChanged
            .withLatestFrom(goalCircularCollectionView.rx.contentOffset) {
                ScrollInfo(status: $0, y: $1.y)
            }
            .bind(to: circularCvScrollStautsRelay)
            .disposed(by: disposeBag)
        
        circularCvScrollStautsRelay
            .filter { $0.status == .isScorlling }
            .map { $0.y }
            .bind(to: scrollStartedAtRelay)
            .disposed(by: disposeBag)
        
        circularCvScrollStautsRelay
            .filter { $0.status == .stopped }
            .map { $0.y }
            .bind(to: scrollStoppedAtRelay)
            .disposed(by: disposeBag)
    }
    
    private func bindCollectionView() {
        homeViewModel.goalViewModelsRelay
            .bind(to: goalCircularCollectionView.rx.items) { [weak self] cv, row, viewModel in
                let cell = cv.dequeueReusableCell(withReuseIdentifier: "GoalCircleCell", for: IndexPath(row: row, section: 0))
                
                guard let cell = cell as? GoalCircleCell, let self = self else { return cell }
                
                cell.setupCell(viewModel)
                
                let didScrollToXSignal = cell.didScrollToXSignal
                    .filter { _ in self.circularCvScrollStautsRelay.value.status == .stopped }
                
                didScrollToXSignal
                    .emit(to: self.rx.scrolledToXUIChange)
                    .disposed(by: cell.disposeBag)
                
                didScrollToXSignal
                    .emit(to: self.rx.buzzToScrollOffsetX)
                    .disposed(by: cell.disposeBag)
                
                Observable
                    .merge(
                        self.scrollBackButton.rx.tap.asObservable(),
                        self.scrollStoppedAtRelay.map { _ in }.asObservable()
                    )
                    .bind(to: cell.rx.setContentOffsetZero)
                    .disposed(by: cell.disposeBag)
                return cell
            }
            .disposed(by: disposeBag)
        
        homeViewModel.goalViewModelsRelay
            .bind(to: self.rx.viewModelDidChange)
            .disposed(by: disposeBag)
    }
    
    private func scrollStatusBind() {
        goalCircularCollectionView.rx.didEndDragging
            .subscribe(onNext: { _ in
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            })
            .disposed(by: disposeBag)
        
        scrollStartedAtRelay
            .bind { [weak self] _ in
                DispatchQueue.main.async {
                    self?.scrollBackButton.alpha = 0
                    self?.plusRotatingButton.alpha = 1
                }
            }
            .disposed(by: disposeBag)
        
        scrollStoppedAtRelay // ---- checkButton
            .bind { [weak self] y in
                guard let self = self else { return }
                let page = Int(y/K.singleRowHeight)
                let viewModels = self.homeViewModel.goalViewModelsRelay.value
                
                guard !viewModels.isEmpty else { return }
                self.checkButton.isSelected = viewModels[page].todayChecked
            }
            .disposed(by: disposeBag)
    }

    private func pageIndicatorBind() {
        homeViewModel
            .goalViewModelsRelay
            .flatMap { Observable.just(($0.count, self.goalCircularCollectionView.contentOffset.y)) }
            .bind(to: pageIndicator.rx.numberOfPages)
            .disposed(by: disposeBag)
        
        scrollStoppedAtRelay
            .bind(to: pageIndicator.rx.updateIndicators)
            .disposed(by: disposeBag)
    }
    
    private func messageBarBind() {
        scrollStoppedAtRelay
            .bind(to: self.rx.setMessageBar)
            .disposed(by: disposeBag)
    }
    
    private func layoutComponents() {
        [
            goalCircularCollectionView,     pageIndicator,
            topTransparentScreenView,       bottomTransparentScreenView,
            topScreenView,                  bottomScreenView,
            plusRotatingButton,
            checkButton,                    scrollBackButton,
            settingsButton,                 bottomDateCalendarButton,
            lottieContainingBlurView,       emptyLabel,
            messageBar
        ]
            .forEach(view.addSubview(_:))

        goalCircularCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(K.singleRowHeight)
        }

        topTransparentScreenView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.goalCircularCollectionView.snp.top).offset(100)
        }
        
        bottomTransparentScreenView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(messageBar).offset(-80)
        }
        
        topScreenView.snp.makeConstraints { make in
            make.edges.equalTo(topTransparentScreenView)
        }
        
        bottomScreenView.snp.makeConstraints { make in
            make.edges.equalTo(bottomTransparentScreenView)
        }
        
        plusRotatingButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset((K.hasNotch ? 120 : 86)*K.ratioFactor)
        }

        messageBar.snp.makeConstraints { make in
            make.height.equalTo(60*K.ratioFactor)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset((K.hasNotch ? 30 : 20)*K.ratioFactor)
        }
        
        scrollBackButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.trailing.equalTo(plusRotatingButton)
            make.bottom.equalTo(goalCircularCollectionView).inset(90)
        }
        
        checkButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.trailing.equalTo(plusRotatingButton)
            make.bottom.equalTo(plusRotatingButton.snp.top).offset(-12)
        }

        pageIndicator.snp.makeConstraints { make in
            make.centerY.equalTo(goalCircularCollectionView)
            make.leading.equalTo(goalCircularCollectionView).inset(14)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.size.equalTo(36)
            make.trailing.equalTo(plusRotatingButton)
            make.top.equalToSuperview().inset(70)
        }
        
        bottomDateCalendarButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.bottom.equalTo(messageBar.snp.top).offset(-4)
            make.height.equalTo(28)
        }
        
        lottieContainingBlurView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(lottieContainingBlurView.snp.width)
            make.centerY.equalToSuperview()
        }
        
        lottieContainingBlurView.addSubview(thumbsUpLottieView)
        thumbsUpLottieView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(200)
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func addGradient() {
        let topLayer = CAGradientLayer()
        topLayer.colors = [
            UIColor.crayon.cgColor,
            UIColor.crayon.withAlphaComponent(0).cgColor
        ]
        topLayer.locations = [0.0, 0.7]
        topLayer.frame = topTransparentScreenView.bounds
        topTransparentScreenView.layer.addSublayer(topLayer)
        
        
        let bottomLayer = CAGradientLayer()
        bottomLayer.colors = [
            UIColor.crayon.withAlphaComponent(0).cgColor,
            UIColor.crayon.withAlphaComponent(0.85).cgColor
        ]
        bottomLayer.locations = [0.0, 0.7]
        bottomLayer.frame = bottomTransparentScreenView.bounds
        bottomTransparentScreenView.layer.addSublayer(bottomLayer)
    }
}
