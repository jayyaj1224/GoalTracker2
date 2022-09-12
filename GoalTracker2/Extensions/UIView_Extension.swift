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
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func setupShadowToDefaultLayer(alpha: Float=0.6, colour: CGColor=UIColor.gray.cgColor, rd: CGFloat=3, width: CGFloat=1.6, height: CGFloat=2.5) {
        self.layer.shadowOpacity = alpha
        self.layer.shadowColor = colour
        self.layer.shadowRadius = rd
        self.layer.shadowOffset = CGSize(width: width, height: height)
    }
}

class NeumorphismView: UIView {
    private var whiteUpperShadowLayer = CALayer()
    
    private var blackUnderShadowLayer = CALayer()
    
    private var shadowSize: ShadowSize!
    
    enum ShadowSize { case small, medium, large}
    
    init(cornerRadius: CGFloat, shadowSize: ShadowSize) {
        super.init(frame: .zero)
        
        backgroundColor = .crayon
        layer.cornerRadius = cornerRadius
        
        [whiteUpperShadowLayer, blackUnderShadowLayer]
            .forEach { self.layer.insertSublayer($0, at: 0)}
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    private func setNeuphShadowSmall() {
        layerDropShadow(layer: whiteUpperShadowLayer, color: .black, x: 1, y: 1, blur: 3, spread: -1, opacity: 0.2)
        layerDropShadow(layer: blackUnderShadowLayer, color: .white, x: -2, y: -2, blur: 4, spread: 0, opacity: 0.9)
        
        layoutNeuphShadow()
    }
    
    private  func setNeuphShadowMedium() {
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
