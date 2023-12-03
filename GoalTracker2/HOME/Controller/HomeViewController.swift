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
//import Toast_Swift

class HomeViewController: UIViewController {
    //MARK: - UI Components
    fileprivate let goalCollectionView = CircularCollectionView()
    
    fileprivate let plusRotatingButton: NeumorphicButton = {
        let button = NeumorphicButton(color: .crayon, type: .large)
        button.layer.cornerRadius = 20
        return button
    }()
    
    lazy fileprivate var plusRotatingButtonInsideImageView: UIImageView = {
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
    
    fileprivate let pageIndicator = NeumorphicPageControl(pageSize: K.singleRowHeight, axis: .vertical)
    
    fileprivate let checkButton: UIButton = {
        let button = UIButton()
        button.tintColor = .clear
        button.configuration = UIButton.Configuration.plain()
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
    
    fileprivate let scrollBackButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(named: "back.neumorphism")
        let button = UIButton()
        button.configuration = configuration
        button.alpha = 0
        return button
    }()
    
    fileprivate let topScreenView: UIView = {
        let view = UIView()
        view.backgroundColor = .crayon
        view.alpha = 0
        return view
    }()
    
    fileprivate let bottomScreenView: UIView = {
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
    
    //MARK: - Properties
    fileprivate let homeViewModel = HomeViewModel()
    
    typealias CircleScroll = (status: ScrollStatus, y: CGFloat)
    
    enum ScrollStatus {
        case  isScorlling, stopped
    }
    
    private let circularCvScrollStautsRelay = BehaviorRelay<CircleScroll>(value: (status: .stopped, y: 0))
    
    /// - y offset only once, when the circular collectionview started to scroll
    private let scrollStartedAtRelay = BehaviorRelay<CGFloat>(value: 0)
    
    /// - y offset only once, when the circular collectionview stopped
    fileprivate let scrollStoppedAtRelay = BehaviorRelay<CGFloat>(value: 0)
    
    private let newGoalSavedSubject = PublishSubject<Goal>()
    
    private let disposeBag = DisposeBag()
    
    private var initialSettingDone = false
    
    fileprivate var horizontalDidStartScrollBuzzed = false
    
    fileprivate var isMagnified = false
    
    //MARK: - ViewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        showIntroTutorialViewController(dismissCompletion: { [weak self] in
            UserDefaults.standard.set(true, forKey: Keys.tutorial_intro)
            
            DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                self?.showAddGoalTutorialBalloonIfNeeded()
            }
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        plusIconImageRotate180Degree()
        
        if initialSettingDone == false {
            addGradient()
            circularCvScrollStautsRelay.accept(CircleScroll(status: .stopped, y: 0))
            
            initialSettingDone = true
        }
    }
}

//MARK: - UI Setting
extension HomeViewController {
    private func configure() {
        view.backgroundColor = .crayon
        edgesForExtendedLayout = [.top, .bottom]
        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .automatic
        
        addButtonTargets()
        layoutComponents()
        bindings()
        setDateCalendarButtonTitle()
    }
    
