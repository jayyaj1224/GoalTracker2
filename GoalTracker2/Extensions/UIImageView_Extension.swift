//
//  UIImageView_Extension.swift
//  GoalTracker2
//
//  Created by Jay Lee on 30/10/2022.
//

import UIKit

extension UIImageView {
    
    convenience init(imageName: String) {
        self.init(frame: .zero)
        
        image = UIImage(named: imageName)
    }
}
