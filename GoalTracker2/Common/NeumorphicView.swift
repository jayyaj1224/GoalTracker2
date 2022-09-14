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
class NeumorphicView: UIView {

    private let whiteUpperShadowLayer = CALayer()
    
    private let blackUnderShadowLayer = CALayer()
    
    init() {
        super.init(frame: .zero)
        
        layer.insertSublayer(whiteUpperShadowLayer, at: 0)
        layer.insertSublayer(blackUnderShadowLayer, at: 0)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    // 아래의 2가지 내용이 UIView Extension 에 들어가면 좋다
    enum NeumorphicSize {
        case small, medium, large
    }
    
    func setNeumorphicShadow(size shadowSize: NeumorphicSize) {
        switch shadowSize {
        case .small:
            setDropShadow(layer: whiteUpperShadowLayer, color: .black, width: 1, height: 1, blur: 3, spread: -1, opacity: 0.2)
            setDropShadow(layer: blackUnderShadowLayer, color: .white, width: -2, height: -2, blur: 4, spread: 0, opacity: 0.9)
        case .medium:
            setDropShadow(layer: whiteUpperShadowLayer, color: .black, width: 2, height: 2, blur: 6, spread: -2, opacity: 0.2)
            setDropShadow(layer: blackUnderShadowLayer, color: .white, width: -3.6, height: -3.6, blur: 8, spread: 0, opacity: 0.9)
        case .large:
            setDropShadow(layer: whiteUpperShadowLayer, color: .black, width: 2, height: 2, blur: 6, spread: -2, opacity: 0.2)
            setDropShadow(layer: blackUnderShadowLayer, color: .white, width: -3.6, height: -3.6, blur: 8, spread: 0, opacity: 0.9)
        }
    }
}