    private func addButtonTargets() {
        plusRotatingButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        settingsButton.addTarget(self, action: #selector(settingsButtonsTapped), for: .touchUpInside)
        bottomDateCalendarButton.addTarget(self, action: #selector(calenderButtonsTapped), for: .touchUpInside)
        checkButton.addTarget(self, action: #selector(checkButtonTapped), for: .touchUpInside)
        messageBar.addTarget(self, action: #selector(messageBarTapped), for: .touchUpInside)

        let cvDoubletapGestureRecognizer = UITapGestureRecognizer()
        cvDoubletapGestureRecognizer.numberOfTapsRequired = 2
        cvDoubletapGestureRecognizer.addTarget(self, action: #selector(collectionViewDoubleTapped))
        goalCollectionView.addGestureRecognizer(cvDoubletapGestureRecognizer)
        
        let lottieTapGestureRecognizer = UITapGestureRecognizer()
        lottieTapGestureRecognizer.addTarget(self, action: #selector(lottieBlurViewTapped))
        lottieContainingBlurView.addGestureRecognizer(lottieTapGestureRecognizer)
    }
    
    private func bindings() {
        bindCollectionView()
        
        bindScrollStatusRelay()
        
        messageBarBind()
        pageIndicatorBind()
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
                goalCollectionView.rx.didScroll.map { ScrollStatus.isScorlling },
                goalCollectionView.rx.didEndDragging.map { _ in ScrollStatus.stopped },
                goalCollectionView.rx.didEndDecelerating.map { ScrollStatus.stopped }
            )
            .distinctUntilChanged()
        
        scrollStatusChanged
            .withLatestFrom(goalCollectionView.rx.contentOffset) {
                CircleScroll(status: $0, y: $1.y)
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
        
        scrollStartedAtRelay
            .bind(to: self.rx.circularScrollStartedAt)
            .disposed(by: disposeBag)
        
        scrollStoppedAtRelay
            .bind(to: self.rx.circularScrollStoppedAt)
            .disposed(by: disposeBag)
    }
    
    private func bindCollectionView() {
        homeViewModel.goalViewModelsRelay
            .bind(to: goalCollectionView.rx.items) { [weak self] cv, row, viewModel in
                let cell = cv.dequeueReusableCell(withReuseIdentifier: "GoalCircleCell", for: IndexPath(row: row, section: 0))
                
                guard let cell = cell as? GoalCircleCell, let self = self else { return cell }
                
                cell.setupCell(viewModel)
                
                let didScrollToXSignal = cell.didScrollToXSignal
                    .filter { _ in self.circularCvScrollStautsRelay.value.status == .stopped }
                
                didScrollToXSignal
                    .emit(to: self.rx.goalScrolledHorizontallyAt)
                    .disposed(by: cell.reuseBag)
                
                didScrollToXSignal
                    .emit(to: self.rx.buzzToScrollOffsetX)
                    .disposed(by: cell.reuseBag)
                
                Observable
                    .merge(
                        self.scrollBackButton.rx.tap.asObservable(),
                        self.scrollStoppedAtRelay.map { _ in }.asObservable()
                    )
                    .bind(to: cell.rx.setContentOffsetZero)
                    .disposed(by: cell.reuseBag)
                return cell
            }
            .disposed(by: disposeBag)
        
        homeViewModel.goalViewModelsRelay
            .bind(to: self.rx.viewModelDidChange)
            .disposed(by: disposeBag)
    }
    
    private func pageIndicatorBind() {
        homeViewModel
            .goalViewModelsRelay
            .flatMap { Observable.just(($0.count, self.goalCollectionView.contentOffset.y)) }
            .bind(to: pageIndicator.rx.numberOfPages)
            .disposed(by: disposeBag)
        
        scrollStoppedAtRelay
            .bind(to: pageIndicator.rx.currentOffset)
            .disposed(by: disposeBag)
    }
    
    private func messageBarBind() {
        scrollStoppedAtRelay
            .bind(to: self.rx.setMessageBar)
            .disposed(by: disposeBag)
    }
    
    private func layoutComponents() {
        [
            goalCollectionView,     pageIndicator,
            topTransparentScreenView,       bottomTransparentScreenView,
            topScreenView,                  bottomScreenView,
            plusRotatingButton,
            checkButton,                    scrollBackButton,
            settingsButton,                 //magnifierButton,
            bottomDateCalendarButton,
            lottieContainingBlurView,       emptyLabel,
            messageBar
        ]
            .forEach(view.addSubview(_:))

        goalCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(K.singleRowHeight)
        }

        topTransparentScreenView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.goalCollectionView.snp.top).offset(40)
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
            make.bottom.equalToSuperview().inset((DeviceInfo.current.hasNotch ? 114 : 94)*K.ratioFactor)
        }

        messageBar.snp.makeConstraints { make in
            make.height.equalTo(54*K.ratioFactor)
            make.leading.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset((DeviceInfo().hasNotch ? 30 : 20)*K.ratioFactor)
        }
        
        scrollBackButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.trailing.equalTo(plusRotatingButton)
            make.bottom.equalTo(checkButton.snp.top).offset(-30)
        }
        
        checkButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.trailing.equalTo(plusRotatingButton)
            make.bottom.equalTo(plusRotatingButton.snp.top).offset(-12)
        }

        pageIndicator.snp.makeConstraints { make in
            make.centerY.equalTo(goalCollectionView)
            make.leading.equalTo(goalCollectionView)
        }
        
        settingsButton.snp.makeConstraints { make in
            make.size.equalTo(36)
            make.trailing.equalTo(plusRotatingButton)
            make.top.equalToSuperview().inset(60)
        }
        
        bottomDateCalendarButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(15)
            make.bottom.equalTo(messageBar.snp.top).offset(-4)
            make.height.equalTo(28)
        }
        
        lottieContainingBlurView.snp.makeConstraints { make in
            make.leading.height.trailing.equalToSuperview()
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
        topLayer.locations = [0.2, 1.0]
        topLayer.frame = topTransparentScreenView.bounds
        topTransparentScreenView.layer.addSublayer(topLayer)
        
        
        let bottomLayer = CAGradientLayer()
        bottomLayer.colors = [
            UIColor.crayon.withAlphaComponent(0).cgColor,
            UIColor.crayon.withAlphaComponent(1).cgColor
        ]
        bottomLayer.locations = [0.0, 0.3]
        bottomLayer.frame = bottomTransparentScreenView.bounds
        bottomTransparentScreenView.layer.addSublayer(bottomLayer)
    }
}

//MARK: - Reative Extension
extension Reactive where Base: HomeViewController {
    fileprivate var circularScrollStartedAt: Binder<CGFloat> {
        Binder(base) { base, y in
            DispatchQueue.main.async {
//                base.view.hideAllToasts()
                
                base.scrollBackButton.alpha = 0
                base.plusRotatingButton.alpha = 1
            }
        }
    }
    
