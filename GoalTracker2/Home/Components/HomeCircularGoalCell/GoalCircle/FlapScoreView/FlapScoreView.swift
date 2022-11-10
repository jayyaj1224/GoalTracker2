//
//  FlapScoreView.swift
//  GoalTracker2
//
//  Created by Jay Lee on 08/11/2022.
//

import UIKit

class FlapScoreView: UIView {
    
    private let scoreFrameImageView: UIImageView = {
        let imageView = UIImageView(imageName: "")
        return imageView
    }()
    
    private let successScoreLabel: UILabel = {
        let label = UILabel()
        label.text = "000"
        label.withKern(value: 1.07)
        return label
    }()
    
    private let failScoreLabel: UILabel = {
        let label = UILabel()
        label.text = "000"
        label.withKern(value: 1.07)
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
