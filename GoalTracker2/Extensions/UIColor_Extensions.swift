//
//  UIColorExtensions.swift
//  GoalTracker2
//
//  Created by Jay Lee on 12/09/2022.
//

import UIKit

extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        let hexString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.currentIndex = scanner.string.index(after: scanner.currentIndex)
        }
        var color: UInt64 = 0
        scanner.scanHexInt64(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    
    //MARK: - Colors
    /*
     Brighter < ----- > Darker
        A     B,C,D       E
     
     */
    
    static let crayon = UIColor(hex: "F2F4FA")
    // Consider: "EDEFF1")  F6F6F6 FBFBFB  F2F4FA
    
    static let redA = UIColor(hex: "F04D4E")
    
    static let orangeA = UIColor(hex: "CE8F56")
//    static let orangeB = UIColor(hex: "CE8F56")
    
    static let blueA = UIColor(hex: "C7D2DE")
    static let blueB = UIColor(hex: "6E8EB7")
    
    static let grayA = UIColor(hex: "D9D9D9")
    static let grayB = UIColor(hex: "909090")
    static let grayC = UIColor(hex: "626262")
    
    static let dimA = UIColor.black.withAlphaComponent(0.4)
    static let dimB = UIColor.black.withAlphaComponent(0.6)
    static let dimC = UIColor.black.withAlphaComponent(0.8)
    
    static let score_blue = UIColor(hex: "C3CDDA")
    static let score_green = UIColor(hex: "A6D2C8")
    static let score_yellow = UIColor(hex: "E3DA8A")
    static let score_orange = UIColor(hex: "E9AE77")
    static let score_red = UIColor(hex: "FF5555")
}

