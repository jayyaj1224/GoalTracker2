//
//  TouchThrough.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/02/21.
//

import UIKit

class TouchThroughView: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        let members = subviews.reversed()
        for member in members {
            let subPoint = member.convert(point, to: self)
            guard let result = member.hitTest(subPoint, with: event) else {
                continue
            }
            return result
        }
        return nil
    }
}

class MainDimView: TouchThroughView {
    
    let gradient = CAGradientLayer()
    
    var reverse: Bool = false
    
    convenience init(reverse: Bool) {
        self.init(frame: .zero)
        self.reverse = reverse
    }
    
    override public func draw(_ rect: CGRect) {
        var colors: [UIColor] = [.crayon.withAlphaComponent(0.7), .crayon.withAlphaComponent(0)]
        var locations: [NSNumber] = [0.6, 1]
        
        if reverse {
            colors.reverse()
            locations = [0, 0.4]
        }

        gradient.colors = colors.map { $0.cgColor }
        gradient.locations = locations
        gradient.frame = self.bounds
        gradient.startPoint = CGPoint(x: 0.5, y: 0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1)
        if gradient.superlayer == nil {
            layer.insertSublayer(gradient, at: 0)
        }
    }
}
