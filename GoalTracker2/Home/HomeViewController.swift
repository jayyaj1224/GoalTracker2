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
    
    private let topAlphaScreenView = UIView()
    
    //MARK: - Logics
    private let homeViewModel = HomeVieWModel()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHome()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        plusIconImageRotate180Degree()
    }

}

//MARK: - UI Setups
extension HomeViewController {
    private func setupHome() {
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
    }
    
    private func messageBarBind() {
        messageBar.mock_setMessage()
    }
    
    private func layoutComponents() {
        [goalCircularCollectionView, dotPageIndicator, plusRotatingButtonView, topAlphaScreenView, messageBar]
            .forEach { components in
                self.view.addSubview(components)
            }

        goalCircularCollectionView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(K.singleRowHeight)
        }

        topAlphaScreenView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(self.goalCircularCollectionView.snp.top).offset(100)
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
    
//MARK: -  Button Actions
    private func addButtonTargets() {
        plusRotatingButtonView.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    // selector functions
    @objc private func plusButtonTapped() {
        let feedBackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        feedBackGenerator.impactOccurred()
        
        let plusMenuViewController = PlusMenuViewController()
        plusMenuViewController.modalPresentationStyle = .overFullScreen
        plusMenuViewController.dismissCompletionHandler = {
            self.plusRotatingButtonView.iconImageView.alpha = 1
        }
        
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
