//
//  AddGoalDatePickerRowView.swift
//  GoalTracker2
//
//  Created by Jay Lee on 15/10/2022.
//

import UIKit

class AddGoalDatePickerRowView: UIView {
    let componentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .outFit(size: 14, family: .Regular)
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        
        addSubview(componentLabel)
        
        componentLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
