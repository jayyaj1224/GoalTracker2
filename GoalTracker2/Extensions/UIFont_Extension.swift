//
//  UIFont+Extension.swift
//  HabitSquare
//
//  Created by Lee Jong Yun on 2021/12/14.
//

import UIKit

extension UIFont {
    enum Family: String {
        case Thin, ExtraLight, Light, Regular, Medium, Semibold, Bold, ExtraBold, Black
    }
    
    static func noto(size: CGFloat, family: Family = .Regular) -> UIFont {
        if let font = UIFont(name: "NotoSans-\(family)", size: size) {
            return font
        }
        if family == .Bold {
            return .boldSystemFont(ofSize: size)
        }
        else {
            return .systemFont(ofSize: size)
        }
    }
    
    static func sfPro(size: CGFloat, family: Family = .Regular) -> UIFont {
        if let font = UIFont(name: "SFProDisplay-\(family)", size: size) {
            return font
        }
        if family == .Bold {
            return .boldSystemFont(ofSize: size)
        }
        else {
            return .systemFont(ofSize: size)
        }
    }
    
    static func outFit(size: CGFloat, family: Family = .Regular) -> UIFont {
        if let font = UIFont(name: "Outfit-\(family)", size: size) {
            return font
        }
        if family == .Bold {
            return .boldSystemFont(ofSize: size)
        }
        else {
            return .systemFont(ofSize: size)
        }
    }
}
