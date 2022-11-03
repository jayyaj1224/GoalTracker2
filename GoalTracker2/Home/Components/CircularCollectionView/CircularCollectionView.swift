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
    public let pageWidth = K.screenWidth
    
    public let pageHeight = K.singleRowHeight
    
    public var currentPage: Int {
        Int(round((contentOffset.y)/K.singleRowHeight))
    }
    
    private var currentPageActionTargetIndex: Int = 0
    
    
    
    /// bind to only current page
    var currentPageRelay = BehaviorRelay<Int>(value: 0)
    
    var currentPageReuseBag = DisposeBag()
    
    
    
    private let disposeBag = DisposeBag()
    
    init() {
        super.init(frame: .zero, collectionViewLayout: CircularLayout())
        
        self.register(GoalCircleCell.self, forCellWithReuseIdentifier: "GoalCircleCell")
        self.backgroundColor = .crayon
        self.isPagingEnabled = true
        self.clipsToBounds = false
        self.showsVerticalScrollIndicator = false
        
        self.rx.didScroll
            .filter { self.currentPage != self.currentPageActionTargetIndex }
            .flatMap { [weak self] offset -> Observable<Int> in
                guard let self = self else { return .empty() }
                
                self.currentPageActionTargetIndex = self.currentPage
                
                return Observable.just(self.currentPage)
            }
            .bind(to: currentPageRelay)
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func currentPageAction(_ action: @escaping (CircularCollectionView)->Void) {
        action(self)
    }
}

extension Reactive where Base: CircularCollectionView {
//    var adsf: Binder<Void> {
//         Binder(base) { base, _ in
//            let currentInex = base.currentPage
//            
//            if currentInex != base.currentPageActionTargetIndex {
//                base.currentPageReuseBag = DisposeBag()
//            }
//            
//            let currentCell = base.cellForItem(at: IndexPath(row: 2, section: 0))
//            
//            guard let currentCell = currentCell as? GoalCircleCell else {
//                return
//            }
//        
//        }
//    }
}
