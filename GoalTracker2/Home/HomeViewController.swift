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
    
    let plusRotatingButtonView = RotatingButtonView(imageName: "plus.neumorphism")

    private let messageBar = MessageBar()
    
    private let topTransparentScreenView = UIView()
    
    private let bottomTransparentScreenView = UIView()
    
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
    private let homeViewModel = HomeVieWModel()
    
    private lazy var circularScrollSignal = goalCircularCollectionView.rx.didScroll.asSignal()
    
    private let disposeBag = DisposeBag()
    
    private var goalCircularViewIsScrolling = false {
        didSet {
            if goalCircularViewIsScrolling {
                [topScreenView, bottomScreenView].forEach { $0.alpha = 0 }
            }
        }
    }
    
    private var initialSettingDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
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
        plusRotatingButtonView.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    // selector functions
    @objc private func plusButtonTapped() {
        let feedBackGenerator = UIImpactFeedbackGenerator(style: .medium)
        feedBackGenerator.impactOccurred()
        
        let plusMenuViewController = PlusMenuViewController()
        plusMenuViewController.modalPresentationStyle = .overFullScreen
        
        let newGoalSaved = plusMenuViewController.newGoalSavedSubject
        let plusMenuDismissed = plusMenuViewController.viewDismissSubject
        
        newGoalSaved
            .bind(to: homeViewModel.rx.relayAcceptNewGoal)
            .disposed(by: plusMenuViewController.disposeBag)
        
        plusMenuDismissed
            .subscribe(onNext: { [weak self] _ in
                self?.plusRotatingButtonView.iconImageView.alpha = 1
            })
            .disposed(by: disposeBag)
        
        Observable
            .zip(
                newGoalSaved.asObservable(),
                plusMenuDismissed.asObservable()
            )
            .flatMap { _ in return Observable.just(()) }
            .subscribe(self.rx.scrollToAddedGoal)
            .disposed(by: disposeBag)
        
       
        present(plusMenuViewController, animated: false) {
            self.plusRotatingButtonView.iconImageView.alpha = 0
        }
    }
    
    private func plusIconImageRotate180Degree() {
        let plusIconImage = self.plusRotatingButtonView.iconImageView
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            plusIconImage.transform = CGAffineTransform(rotationAngle: 180.pi.cgFloat)
        } completion: { _ in
            plusIconImage.transform = .identity
        }
    }
}

//MARK: - Reative Extension
extension Reactive where Base: HomeViewController {
    var uiChangeToScrollOffsetX: Binder<CGFloat> {
        Binder(base) {base, x in
            var alpha: CGFloat = 0
            
            switch x {
            case -30..<50:
                alpha = 0
            case 50...400:
                alpha = (x+50)/400
            case 400...500:
                alpha = 1
            default:
                return
            }
            
            let showing = [base.topScreenView, base.bottomScreenView, base.scrollBackButton]
            let hiding = [base.pageIndicator, base.plusRotatingButtonView]
            let hidingFast = [base.pageIndicator]
            
            showing.forEach { $0.alpha = alpha}
            hiding.forEach { $0.alpha = 1 - alpha }
            hidingFast.forEach { $0.alpha = 1 - alpha*2.5 }
        }
    }
    
    var scrollToAddedGoal: Binder<Void> {
        Binder(base) {base, goal in
            let y = base.goalCircularCollectionView.contentSize.height
            let rect = CGRect(x: 0, y: y-K.singleRowHeight, width: 10, height: K.singleRowHeight)
            
            DispatchQueue.main.async {
                base.goalCircularCollectionView.scrollRectToVisible(rect, animated: true)
            }
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
    }
    
    private func collectionViewBind() {
        homeViewModel.goalViewModelsRelay
            .bind(to: goalCircularCollectionView.rx.items) { [weak self] cv, row, viewModel in
                let cell = cv.dequeueReusableCell(withReuseIdentifier: "GoalCircleCell", for: IndexPath(row: row, section: 0))
                
                guard let cell = cell as? GoalCircleCell, let self = self else { return cell }
                
                cell.setupCell(viewModel)
                
                cell.didScrollToXSignal
                    .filter { _ in self.goalCircularViewIsScrolling == false }
                    .emit(to: self.rx.uiChangeToScrollOffsetX)
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
        
        circularScrollSignal
            .emit { _ in
                self.scrollBackButton.alpha = 0
                self.plusRotatingButtonView.alpha = 1
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
            goalCircularCollectionView,
            pageIndicator,
            topTransparentScreenView,       bottomTransparentScreenView,
            topScreenView,                  bottomScreenView,
            messageBar,
            plusRotatingButtonView,         scrollBackButton
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
        
        plusRotatingButtonView.snp.makeConstraints { make in
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
            make.trailing.equalTo(plusRotatingButtonView)
            make.bottom.equalTo(plusRotatingButtonView.snp.top).offset(-10)
        }

        pageIndicator.snp.makeConstraints { make in
            make.centerY.equalTo(goalCircularCollectionView)
            make.leading.equalTo(goalCircularCollectionView).inset(14)
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
            UIColor.crayon.cgColor
        ]
        bottomLayer.locations = [0.0, 1.0]
        bottomLayer.frame = bottomTransparentScreenView.bounds
        bottomTransparentScreenView.layer.addSublayer(bottomLayer)
    }
}
