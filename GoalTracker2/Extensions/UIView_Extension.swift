//
//  UIView+Extension.swift
//  GoalTracker
//
//  Created by Lee Jong Yun on 2021/12/27.
//

import Foundation
import UIKit

extension UIView {
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let mask = CAShapeLayer()
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func setDropShadow(layer: CALayer?=nil, color: UIColor=UIColor.gray, width: CGFloat=1.6, height: CGFloat=2.5, blur radius: CGFloat=3, spread: CGFloat, opacity: Float) {
        let shadowLayer = layer ?? self.layer
        
        shadowLayer.shadowColor = color.cgColor
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shadowOffset = CGSize(width: width, height: height)
        shadowLayer.shadowRadius = radius / 2
        shadowLayer.masksToBounds = false
        shadowLayer.shouldRasterize = true
    }
}

extension UIView {
    enum ShadowSize {
        case small, medium, large
    }
    
    func layoutNeumorphicShadows(layers: [CALayer]) {
        layers.forEach { layer in
            layer.frame = self.layer.bounds
            layer.cornerRadius = self.layer.cornerRadius
        }
    }
    
    func setNeumorphicShadowAt(_ layers: [CALayer], shadowSize: ShadowSize) {
        let upperShadowLayer = layers[0], underShadowLayer = layers[1]
        
        switch shadowSize {
        case .small:
            setDropShadow(layer: underShadowLayer, color: .black, width: 1, height: 1, blur: 3, spread: -1, opacity: 0.2)
            setDropShadow(layer: upperShadowLayer, color: .white, width: -2, height: -2, blur: 4, spread: 0, opacity: 0.9)
        case .medium:
            setDropShadow(layer: underShadowLayer, color: .black, width: 2, height: 2, blur: 6, spread: -2, opacity: 0.4)
            setDropShadow(layer: upperShadowLayer, color: .white, width: -3.6, height: -3.6, blur: 8, spread: 0, opacity: 0.9)
        case .large:
            setDropShadow(layer: underShadowLayer, color: .black, width: 2, height: 2, blur: 6, spread: -2, opacity: 0.2)
            setDropShadow(layer: upperShadowLayer, color: .white, width: -3.6, height: -3.6, blur: 8, spread: 0, opacity: 0.9)
        }
    }
}
