//
//  UIImage+Extension.swift
//  HabitSquare
//
//  Created by Lee Jong Yun on 2021/12/17.
//

import Foundation
import UIKit

public extension UIImage {
    convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

extension UIImageView {
    convenience init(imageName: String) {
        self.init()
        let image = UIImage(named: imageName) ?? UIImage(systemName: imageName)
        self.image = image
    }
}