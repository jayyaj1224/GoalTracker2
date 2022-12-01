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
 - today quick check
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
        let button = NeumorphicButton(color: .crayon, shadowSize: .medium)
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

    private let messageBar = MessageBar()
    
    private let topTransparentScreenView = UIView()
    
    private let bottomTransparentScreenView = UIView()
    
    private let settingsButton: NeumorphicButton = {
        let button = NeumorphicButton(color: .crayon, shadowSize: .medium)
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
                button.configuration?.image =  UIImage(named: "thumbs.up.neumorphism")
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
    
    //MARK: - Logics
    let homeViewModel = HomeViewModel()
    
    private lazy var collectionViewDidScrollSignal = goalCircularCollectionView.rx.didScroll.asSignal()
    
    private let disposeBag = DisposeBag()
    
    private var goalCircularViewIsScrolling = false {
        didSet {
            if goalCircularViewIsScrolling {
                [topScreenView, bottomScreenView].forEach { $0.alpha = 0 }
            }
        }
    }
    
    private var initialSettingDone = false
    
    var horizontalDidStartScrollBuzzed = false
    
    // Calendar data preperation
    var calendarModel: CalendarModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        // Calendar data preperation
        prepareCalendarViewModelData()
        
        pageIndicator.currentIndex = 0
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
                DispatchQueue.global(qos: .userInteractive).async {
                    self?.calendarModel?.addGoalByMonth(goal: goal)
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
                DispatchQueue.main.async {
                    self?.plusRotatingButtonInsideImageView.alpha = 1
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
        
        let page = pageIndicator.currentIndex

        if checkButton.isSelected == false {
            dayCheckAnimation()
            homeViewModel.dayCheck(at: page)
        } else {
            homeViewModel.dayUncheck(at: page)
        }

        checkButton.isSelected.toggle()
    }
    
    private func dayCheckAnimation() {
        lottieContainingBlurView.isHidden = false
        thumbsUpLottieView.play(completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                UIView.animate(withDuration: 0.2, delay: 0) {
                    self.lottieContainingBlurView.alpha = 0
                } completion: { _ in
                    self.lottieContainingBlurView.isHidden = true
                    self.lottieContainingBlurView.alpha = 1
                }
            }
        })
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
        navigationController?.pushViewController(settingsViewController, animated: true)
        
        scrollBackButton.sendActions(for: .touchUpInside)
    }
}

extension HomeViewController {
    private func prepareCalendarViewModelData() {
        let calendarModel = CalendarModel()
        calendarModel.setData()
        
        self.calendarModel = calendarModel
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
}


//MARK: - Initial UI Setting
extension HomeViewController {
    private func configure() {
        view.backgroundColor = .crayon
        edgesForExtendedLayout = [.top, .bottom]
        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .automatic
        
        layoutComponents()
        
        collectionViewBind()
        scrollStatusBind()
        messageBarBind()
        pageIndicatorBind()
        
        addButtonTargets()
        setDateCalendarButtonTitle()
    }
    
