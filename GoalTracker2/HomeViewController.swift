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
//    private let goalCircularCollectionView = CircularCollectionView()
//
//    private let messageBar = MessageBar()
//
//    private let dotPageIndicator = VerticalPageIndicator()
    
    private let topAlphaScreenView = UIView()
    
    
    //MARK: - Logics
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHome()
    }
    
    
    private func setupHome() {
        
        
        
    }
}

//MARK: - UI Layout
extension HomeViewController {
//    
//    private func layout() {
//        [goalCircularCollectionView, dotPageIndicator, topAlphaScreenView, messageBar]
//            .forEach { components in
//                self.view.addSubview(components)
//            }
//
//        goalCircularCollectionView.snp.makeConstraints { make in
//            make.leading.trailing.equalToSuperview()
//            make.centerY.equalToSuperview()
//            make.height.equalTo(K.singleRowHeight)
//        }
//
//        topAlphaScreenView.snp.makeConstraints { make in
//            make.top.leading.trailing.equalToSuperview()
//            make.bottom.equalTo(self.goalCircularCollectionView.snp.top).offset(100)
//        }
//
//        messageBar.snp.makeConstraints { make in
//            make.height.equalTo(50*K.ratioFactor)
//            make.leading.trailing.equalToSuperview().inset(18)
//            make.bottom.equalToSuperview().inset((K.hasNotch ? 59 : 20)*K.ratioFactor)
//        }
//
//        dotPageIndicator.snp.makeConstraints { make in
//            make.centerY.equalTo(goalCircularCollectionView)
//            make.leading.equalTo(goalCircularCollectionView).inset(14)
//        }
//    }
}
