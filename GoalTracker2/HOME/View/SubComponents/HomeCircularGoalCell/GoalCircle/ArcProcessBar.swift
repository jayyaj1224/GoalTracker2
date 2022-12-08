//
//  ArcView.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/03/05.
//

import UIKit

class ArcProcessBar: UIView {
    var startPoint: CGFloat = 0.3
    var color: UIColor = .blueA
    var trackColor: UIColor = .crayon
    var trackWidth: CGFloat = 6
    var fillPercentage: CGFloat = 100 {
        didSet {
            switch fillPercentage {
            case ...20:
                color = .score_red
            case ...40:
                color = .score_orange
            case ...60:
                color = .score_yellow
            case ...75:
                color = .score_green
            default:
                color = .score_blue
            }
        }
    }
    
    var percentagePath: UIBezierPath!
    
    var nowPoint = UIImageView(imageName: "nowpoint.bar")
    
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.clear
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    private func getGraphStartAndEndPointsInRadians() -> (graphStartingPoint: CGFloat, graphEndingPoint: CGFloat) {
        startPoint = min(startPoint, 100)
        startPoint = max(startPoint, 0)
        
        fillPercentage = min(fillPercentage, 100)
        fillPercentage = max(fillPercentage, 0)
        
        startPoint -= 25
        
        let trueFillPercentage = fillPercentage + startPoint - 1
        
        let π: CGFloat = .pi
        
        let startPoint = ((2 * π) / 100) * (CGFloat(self.startPoint))
        let endPoint = ((2 * π) / 100) * (CGFloat(trueFillPercentage))
        
        return(startPoint, endPoint)
    }
    
    override func draw(_ rect: CGRect) {
        let center: CGPoint = CGPoint(x: rect.midX, y: rect.midY)
        let radius: CGFloat = rect.width / 2
        
        trackWidth = min(trackWidth, radius)
        trackWidth = max(trackWidth, 1)
        
        let (graphStartingPoint, graphEndingPoint) = self.getGraphStartAndEndPointsInRadians()
        
        let trackPath = UIBezierPath(arcCenter: center, radius: radius - (trackWidth / 2), startAngle: graphStartingPoint, endAngle: 2.0 * .pi, clockwise: true)
        trackPath.lineWidth = trackWidth
        self.trackColor.setStroke()
        trackPath.stroke()
        
        percentagePath = UIBezierPath(arcCenter: center, radius: radius - (trackWidth / 2), startAngle: graphStartingPoint, endAngle: graphEndingPoint, clockwise: true)
        percentagePath.lineWidth = trackWidth
        percentagePath.lineCapStyle = .square
        self.color.setStroke()
        percentagePath.stroke()

        let startPoint = UIView()
        startPoint.backgroundColor = .gray
        self.addSubview(startPoint)
        startPoint.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(trackWidth)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        var angle = graphEndingPoint
        
        switch graphEndingPoint {
        case ..<1.5:
            angle += 90.pi.cgFloat
        case 1.5...4:
            angle -= 90.pi.cgFloat
        default:
            angle += 90.pi.cgFloat
        }
        
        self.nowPoint.transform = CGAffineTransform.init(rotationAngle: ((2 * .pi) / 100) * (CGFloat(fillPercentage)))
    }   
}
