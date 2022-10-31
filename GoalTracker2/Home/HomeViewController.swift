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
    private let goalCircularCollectionView = CircularCollectionView()
    
    private let plusRotatingButtonView = RotatingButtonView(imageName: "plus.neumorphism")

    private let messageBar = MessageBar()

    private let dotPageIndicator = VerticalPageIndicator()
    
    private let topGradationScreenView = UIView()
    
    private let bottomGradationScreenView = UIView()

    //MARK: - Logics
    private let homeViewModel = HomeVieWModel()
    
    private let disposeBag = DisposeBag()
    
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
                newGoalSaved,
                plusMenuDismissed
            )
            .subscribe(onNext: { [weak self] _ in
                let y = self?.goalCircularCollectionView.contentSize.height ?? 0
                let rect = CGRect(x: 0, y: y-K.singleRowHeight, width: 10, height: K.singleRowHeight)
                
                DispatchQueue.main.async {
                    self?.goalCircularCollectionView.scrollRectToVisible(rect, animated: true)
                }
            })
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

//MARK: - Initial UI Setting
extension HomeViewController {
    private func configure() {
        view.backgroundColor = .crayon
        edgesForExtendedLayout = [.top, .bottom]
        modalTransitionStyle = .coverVertical
        modalPresentationStyle = .automatic
        
        layoutComponents()
        collectionViewBind()
        messageBarBind()
        addButtonTargets()
    }
    
    private func collectionViewBind() {
        homeViewModel.goalViewModelsRelay
            .bind(to: goalCircularCollectionView.rx.items)(homeViewModel.cellFactory)
            .disposed(by: disposeBag)
        
        homeViewModel.collectionViewDidScrollSignal = goalCircularCollectionView.rx.didScroll
            .share()
            .asSignal(onErrorSignalWith: .empty())
    }
    
    private func messageBarBind() {
        messageBar.mock_setMessage()
    }
    
    private func layoutComponents() {
        [
            goalCircularCollectionView, dotPageIndicator, topGradationScreenView, bottomGradationScreenView, plusRotatingButtonView, messageBar
        ]
            .forEach(view.addSubview(_:))

        goalCircularCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(K.singleRowHeight)
        }

        topGradationScreenView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.goalCircularCollectionView.snp.top).offset(100)
        }
        
        bottomGradationScreenView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(messageBar).offset(-80)
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

        dotPageIndicator.snp.makeConstraints { make in
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
        topLayer.frame = topGradationScreenView.bounds
        topGradationScreenView.layer.addSublayer(topLayer)
        
        
        let bottomLayer = CAGradientLayer()
        bottomLayer.colors = [
            UIColor.crayon.withAlphaComponent(0).cgColor,
            UIColor.crayon.cgColor
        ]
        bottomLayer.locations = [0.0, 1.0]
        bottomLayer.frame = bottomGradationScreenView.bounds
        bottomGradationScreenView.layer.addSublayer(bottomLayer)
    }
}
