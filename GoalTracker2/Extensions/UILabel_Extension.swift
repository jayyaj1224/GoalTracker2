//
//  UILabel_Extension.swift
//  GoalTracker2
//
//  Created by Jay Lee on 10/11/2022.
//

import UIKit

extension UILabel {
    func withKern(value kernValue: CGFloat = 1.15) {
        guard let text = text, !text.isEmpty else { return }
        let string = NSMutableAttributedString(string: text)
        string.addAttribute(NSAttributedString.Key.kern, value: kernValue, range: NSRange(location: 0, length: string.length - 1))
        attributedText = string
    }
}
