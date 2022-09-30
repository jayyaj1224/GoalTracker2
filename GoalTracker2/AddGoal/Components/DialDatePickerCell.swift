//
//  DialDatePickerCell.swift
//  GoalTracker2
//
//  Created by Jay Lee on 25/09/2022.
//

import UIKit

class DialDatePickerCell: UICollectionViewCell {
    let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .outFit(size: 14, family: .Light)
        label.textColor = .grayC
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        layout()
    }
    
    private func layout() {
        contentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
