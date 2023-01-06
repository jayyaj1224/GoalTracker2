//
//  ArcView.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/03/05.
//

import UIKit

class ArcProcessBar: UIView {
    let nowPointView = UIImageView(imageName: "nowpoint.bar")
    
    private var processColor: UIColor = .blueA
    
    private let trackColor: UIColor = .crayon
    
    var processPercentage: CGFloat = 100 {
        didSet {
            processPercentage = min(processPercentage, 100)
            processPercentage = max(processPercentage, 0)
            
            adjustProcessBarColor()
        }
    }
    
    init() {
        super.init(frame: .zero)
        backgroundColor = UIColor.clear
        
        setStartLine()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override func draw(_ rect: CGRect) {
        let trackPath = makeRim(rect: rect, pathPercentage: 100)
        trackColor.setStroke()
        trackPath.stroke()
        
        let processPath = makeRim(rect: rect, pathPercentage: processPercentage)
        processColor.setStroke()
        processPath.stroke()
        
        setNowPointNeumorphicView()
    }
    
    private func makeRim(rect: CGRect, pathPercentage: CGFloat) -> UIBezierPath {
        let trackWidth: CGFloat = 6.0
        
        let rim = UIBezierPath(
            arcCenter: CGPoint(x: rect.midX, y: rect.midY),
            radius: (rect.width/2.0) - (trackWidth/2.0),
            startAngle: getAngleFrom(percentage: 0),
            endAngle: getAngleFrom(percentage: pathPercentage),
            clockwise: true
        )
        rim.lineWidth = trackWidth
        rim.lineCapStyle = .square
        return rim
    }
    
    private func setNowPointNeumorphicView() {
        let percentage = adjustPercentageForGraphicPrecision(processPercentage)
        
        var rotationAngle = .pi*2.0*(percentage/100)
        
        if percentage != 100, percentage != 0 {
            rotationAngle+=0.06
        }
        
        nowPointView.transform = CGAffineTransform.init(rotationAngle: rotationAngle)
    }
    
    private func getAngleFrom(percentage: CGFloat) -> CGFloat {
        let percentage = adjustPercentageForGraphicPrecision(percentage)
        
        let graphicPrecisionAddOn = 0.03
        
        let defaultAngle = -.pi/2.0 + graphicPrecisionAddOn
        
        let percentageAngle = .pi*2.0*(percentage/100)
        
        return defaultAngle + percentageAngle
    }
    
    private func adjustPercentageForGraphicPrecision(_ percentage: CGFloat) -> CGFloat {
        if percentage > 90, percentage != 100 {
            var firstDigit = percentage-90
            firstDigit = firstDigit/9*8
            
            return 90+firstDigit
        }
        return percentage
    }
    
    private func setStartLine() {
        let startLine = UIView()
        startLine.backgroundColor = .gray
        
        self.addSubview(startLine)
        startLine.snp.makeConstraints { make in
            make.width.equalTo(1)
            make.height.equalTo(6)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
    }
    
    private func adjustProcessBarColor() {
        switch processPercentage {
        case 0:
            processColor = .score_blue
        case ...20:
            processColor = .score_red
        case ...40:
            processColor = .score_orange
        case ...60:
            processColor = .score_yellow
        case ...75:
            processColor = .score_green
        default:
            processColor = .score_blue
        }
    }
}
