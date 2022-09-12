//
//  UIButton_Extension.swift
//  GoalTracker
//
//  Created by 이종윤 on 2022/02/05.
//

import UIKit

class NeuphShadowButton: UIButton {
    var whiteUpperShadowLayer = CALayer()
    
    var blackUnderShadowLayer = CALayer()
    
    enum ShadowSize { case small, medium, large}
    
    convenience init(cornerRadius: CGFloat) {
        self.init(frame: .zero)
        self.backgroundColor = .crayon
        self.layer.cornerRadius = cornerRadius
        
        [whiteUpperShadowLayer, blackUnderShadowLayer]
            .forEach { self.layer.insertSublayer($0, at: 0)}
    }
    
    public func setNeuphShadowSmall() {
        layerDropShadow(layer: whiteUpperShadowLayer, color: .black, x: 1, y: 1, blur: 3, spread: -1, opacity: 0.2)
        layerDropShadow(layer: blackUnderShadowLayer, color: .white, x: -2, y: -2, blur: 4, spread: 0, opacity: 0.9)
        
        layoutNeuphShadow()
    }
    
    public func setNeuphShadowMedium() {
        layerDropShadow(layer: whiteUpperShadowLayer, color: .black, x: 2, y: 2, blur: 6, spread: -2, opacity: 0.2)
        layerDropShadow(layer: blackUnderShadowLayer, color: .white, x: -3.6, y: -3.6, blur: 8, spread: 0, opacity: 0.9)
        
        layoutNeuphShadow()
    }
    
    public func setNeuphShadowLarge() {
    }
    
    private func layoutNeuphShadow() {
        [whiteUpperShadowLayer, blackUnderShadowLayer]
            .forEach { layer in
                layer.frame = self.layer.bounds
                layer.cornerRadius = self.layer.cornerRadius
            }
    }
    
    private func layerDropShadow(layer: CALayer, color: UIColor, x w: CGFloat, y h: CGFloat, blur radius: CGFloat, spread: CGFloat, opacity: Float) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: w, height: h)
        layer.shadowRadius = radius / 2
        layer.masksToBounds = false
        layer.shouldRasterize = true
        layer.backgroundColor = UIColor.crayon.cgColor
    }
}
