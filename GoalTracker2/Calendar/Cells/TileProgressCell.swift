//
//  TileProgressCell.swift
//  GoalTracker2
//
//  Created by Jay Lee on 24/11/2022.
//

import UIKit

class TileProgressCell: UITableViewCell {
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return cv
    }()
    
    private let bottomTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .sfPro(size: 8, family: .Light)
        label.textColor = .grayB
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
