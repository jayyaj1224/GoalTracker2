//
//  NeumorphicView.swift
//  GoalTracker2
//
//  Created by Lee Jong Yun on 2022/09/14.
//

import UIKit

/// UIView with Neumorphism Shadow
/// *     init(color: UIColor, shadowSize: ShadowSize)
/// *     enum NeumorphicSize { case small, medium, large }
///
class NeumorphicView: UIView {
    private let upperWhiteShadowLayer = CALayer()
    
    private let underBlackShadowLayer = CALayer()
    
    init(backgroundColor color: UIColor = .crayon, type: NeumorphicType = .medium) {
        super.init(frame: .zero)
        
        backgroundColor = color
        
        [upperWhiteShadowLayer, underBlackShadowLayer].forEach { shadowLayer in
            shadowLayer.backgroundColor = color.cgColor
            
            layer.insertSublayer(shadowLayer, at: 0)
        }

        setNeumorphicShadow(at: [upperWhiteShadowLayer, underBlackShadowLayer], type: type)
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


//MARK: -  Neumorphic View, Button
extension UIView {
    enum NeumorphicType {
        /// - size of light reflection and shadow
        case small, medium, large
        /// - no light reflection, but only shadow
        case smallShadow, mediumShadow, largeShadow
    }
    
    func setNeumorphicShadow(at layers: [CALayer], type: NeumorphicType) {
        let upperShadowLayer = layers[0], underShadowLayer = layers[1]
        
        switch type {
        case .smallShadow:
            setDropShadow(customLayer: underShadowLayer, color: .black, width: 1, height: 1, blur: 1, spread: 0, opacity: 0.4)
        case .mediumShadow:
            setDropShadow(customLayer: underShadowLayer, color: .black, width: 2, height: 2, blur: 6, spread: -0, opacity: 0.4)
        case .largeShadow:
            setDropShadow(customLayer: underShadowLayer, color: .black, width: 2.8, height: 3.8, blur: 8, spread: 0, opacity: 0.3)
        case .small:
            setDropShadow(customLayer: underShadowLayer, color: .black, width: 1, height: 1, blur: 1, spread: 0, opacity: 0.4)
            setDropShadow(customLayer: upperShadowLayer, color: .white, width: -3, height: -3, blur: 2, spread: 0, opacity: 0.8)
        case .medium:
            setDropShadow(customLayer: underShadowLayer, color: .black, width: 2, height: 2, blur: 6, spread: -0, opacity: 0.4)
            setDropShadow(customLayer: upperShadowLayer, color: .white, width: -3.6, height: -3.6, blur: 5, spread: 0, opacity: 0.9)
        case .large:
            setDropShadow(customLayer: underShadowLayer, color: .black, width: 2.8, height: 3.8, blur: 8, spread: 0, opacity: 0.3)
            setDropShadow(customLayer: upperShadowLayer, color: .white, width: -8, height: -8, blur: 8, spread: 0, opacity: 0.8)
        }
    }
}