    private func addButtonTargets() {
        plusRotatingButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsButtonsTapped), for: .touchUpInside)
        bottomDateCalendarButton.addTarget(self, action: #selector(calenderButtonsTapped), for: .touchUpInside)
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        
        let tapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.numberOfTapsRequired = 2
        tapGestureRecognizer.addTarget(self, action: #selector(checkButtonTapped))
        
        goalCircularCollectionView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setDateCalendarButtonTitle() {
        let attributtedTitle = AttributedString(
            Date().stringFormat(of: .ddMMMEEEE_Comma_Space),
            attributes: AttributeContainer([
                .font: UIFont.sfPro(size: 12, family: .Medium),
                .foregroundColor: UIColor.grayC
            ])
        )
        bottomDateCalendarButton.configuration?.attributedTitle = attributtedTitle
    }
    
    private func collectionViewBind() {
        homeViewModel.goalViewModelsRelay
            .bind(to: goalCircularCollectionView.rx.items) { [weak self] cv, row, viewModel in
                let cell = cv.dequeueReusableCell(withReuseIdentifier: "GoalCircleCell", for: IndexPath(row: row, section: 0))
                
                guard let cell = cell as? GoalCircleCell, let self = self else { return cell }
                
                cell.setupCell(viewModel)
                
                let didScrollToXSignal = cell.didScrollToXSignal
                    .filter { _ in self.goalCircularViewIsScrolling == false }
                
                
                didScrollToXSignal
                    .emit(to: self.rx.scrolledToXUIChange)
                    .disposed(by: cell.disposeBag)
                
                didScrollToXSignal
                    .emit(to: self.rx.buzzToScrollOffsetX)
                    .disposed(by: cell.disposeBag)
                
                Signal
                    .merge(
                        self.scrollBackButton.rx.tap.asSignal(),
                        self.collectionViewDidScrollSignal
                    )
                    .emit(to: cell.rx.setContentOffsetZero)
                    .disposed(by: cell.disposeBag)
                
                return cell
            }
            .disposed(by: disposeBag)
    }
    
    
    private func scrollStatusBind() {
        goalCircularCollectionView.rx.willBeginDragging
            .bind { [weak self] in
                self?.goalCircularViewIsScrolling = true
            }
            .disposed(by: disposeBag)
        
        let didEndDecelerating = goalCircularCollectionView
            .rx.didEndDecelerating
            .share()
        
        didEndDecelerating
            .bind { [weak self] in
                self?.goalCircularViewIsScrolling = false
            }
            .disposed(by: disposeBag)
        
        goalCircularCollectionView.rx.didEndDragging
            .subscribe(onNext: { _ in
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            })
            .disposed(by: disposeBag)
        
        collectionViewDidScrollSignal
            .emit { [weak self] _ in
                DispatchQueue.main.async {
                    self?.scrollBackButton.alpha = 0
                    self?.plusRotatingButton.alpha = 1
                }
            }
            .disposed(by: disposeBag)
        
        collectionViewDidScrollSignal
            .flatMap {
                Observable.just(self.goalCircularCollectionView.contentOffset.y)
                    .asSignal(onErrorSignalWith: .empty())
            }
            .emit { [weak self] y in
                guard let self = self else { return }
                let page = Int(y/K.singleRowHeight)
                let viewModel = self.homeViewModel.goalViewModelsRelay.value[page]
                self.checkButton.isSelected = viewModel.todayChecked
            }
            .disposed(by: disposeBag)
    }

    private func pageIndicatorBind() {
        homeViewModel
            .goalViewModelsRelay
            .flatMap { Observable.just(($0.count, self.goalCircularCollectionView.contentOffset.y)) }
            .bind(to: pageIndicator.rx.numberOfPages)
            .disposed(by: disposeBag)
        
        collectionViewDidScrollSignal
            .flatMap {
                Observable.just(self.goalCircularCollectionView.contentOffset.y)
                    .asSignal(onErrorSignalWith: .empty())
            }
            .emit(to: pageIndicator.rx.updateIndicators)
            .disposed(by: disposeBag)
    }

    
    private func messageBarBind() {
        messageBar.mock_setMessage()
    }
    
    private func layoutComponents() {
        [
            goalCircularCollectionView,     pageIndicator,
            topTransparentScreenView,       bottomTransparentScreenView,
            topScreenView,                  bottomScreenView,
            messageBar,                     plusRotatingButton,
            checkButton,                    scrollBackButton,
            settingsButton,                 bottomDateCalendarButton,
            lottieContainingBlurView
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
            make.bottom.equalToSuperview().inset((K.hasNotch ? 125 : 86)*K.ratioFactor)
        }

        messageBar.snp.makeConstraints { make in
            make.height.equalTo(50*K.ratioFactor)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset((K.hasNotch ? 59 : 20)*K.ratioFactor)
        }
        
        scrollBackButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.trailing.equalTo(plusRotatingButton)
            make.bottom.equalTo(goalCircularCollectionView).inset(90)
        }
        
        checkButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.trailing.equalTo(plusRotatingButton)
            make.bottom.equalTo(plusRotatingButton.snp.top).offset(-16)
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
            make.leading.equalTo(messageBar)
            make.bottom.equalTo(messageBar.snp.top)
            make.height.equalTo(28)
            // automatic width
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
