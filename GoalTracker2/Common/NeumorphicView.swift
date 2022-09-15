//
//  NeumorphicView.swift
//  GoalTracker2
//
//  Created by Lee Jong Yun on 2022/09/14.
//

import UIKit

class Neumorphic {
    
}

/// UIView with Neumorphism Shadow
/// *     enum NeumorphicSize { case small, medium, large }
/// *     func setNeumorphicShadow(size shadowSize: NeumorphicSize)
///
class NeumorphicView: UIView {
    enum ShadowSize {
        case small, medium, large
    }
    
    private let whiteUpperShadowLayer = CALayer()
    private let blackUnderShadowLayer = CALayer()
    
    init(shadowSize: ShadowSize) {
        super.init(frame: .zero)
        
        layer.insertSublayer(whiteUpperShadowLayer, at: 0)
        layer.insertSublayer(blackUnderShadowLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutNeumorphicShadows()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layoutNeumorphicShadows() {
        [whiteUpperShadowLayer, blackUnderShadowLayer]
            .forEach { layer in
                layer.frame = self.layer.bounds
                layer.cornerRadius = self.layer.cornerRadius
            }
    }

    private func setNeumorphicShadow(shadowSize: ShadowSize, whiteShadowLayer: CALayer, blackShadowLayer: CALayer) {
        switch shadowSize {
        case .small:
            setDropShadow(layer: whiteShadowLayer, color: .black, width: 1, height: 1, blur: 3, spread: -1, opacity: 0.2)
            setDropShadow(layer: blackShadowLayer, color: .white, width: -2, height: -2, blur: 4, spread: 0, opacity: 0.9)
        case .medium:
            setDropShadow(layer: whiteShadowLayer, color: .black, width: 2, height: 2, blur: 6, spread: -2, opacity: 0.2)
            setDropShadow(layer: blackShadowLayer, color: .white, width: -3.6, height: -3.6, blur: 8, spread: 0, opacity: 0.9)
        case .large:
            setDropShadow(layer: whiteShadowLayer, color: .black, width: 2, height: 2, blur: 6, spread: -2, opacity: 0.2)
            setDropShadow(layer: blackShadowLayer, color: .white, width: -3.6, height: -3.6, blur: 8, spread: 0, opacity: 0.9)
        }
    }
}