    fileprivate var circularScrollStoppedAt: Binder<CGFloat> {
        Binder(base) {base, y in
            let viewModels = base.homeViewModel.goalViewModelsRelay.value
            
            guard !viewModels.isEmpty else { return }
            
            let row = Int(y/K.singleRowHeight)
            let todayStatus = base.homeViewModel.getTodayStatus(at: row)
            
            base.checkButton.isSelected = (todayStatus == .success)
            
            if SettingsManager.shared.vibrate {
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
        }
    }
    
    fileprivate var goalScrolledHorizontallyAt: Binder<CGFloat> {
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
            let showing = [base.scrollBackButton]
            let showingWhenNotMagnified = [base.topScreenView, base.bottomScreenView]
            let hiding = [base.checkButton, base.plusRotatingButton]
            let hidingFast = [base.pageIndicator]
            
            DispatchQueue.main.async {
                showing.forEach { $0.alpha = alpha}
                hiding.forEach { $0.alpha = 1 - alpha }
                hidingFast.forEach { $0.alpha = 1 - alpha*2.5 }
                
                if base.isMagnified == false {
                    showingWhenNotMagnified.forEach { $0.alpha = alpha}
                }
            }
        }
    }
    
    fileprivate var viewModelDidChange: Binder<[GoalViewModel]> {
        Binder(base) { base, viewModels in
            base.emptySettingsIfNeeded()
        }
    }
    
