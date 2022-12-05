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
    
    func setDropShadow(customLayer: CALayer?=nil, color: UIColor=UIColor.gray, width: CGFloat=1.6, height: CGFloat=2.5, blur radius: CGFloat=3, spread: CGFloat, opacity: Float) {
        let shadowLayer = customLayer ?? self.layer
        
        shadowLayer.shadowColor = color.cgColor
        shadowLayer.shadowOpacity = opacity
        shadowLayer.shadowOffset = CGSize(width: width, height: height)
        shadowLayer.shadowRadius = radius / 2
        shadowLayer.masksToBounds = false
        shadowLayer.shouldRasterize = true
        
        if spread == 0 {
            shadowLayer.shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowLayer.shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}
