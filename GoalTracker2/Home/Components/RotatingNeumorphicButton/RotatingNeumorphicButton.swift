//
//  RotatingNeumorphicButton.swift
//  GoalTracker2
//
//  Created by Jay Lee on 17/09/2022.
//

import UIKit

class RotatingNeumorphicButton: NeumorphicButton {
    private let rotatingButtonImageView = UIImageView()
    
    init(imageName: String) {
        super.init(color: .crayon, shadowSize: .medium)
        
        layer.cornerRadius = 17
        
        rotatingButtonImageView.image = UIImage(named: imageName)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        addSubview(rotatingButtonImageView)
        
        rotatingButtonImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.
        }
    }
}
