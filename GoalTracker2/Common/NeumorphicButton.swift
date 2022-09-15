//
//  NeumorphicView.swift
//  GoalTracker2
//
//  Created by Lee Jong Yun on 2022/09/14.
//

import UIKit

/// UIView with Neumorphism Shadow
/// *     enum NeumorphicSize { case small, medium, large }
/// *     func setNeumorphicShadow(size shadowSize: NeumorphicSize)
///
class NeumorphicButton: UIButton {
    private var neumorphicShadowLayers: [CALayer]!
    
    override private init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(color: UIColor, shadowSize: ShadowSize) {
        self.init(frame: .zero)
        backgroundColor = .crayon
        
        var shadowLayer: CALayer {
            let shadowLayer = CALayer()
            shadowLayer.backgroundColor = color.cgColor
            
            layer.insertSublayer(shadowLayer, at: 0)
            
            return shadowLayer
        }
        
        neumorphicShadowLayers = [CALayer](repeating: shadowLayer, count: 2)
        
        setNeumorphicShadowAt(neumorphicShadowLayers, shadowSize: .medium)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutNeumorphicShadows(layers: neumorphicShadowLayers)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

