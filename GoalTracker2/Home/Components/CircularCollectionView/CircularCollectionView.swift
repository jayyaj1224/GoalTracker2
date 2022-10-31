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
    var currentIndex: CGFloat = 0
    
    let pageWidth = K.screenWidth
    
    let pageHeight = K.singleRowHeight
    
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero, collectionViewLayout: CircularLayout())
        
        self.register(GoalCircleCell.self, forCellWithReuseIdentifier: "GoalCircleCell")
        self.backgroundColor = .crayon
        self.isPagingEnabled = true
        self.clipsToBounds = false
        self.showsVerticalScrollIndicator = false
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        self.rx.didScroll
            .bind(to: self.rx.pageAt)
            .disposed(by: self.disposeBag)
    }
}

extension Reactive where Base: CircularCollectionView {
    var pageAt: Binder<Void> {
        Binder(base) { base, _ in
            base.currentIndex = round((base.contentOffset.y)/K.singleRowHeight)
        }
    }
}
