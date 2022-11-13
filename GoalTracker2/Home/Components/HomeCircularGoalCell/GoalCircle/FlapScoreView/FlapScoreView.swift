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
    
    let goalCircularCollectionView = CircularCollectionView()
    
    let plusRotatingButton: NeumorphicButton = {
        let button = NeumorphicButton(color: .crayon, shadowSize: .medium)
        button.layer.cornerRadius = 20
        return button
    }()
    
    lazy var plusRotatingButtonInsideImageView: UIImageView = {
        let imageView = UIImageView(imageName: "plus.neumorphism")
        plusRotatingButton.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(22)
        }
        return imageView
    }()

    private let messageBar = MessageBar()
    
    private let topTransparentScreenView = UIView()
    
    private let bottomTransparentScreenView = UIView()
    
    private let topCalendarButton: NeumorphicButton = {
        let button = NeumorphicButton(color: .crayon, shadowSize: .medium)
        button.layer.cornerRadius = 18
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(named: "calendar.neumorphism")
        button.configuration = configuration
        return button
    }()
    
    private let bottomDateCalendarButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(named: "calendar.neumorphism")
        configuration.imagePlacement = .leading
        configuration.titleAlignment = .trailing
        configuration.imagePadding = 6
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        let button = UIButton()
        button.configuration = configuration
        button.backgroundColor = .crayon.withAlphaComponent(0.6)
        button.layer.cornerRadius = 10
        return button
    }()
    
    
    private let leftDateCalendarButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(named: "calendar.neumorphism")
        configuration.imagePlacement = .leading
        configuration.titleAlignment = .trailing
        configuration.imagePadding = 6
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        let button = UIButton()
        button.configuration = configuration
        button.backgroundColor = .crayon.withAlphaComponent(0.6)
        button.layer.cornerRadius = 10
        return button
    }()
    
    
    private let rightDateCalendarButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(named: "calendar.neumorphism")
        configuration.imagePlacement = .leading
        configuration.titleAlignment = .trailing
        configuration.imagePadding = 6
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10)
        let button = UIButton()
        button.configuration = configuration
        button.backgroundColor = .crayon.withAlphaComponent(0.6)
        button.layer.cornerRadius = 10
        return button
    }()
    
    
    
    init() {
        super.init(frame: .zero)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
