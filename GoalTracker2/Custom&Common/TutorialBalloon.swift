//
//  TutorialBalloon.swift
//  GoalTracker2
//
//  Created by Jay Lee on 08/01/2023.
//

import Foundation
import UIKit

class TutorialBalloon: NeumorphicView {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .noto(size: 15, family: .Semibold)
        label.textColor = .white
        return label
    }()
    
    private var balloonTail: BalloonTail!
    
    private var tailPosition: TailPosition = .right
    
    private var time: CGFloat = 3.0
    
    private var balloonColor: UIColor = .blueC
    
    private let dismissButton = UIButton()
    
    enum TailPosition {
        case top, bottom, left, right
    }
    
    private init() {
        super.init(backgroundColor: balloonColor, type: .mediumShadow)
        clipsToBounds = false
        layer.cornerRadius = 10
        
        dismissButton.addTarget(self, action: #selector(dismissAnimation), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func make(message: String, tailPosition: TailPosition, time: CGFloat=3.0, locate: (TutorialBalloon)->Void) -> TutorialBalloon {
        let balloon = TutorialBalloon()
        
        balloon.setMessage(message)
        balloon.setTail(at: tailPosition)
        balloon.layout()
        
        locate(balloon)
        
        balloon.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        
        return balloon
    }
    
    func show() {
        DispatchQueue.main.async {
            self.presentAnimation()
        }
    }
    
    private func presentAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1) {
            self.transform = .identity
        } completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now()+4) {
                self.dismissAnimation()
            }
        }
    }
    
    @objc private func dismissAnimation() {
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1) {
            self.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    private class BalloonTail: UIView {
        var balloonColor: UIColor
        var position: TutorialBalloon.TailPosition
        
        init(color: UIColor, position: TutorialBalloon.TailPosition) {
            self.balloonColor = color
            self.position = position
            
            super.init(frame: .zero)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func draw(_ rect: CGRect) {
            let trianglePath = makeTrianglePath(rect: rect, at: position)
            trianglePath.close()
            
            let triangleLayer = CAShapeLayer()
            triangleLayer.path = trianglePath.cgPath
            triangleLayer.fillColor = balloonColor.cgColor
            triangleLayer.shadowPath = trianglePath.cgPath
            setShadowIfNeeded(at: triangleLayer, at: position)
            
            
            self.layer.addSublayer(triangleLayer)
        }
        
        private func makeTrianglePath(rect: CGRect, at position: TutorialBalloon.TailPosition) -> UIBezierPath {
            let trianglePath = UIBezierPath()
            switch position {
            case .top:
                trianglePath.move(to: CGPoint(x: rect.midX, y: rect.minY))
                trianglePath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                trianglePath.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            case .bottom:
                trianglePath.move(to: CGPoint(x: rect.midX, y: rect.maxY))
                trianglePath.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
                trianglePath.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
            case .left:
                trianglePath.move(to: CGPoint(x: rect.minX, y: rect.midY))
                trianglePath.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                trianglePath.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
            case .right:
                trianglePath.move(to: CGPoint(x: rect.maxX, y: rect.midY))
                trianglePath.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
                trianglePath.addLine(to: CGPoint(x: rect.minX, y: rect.minX))
            }
            return trianglePath
        }
        
        private func setShadowIfNeeded(at layer: CAShapeLayer, at position: TutorialBalloon.TailPosition) {
            switch position {
            case .bottom, .right:
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOpacity = 0.4
                layer.shadowRadius = 1
                layer.shadowOffset = CGSize(width: 1.5, height: 1.5)
                layer.masksToBounds = false
                layer.shouldRasterize = true
            default:
                break
            }
        }
    }
}

extension TutorialBalloon {
    private func setMessage(_ message: String) {
        messageLabel.text = message
    }
    
    private func setTail(at position: TailPosition) {
        balloonTail = BalloonTail(color: balloonColor, position: position)
        tailPosition = position
    }
    
    private func layout() {
        [messageLabel, balloonTail, dismissButton]
            .forEach(addSubview)
        
        messageLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(10)
            make.leading.trailing.equalToSuperview().inset(15)
        }
        
        balloonTail.snp.makeConstraints { make in
            make.size.equalTo(14)
        }
        
        switch tailPosition {
        case .top:
            balloonTail.snp.makeConstraints { make in
                make.bottom.equalTo(self.snp.top).offset(1)
                make.centerX.equalToSuperview()
            }
        case .bottom:
            balloonTail.snp.makeConstraints { make in
                make.top.equalTo(self.snp.bottom).offset(-1)
                make.centerX.equalToSuperview()
            }
        case .left:
            balloonTail.snp.makeConstraints { make in
                make.trailing.equalTo(self.snp.leading).offset(1)
                make.centerY.equalToSuperview().offset(2)
            }
        case .right:
            balloonTail.snp.makeConstraints { make in
                make.leading.equalTo(self.snp.trailing).offset(-1)
                make.centerY.equalToSuperview().offset(2)
            }
        }
        
        dismissButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
