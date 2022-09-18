//
//  RotatingNeumorphicButton.swift
//  GoalTracker2
//
//  Created by Jay Lee on 17/09/2022.
//

import UIKit

/// * size: 34 x 34
class RotatingButtonView: NeumorphicButton {
    let iconImageView = UIImageView()
    
    init(imageName: String) {
        super.init(color: .crayon, shadowSize: .medium)
            
        layer.cornerRadius = 17
        
        iconImageView.image = UIImage(named: imageName)
        
        layoutComponents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutComponents() {
        addSubview(iconImageView)
        iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
