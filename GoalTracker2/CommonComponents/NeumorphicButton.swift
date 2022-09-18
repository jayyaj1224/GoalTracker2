//
//  NeumorphicButton.swift
//  GoalTracker2
//
//  Created by Lee Jong Yun on 2022/09/14.
//

import UIKit

/// UIButton with Neumorphism Shadow
/// *     init(color: UIColor, shadowSize: ShadowSize)
/// *     enum NeumorphicSize { case small, medium, large }
///
class NeumorphicButton: UIButton {
    private let upperWhiteShadowLayer = CALayer()
    
    private let underBlackShadowLayer = CALayer()
    
    init(color: UIColor, shadowSize: ShadowSize) {
        super.init(frame: .zero)
        backgroundColor = color
        
        [upperWhiteShadowLayer, underBlackShadowLayer].forEach { shadowLayer in
            shadowLayer.backgroundColor = color.cgColor
            
            layer.insertSublayer(shadowLayer, at: 0)
        }
        
        setNeumorphicShadow(at: [upperWhiteShadowLayer, underBlackShadowLayer], shadowSize: shadowSize)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        [upperWhiteShadowLayer, underBlackShadowLayer].forEach { layer in
            layer.frame = self.layer.bounds
            layer.cornerRadius = self.layer.cornerRadius
        }
    }
    
    public func setShadowOpacity(_ opacity: Float) {
        upperWhiteShadowLayer.shadowOpacity = opacity
        underBlackShadowLayer.shadowOpacity = opacity
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

