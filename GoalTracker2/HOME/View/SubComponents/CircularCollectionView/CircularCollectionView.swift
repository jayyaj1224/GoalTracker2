//
//  CircularCollectionView.swift
//  GoalTracker
//
//  Created by Jay Lee on 03/07/2022.
//

import UIKit
import RxSwift
import RxCocoa

class CircularCollectionView: UICollectionView {
//    public let pageWidth = K.screenWidth
//
//    public let pageHeight = K.singleRowHeight
//
    public var pageOffset: Int {
        Int(round((contentOffset.y)/K.singleRowHeight))
    }
    
    init() {
        super.init(frame: .zero, collectionViewLayout: CircularLayout())
        
        self.register(GoalCircleCell.self, forCellWithReuseIdentifier: "GoalCircleCell")
        self.backgroundColor = .crayon
        self.isPagingEnabled = true
        self.clipsToBounds = false
        self.showsVerticalScrollIndicator = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