    fileprivate var buzzToScrollOffsetX: Binder<CGFloat> {
        Binder(base) { base, x in
            guard SettingsManager.shared.vibrate else {
                return
            }
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
    
    fileprivate var scrollToAddedGoal: Binder<Void> {
        Binder(base) {base, _ in
            let offsetY = base.goalCollectionView.contentSize.height-K.singleRowHeight
            let rect = CGRect(x: 0, y: offsetY, width: 10, height: K.singleRowHeight)
            
            DispatchQueue.main.async {
                base.goalCollectionView.scrollRectToVisible(rect, animated: true)
            }
            
            base.pageIndicator.updateIndicators(offset: offsetY)
            
            base.checkButton.isSelected = false
        }
    }
    
    fileprivate var showGoalTutorialIfNeeded: Binder<Void> {
        Binder(base) {base, _ in
            base.showNewGoalTutorialIfNeeded()
        }
    }
    
    fileprivate var newGoalSaved: Binder<Goal> {
        Binder(base) { base, new in
            base.homeViewModel.acceptNewGoal(new)
            
            base.messageBar.setNewGoalPlaceHolderMessage()
        }
    }
    
    fileprivate var deleteGoalWithIdentifier: Binder<String> {
        Binder(base) { base, identifier in
            let base = base as HomeViewController
            
            let goals = base.homeViewModel.goalViewModelsRelay.value
            let numberOfItems = goals.count
            
            var isFistItemDelete = false

            DispatchQueue.main.async {
                let y = base.goalCollectionView.contentOffset.y
                let oneRowBefore = CGPoint(x: 0, y: y-K.singleRowHeight)

                if oneRowBefore.y >= 0 {
                    base.goalCollectionView.setContentOffset(oneRowBefore, animated: true)

                } else if oneRowBefore.y < 0 {
                    guard  numberOfItems > 1 else { return }

                    isFistItemDelete = true

                    let oneRowAfter = CGPoint(x: 0, y: y+K.singleRowHeight)
                    base.goalCollectionView.setContentOffset(oneRowAfter, animated: true)
                }
            }

            let delay = (numberOfItems==1) ? 0.0 : 0.6

            DispatchQueue.main.asyncAfter(deadline: .now()+delay) {
                if isFistItemDelete {
                    base.goalCollectionView.setContentOffset(.zero, animated: false)
                }

                let goalVmsFiltered = base.homeViewModel
                    .goalViewModelsRelay.value
                    .filter { $0.goal.identifier != identifier }

                base.homeViewModel.goalViewModelsRelay
                    .accept(goalVmsFiltered)
            }
        }
    }
    
    fileprivate var setMessageBar: Binder<CGFloat> {
        Binder(base) {base, offsetY in
            let page = Int(offsetY/K.singleRowHeight)
            let id = base.homeViewModel.goalIdentifier(at: page)
            if let userNotes = UserNoteManager.shared.userNotesDictionary[id] {
                base.messageBar.configure(with: userNotes)
            }
        }
    }
}

//MARK: -  Button Actions
extension HomeViewController {
    @objc private func plusButtonTapped() {
        if SettingsManager.shared.vibrate {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
        
        let plusMenuViewController = PlusMenuViewController()
        plusMenuViewController.modalPresentationStyle = .overFullScreen
        plusMenuViewController.presentCalendarViewCompletion = { [weak self] in
            self?.calenderButtonsTapped()
        }
        
        let row = Int(goalCollectionView.contentOffset.y/K.singleRowHeight)
        let goals = self.homeViewModel.goalViewModelsRelay.value.map { $0.goal }
        
        if goals.count != 0 {
            let goal = goals[row]
            plusMenuViewController.selectedGoalIdentifier = goal.identifier
            plusMenuViewController.selectedGoalTitle = goal.title
        }
        
        plusMenuViewController.newGoalSavedSubject
            .bind(to: self.rx.newGoalSaved)
            .disposed(by: plusMenuViewController.disposeBag)
        
        plusMenuViewController.goalDeletedIdentifierSubject
            .bind(to: self.rx.deleteGoalWithIdentifier)
            .disposed(by: plusMenuViewController.disposeBag)
        
        Observable
            .merge(
                plusMenuViewController.newGoalSavedSubject.map{_ in}.asObservable(),
                plusMenuViewController.viewDismissSubject.asObservable()
            )
            .subscribe(onNext: {
                DispatchQueue.main.async {
                    self.plusRotatingButtonInsideImageView.alpha = 1
                }
            })
            .disposed(by: disposeBag)
        
        let newGoalSavedAndDismissed = Observable
            .zip(
                plusMenuViewController.newGoalSavedSubject.asObservable(),
                plusMenuViewController.viewDismissSubject.asObservable()
            )
            .flatMap { _ in return Observable.just(()) }
            .share()
        
        newGoalSavedAndDismissed
            .map { _ in }
            .subscribe(self.rx.showGoalTutorialIfNeeded)
            .disposed(by: plusMenuViewController.disposeBag)
        
        newGoalSavedAndDismissed
            .subscribe(self.rx.scrollToAddedGoal)
            .disposed(by: plusMenuViewController.disposeBag)
        
        present(plusMenuViewController, animated: false) {
            DispatchQueue.main.async {
                self.plusRotatingButtonInsideImageView.alpha = 0
            }
        }
    }
    
    @objc private func collectionViewDoubleTapped(_ sender: UITapGestureRecognizer) {
        if isMagnified {
            UIView.animate(withDuration: 0.3, delay: 0) {
                self.goalCollectionView.transform = .identity
            }
        } else {
            [self.topScreenView, self.bottomScreenView]
                .forEach { $0.alpha = 0 }
            
            UIView.animate(withDuration: 0.3, delay: 0) {
                self.goalCollectionView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
            }
        }
        
        isMagnified.toggle()
    }
    
    @objc private func checkButtonTapped(_ sender: Any) {
        if sender is UITapGestureRecognizer && checkButton.isSelected {
            return
        }
        
        if homeViewModel.goalViewModelsRelay.value.isEmpty {
            return
        }
        
//        view.hideAllToasts()
        
        let page = pageIndicator.currentIndex
        
        if checkButton.isSelected == false {
            dayCheckLottieAnimation()
            dayCheckToast()
            homeViewModel.dayCheck(at: page, status: .success)
        } else {
            homeViewModel.dayCheck(at: page, status: .fail)
            
//            var toastStyle = ToastStyle()
//            toastStyle.backgroundColor = .black.withAlphaComponent(0.4)
//            toastStyle.fadeDuration = 0.1
            
            GTToast.hideAllToast()
            thumbsUpLottieView.stop()
            
            lottieDismissAnimation()
            
//            view.makeToast(
//                "Unchecked",
//                point: CGPoint(x: K.screenWidth/2, y: messageBar.frame.minY-100),
//                title: nil, image: nil,
//                style: toastStyle,
//                completion: nil
//            )
        }
        
        showCalendarTutorialBalloonIfNeeded()
        
        checkButton.isSelected.toggle()
    }
    
    @objc private func lottieBlurViewTapped() {
        DispatchQueue.main.async {
            self.lottieDismissAnimation()
            
            GTToast.hideAllToast()
        }
    }
    
    @objc private func messageBarTapped() {
        let row = Int(goalCollectionView.contentOffset.y/K.singleRowHeight)
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
}

//MARK: -  Animation
extension HomeViewController {
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
        GTToast
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
        let goals = homeViewModel
            .goalViewModelsRelay.value
            .map(\.goal)
        
        let calendarViewController = CalendarViewController(goals: goals)

        calendarViewController
            .goalsEditedSubject
            .map { $0.compactMap(GoalViewModel.init) }
            .bind(to: homeViewModel.goalViewModelsRelay)
            .disposed(by: calendarViewController.disposeBag)
        
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
}

extension HomeViewController: SettingsProtocol {
    func dataHasReset() {
        homeViewModel.goalViewModelsRelay.accept([])
        
        messageBar.setGoalEmptyMessage()
        
        checkButton.isSelected = false
        checkButton.isEnabled = false
    }
    
    func scoreBoardSet() {
        goalCollectionView.reloadData()
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {

        return PresentationController(contentHeight: K.screenHeight*0.7, presentedViewController: presented, presenting: presenting)
    }
}

//MARK: Tutorials
extension HomeViewController {
    private func showIntroTutorialViewController(dismissCompletion: (()->Void)?=nil) {
        guard !UserDefaults.standard.bool(forKey: Keys.tutorial_intro) else { return }
        
        let tutorialVc = TutorialViewController(tutorialName: "intro", numberOfPages: 5, swipeDismiss: true)
        tutorialVc.modalPresentationStyle = .overFullScreen
        tutorialVc.dismissCompletion = dismissCompletion
        
        present(tutorialVc, animated: false)
    }
    
    private func showAddGoalTutorialBalloonIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: Keys.toolTip_AddGoal) else { return }
        
        UserDefaults.standard.set(true, forKey: Keys.toolTip_AddGoal)
        
        TutorialBalloon
            .make(
                message: "Start a new goal",
                tailPosition: .right,
                locate: {[weak self] balloon in
                    
                    self?.view.addSubview(balloon)
                    
                    balloon.snp.makeConstraints { make in
                        make.bottom.equalTo(plusRotatingButton)
                        make.trailing.equalTo(plusRotatingButton.snp.leading).offset(-19)
                    }
                }
            )
            .show()
    }
    
    fileprivate func showNewGoalTutorialIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: Keys.tutorial_goal) else { return }
        
        UserDefaults.standard.set(true, forKey: Keys.tutorial_goal)
        
        let tutorial = TutorialViewController(tutorialName: "new-goal-tutorial", numberOfPages: 1)
        tutorial.modalPresentationStyle = .overFullScreen
        self.present(tutorial, animated: true)
    }
    
    private func showCalendarTutorialBalloonIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: Keys.toolTip_HomeCalendarButton) else { return }
        
        UserDefaults.standard.set(true, forKey: Keys.toolTip_HomeCalendarButton)
        
        TutorialBalloon
            .make(
                message: "Check out calendar",
                tailPosition: .bottom,
                locate: {[weak self] balloon in
                    guard let self = self else { return }
                    
                    self.view.addSubview(balloon)
                    
                    balloon.snp.makeConstraints { make in
                        make.bottom.equalTo(self.bottomDateCalendarButton.snp.top).offset(-14)
                        make.leading.equalToSuperview().inset(20)
                    }
                }
            )
            .show()
    }
}
