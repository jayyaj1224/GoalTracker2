//
//  GoalMonthlyTileCell.swift
//  GoalTracker2
//
//  Created by Jay Lee on 26/11/2022.
//

import UIKit

class GoalMonthlyTileCell: UICollectionViewCell {
    private let dayLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayB
        label.font = .sfPro(size: 8, family: .Medium)
        return label
    }()
    
    private let statusImageView = UIImageView(imageName: "tile_empty")
    
    private var status: GoalStatus = .none
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(day: Day) {
        
        dayLabel.text = String(day.date.suffix(2))
        
        guard day.date <= Date().stringFormat(of: .yyyyMMdd) else {
            statusImageView.image = UIImage(named: "tile_empty_disabled")
            isUserInteractionEnabled = false
            return
        }
        
        isUserInteractionEnabled = true
        
        status = GoalStatus(rawValue: day.status) ?? .none
        
        switch status {
        case .success:
            statusImageView.image = UIImage(named: "tile_success")
        case .fail:
            statusImageView.image = UIImage(named: "tile_fail")
        case .none:
            statusImageView.image = UIImage(named: "tile_empty")
        }
    }
    
    private func layout() {
        [dayLabel, statusImageView]
            .forEach(contentView.addSubview)
        
        dayLabel.snp.makeConstraints { make in
            make.bottom.equalTo(statusImageView.snp.top)
            make.centerX.equalToSuperview()
        }
        
        statusImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(25)
        }
    }
}
