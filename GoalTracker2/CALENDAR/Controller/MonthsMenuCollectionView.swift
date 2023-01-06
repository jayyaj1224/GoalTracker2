//
//  MonthsMenuView.swift
//  GoalTracker2
//
//  Created by Jay Lee on 24/11/2022.
//

import UIKit
import RxSwift
import RxCocoa

class MonthsMenuCollectionView: UICollectionView {
    private let monthString = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    private let disposeBag = DisposeBag()
    
    lazy var itemSelectedSignal: Signal<IndexPath> = self.rx.itemSelected.asSignal()
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 100, height: 24)
        layout.minimumLineSpacing = 20
        layout.scrollDirection = .horizontal
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .crayon
        showsHorizontalScrollIndicator = false
        contentInset = UIEdgeInsets(top: 0, left: (K.screenWidth-110)/2, bottom: 0, right: (K.screenWidth-110)/2)
        register(MonthsMenuCell.self, forCellWithReuseIdentifier: "MonthsMenuCell")
        
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        Observable.just(monthString)
            .bind(to: self.rx.items) { cv, row, month in
                guard let cell = cv.dequeueReusableCell(withReuseIdentifier: "MonthsMenuCell", for: IndexPath(row: row, section: 0)) as? MonthsMenuCell else { return UICollectionViewCell() }
                
                cell.configure(monthsString: month)
                
                return cell
            }
            .disposed(by: disposeBag)
        
        itemSelectedSignal
            .emit(to: self.rx.shouldScrollToItemCenter)
            .disposed(by: disposeBag)
    }
}

extension Reactive where Base: MonthsMenuCollectionView {
    var shouldScrollToItemCenter: Binder<IndexPath> {
        Binder(base) { base, indexPath in
            DispatchQueue.main.async {
                base.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
        }
    }
}
