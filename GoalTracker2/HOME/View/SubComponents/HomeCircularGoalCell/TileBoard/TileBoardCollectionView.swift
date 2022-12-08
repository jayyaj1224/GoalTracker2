//
//  TileCollectionView.swift
//  GoalTracker
//
//  Created by 이종윤 on 2022/01/31.
//

import UIKit
import RxSwift
import RxCocoa

class TileBoardCollectionView: UICollectionView, UICollectionViewDelegateFlowLayout {

    var viewModel: TileBoardViewModel?
    
    var disposeBag = DisposeBag()
    
    var heightConstraint: NSLayoutConstraint!
    var widthConstraint: NSLayoutConstraint!
    
    private var tileSize: CGSize = .zero
    
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0

        self.init(frame: .zero, collectionViewLayout: layout)
        self.backgroundColor = .crayon
        self.isScrollEnabled = false
        self.register(TileCell.self, forCellWithReuseIdentifier: "TileCell")
        self.delegate = self
        
        self.translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = self.heightAnchor.constraint(equalToConstant: 0)
        widthConstraint = self.widthAnchor.constraint(equalToConstant: 0)
        
        heightConstraint.isActive = true
        widthConstraint.isActive = true
    }

    func setup(with viewModel: TileBoardViewModel) {
        disposeBag = DisposeBag()
        
        self.viewModel = viewModel
        
        viewModel.tileStatusObservable
            .bind(
                to: self.rx.items(cellIdentifier: "TileCell")
            ){ index, statusRaw, cell in
                guard let tileCell = cell as? TileCell else { return }
                tileCell.imageWidth = viewModel.tileSize

                if viewModel.needDateLabelVisible(at: index) {
                    tileCell.configure(statusRaw: statusRaw, dateLabelVisible: true, index: index)
                    
                } else {
                    tileCell.configure(statusRaw: statusRaw, dateLabelVisible: false)
                }
            }
            .disposed(by: disposeBag)
        
        heightConstraint.constant = viewModel.boardSize.height
        widthConstraint.constant = viewModel.boardSize.width
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return viewModel?.itemSize(at: indexPath.row+1) ?? .zero
    }
}
