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
        shadowLayer.backgroundColor = UIColor.white.cgColor
        
        if layer != nil {
            shadowLayer.frame = self.layer.bounds
            shadowLayer.cornerRadius = self.layer.cornerRadius
        }
    }
}

//
//extension UIView where Self: Neumorphic {
//    enum NeumorphicSize {
//        case small, medium, large
//    }
//
//    func insertNeumorphicShadow(size shadowSize: NeumorphicSize, whiteShadowLayer: CALayer, blackShadowLayer: CALayer) {
//        switch shadowSize {
//        case .small:
//            setDropShadow(layer: whiteShadowLayer, color: .black, width: 1, height: 1, blur: 3, spread: -1, opacity: 0.2)
//            setDropShadow(layer: blackShadowLayer, color: .white, width: -2, height: -2, blur: 4, spread: 0, opacity: 0.9)
//        case .medium:
//            setDropShadow(layer: whiteShadowLayer, color: .black, width: 2, height: 2, blur: 6, spread: -2, opacity: 0.2)
//            setDropShadow(layer: blackShadowLayer, color: .white, width: -3.6, height: -3.6, blur: 8, spread: 0, opacity: 0.9)
//        case .large:
//            setDropShadow(layer: whiteShadowLayer, color: .black, width: 2, height: 2, blur: 6, spread: -2, opacity: 0.2)
//            setDropShadow(layer: blackShadowLayer, color: .white, width: -3.6, height: -3.6, blur: 8, spread: 0, opacity: 0.9)
//        }
//    }
//}



//protocol Neumorphic where Self: UIView {
//    var shadowLayers: [CALayer] { get }
//    func setNeumorphicShadow(size: NeumorphicSize)
//}
//
//extension UIView: Neumorphic {
//    enum NeumorphicSize {
//        case small, medium, large
//    }
//
//    var shadowLayers: [CALayer] {
//        return [CALayer](repeating: CALayer(), count: 2)
//    }
//    var shadowLayers: [CALayer] {
//        var neumorpicLayers = layer
//            .sublayers?
//            .filter { $0.name == "neumorpic_layer" }
//
//        switch neumorpicLayers {
//        case let layers where layers == nil:
//            neumorpicLayers = []
//            fallthrough
//        case let layers where layers!.isEmpty:
//            return [CALayer](repeating: CALayer(), count: 2)
//                .compactMap { layer in
//                    layer.name = "neumorpic_layer"
//                    return layer
//                }
//        case let layers:
//            return layers!
//        }
//    }

//    func setNeumorphicShadow(size shadowSize: NeumorphicSize) {
//        
//        var neumorphicShadowLayers = layer
//            .sublayers?
//            .filter { $0.name == "neumorpic_layer" } ?? []
//        
//        if neumorphicShadowLayers.isEmpty {
//            neumorphicShadowLayers = [CALayer](repeating: CALayer(), count: 2)
//                .compactMap({ layer in
//                    layer.name = ""
//                    return layer
//                })
//            //{ $0.name = "neumorpic_layer" }
//        }
//            
//        
//        
//
//        whiteUpperShadowLayer.name = "neumorpic_layer"
//        blackUnderShadowLayer.name = "neumorpic_layer"
//
//        switch shadowSize {
//        case .small:
//            setDropShadow(layer: whiteUpperShadowLayer, color: .black, width: 1, height: 1, blur: 3, spread: -1, opacity: 0.2)
//            setDropShadow(layer: blackUnderShadowLayer, color: .white, width: -2, height: -2, blur: 4, spread: 0, opacity: 0.9)
//        case .medium:
//            setDropShadow(layer: whiteUpperShadowLayer, color: .black, width: 2, height: 2, blur: 6, spread: -2, opacity: 0.2)
//            setDropShadow(layer: blackUnderShadowLayer, color: .white, width: -3.6, height: -3.6, blur: 8, spread: 0, opacity: 0.9)
//        case .large:
//            setDropShadow(layer: whiteUpperShadowLayer, color: .black, width: 2, height: 2, blur: 6, spread: -2, opacity: 0.2)
//            setDropShadow(layer: blackUnderShadowLayer, color: .white, width: -3.6, height: -3.6, blur: 8, spread: 0, opacity: 0.9)
//        }
//
//        layer.insertSublayer(whiteUpperShadowLayer, at: 0)
//        layer.insertSublayer(blackUnderShadowLayer, at: 0)
//    }
//}
