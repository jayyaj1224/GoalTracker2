//
//  HomeViewController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 12/09/2022.
//

import UIKit
import RxSwift
import RxCocoa

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
    
    private let topCalendarButton: NeumorphicButton = {
        let button = NeumorphicButton(color: .crayon, shadowSize: .medium)
        button.layer.cornerRadius = 18
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(named: "calendar.neumorphism")
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
    
    let pageIndicator = VerticalPageIndicator()
    
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
    
    //MARK: - Logics
    let homeViewModel = HomeVieWModel()
    
    private lazy var circularScrollSignal = goalCircularCollectionView.rx.didScroll.asSignal()
    
    private let disposeBag = DisposeBag()
    
    // Calendar preperation
    private let calendarViewController = CalendarViewController()
    
    private var calendarViewModelDataPreperation: [String : [GoalMonthlyViewModel]] = [:]
    
    private var goalCircularViewIsScrolling = false {
        didSet {
            if goalCircularViewIsScrolling {
                [topScreenView, bottomScreenView].forEach { $0.alpha = 0 }
            }
        }
    }
    
    private var initialSettingDone = false
    
    var horizontalDidStartScrollBuzzed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        // Calendar data preperation
        calendarViewController.prepareViewModelData()
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
    private func addButtonTargets() {
        plusRotatingButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        topCalendarButton.addTarget(self, action: #selector(calenderButtonsTapped), for: .touchUpInside)
        bottomDateCalendarButton.addTarget(self, action: #selector(calenderButtonsTapped), for: .touchUpInside)
    }
    
    // selector functions
    @objc private func plusButtonTapped() {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        
        let plusMenuViewController = PlusMenuViewController()
        plusMenuViewController.modalPresentationStyle = .overFullScreen
        
        let newGoalSaved = plusMenuViewController.newGoalSavedSubject
        let plusMenuDismissed = plusMenuViewController.viewDismissSubject
        
        newGoalSaved
            .bind(to: homeViewModel.rx.relayAcceptNewGoal)
            .disposed(by: plusMenuViewController.disposeBag)
        
        plusMenuDismissed
            .subscribe(onNext: { [weak self] _ in
                DispatchQueue.main.async {
                    self?.plusRotatingButtonInsideImageView.alpha = 1
                }
            })
            .disposed(by: disposeBag)
        
        
        let newGoalAdded = Observable
            .zip(newGoalSaved.asObservable(), plusMenuDismissed.asObservable())
            .share()
        
        newGoalAdded
            .flatMap { _ in return Observable.just(()) }
            .subscribe(self.rx.scrollToAddedGoal)
            .disposed(by: disposeBag)
        
        newGoalAdded
            .subscribe(onNext: { [weak self] _ in
                self?.calendarViewController.prepareViewModelData()
            })
            .disposed(by: disposeBag)
        
       
        present(plusMenuViewController, animated: false) {
            DispatchQueue.main.async {
                self.plusRotatingButtonInsideImageView.alpha = 0
            }
        }
    }
    
    private func plusIconImageRotate180Degree() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            self.plusRotatingButtonInsideImageView.transform = CGAffineTransform(rotationAngle: 180.pi.cgFloat)
        } completion: { _ in
            self.plusRotatingButtonInsideImageView.transform = .identity
        }
    }
    
    @objc private func calenderButtonsTapped(_ sender: UIButton) {
        navigationController?.pushViewController(calendarViewController, animated: true)
        
        scrollBackButton.sendActions(for: .touchUpInside)
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
            let hiding = [base.pageIndicator, base.plusRotatingButton]
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
    
    var setPageIndicator: Binder<Int> {
        Binder(base) { base, goalCount in
            base.pageIndicator.set(numberOfPages: goalCount)
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
                        self.circularScrollSignal
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
        
        didEndDecelerating
            .withLatestFrom(goalCircularCollectionView.rx.contentOffset)
            .subscribe(pageIndicator.rx.shouldSetPage)
            .disposed(by: disposeBag)
        
        goalCircularCollectionView.rx.didEndDragging
            .subscribe(onNext: { _ in
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            })
            .disposed(by: disposeBag)
        
        circularScrollSignal
            .emit { _ in
                DispatchQueue.main.async {
                    self.scrollBackButton.alpha = 0
                    self.plusRotatingButton.alpha = 1
                }
            }
            .disposed(by: disposeBag)
    }

    private func pageIndicatorBind() {
        homeViewModel
            .goalViewModelsRelay
            .flatMap { Observable.just($0.count) }
            .bind(to: self.rx.setPageIndicator)
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
            scrollBackButton,               topCalendarButton,
            bottomDateCalendarButton
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
            make.bottom.equalTo(plusRotatingButton.snp.top).offset(-10)
        }

        pageIndicator.snp.makeConstraints { make in
            make.centerY.equalTo(goalCircularCollectionView)
            make.leading.equalTo(goalCircularCollectionView).inset(14)
        }
        
        topCalendarButton.snp.makeConstraints { make in
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
