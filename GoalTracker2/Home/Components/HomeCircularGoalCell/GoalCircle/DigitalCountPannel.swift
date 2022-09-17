//
//  DigitView.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/03/05.
//

import UIKit

class DigitalCountPannel: UIStackView {
    
    var numbers: [SingleDigit] = []
    
    let size = CGSize(width: 42, height: 22.6)
    
    convenience init(digitCount: Int, failDigit: Bool=false) {
        self.init(frame: .zero)
        self.axis = .horizontal
        self.distribution = .equalSpacing
        self.spacing = 1.5
        
        for _ in 1...digitCount {
            let singleDigit = SingleDigit(failDigit: failDigit)
            
            numbers.append(singleDigit)
            
            self.addArrangedSubview(singleDigit.view)
            singleDigit.view.snp.makeConstraints { make in
                make.width.equalTo(singleDigit.size.width).priority(999)
            }
        }
    }
    
    func setNumber(_ num: Int, failDigit: Bool=false) {
        switch num {
        case ...9:
            numbers[0].view.alpha = 0.7
            numbers[1].view.alpha = 0.7
            numbers[2].view.alpha = 1
        case 10...99:
            numbers[0].view.alpha = 0.7
            numbers[1].view.alpha = 0.7
            numbers[2].view.alpha = 1
        case 100...999:
            numbers[0].view.alpha = 1
            numbers[1].view.alpha = 1
            numbers[2].view.alpha = 1
        default:
            break
        }
        
        String(format: "%03d", num)
            .enumerated()
            .forEach { (i, numString) in
                let n = Int(String(numString))!
                self.numbers[i].set(n)
            }
    }
}


class SingleDigit {
    let view = UIView()
    
    var bars: [DigitBarLocation: UIImageView] = [:]
    
    let size = CGSize(width: 13, height: 22.6)
    
    init(failDigit: Bool=false) {
        DigitBarLocation.allCases
            .forEach { barPosition in
                let bar = UIImageView()
                bar.image = UIImage(named: "digit_\(barPosition.string)_empty")
                if failDigit {
                    bar.highlightedImage = UIImage(named: "digit_\(barPosition.string)_fail")
                } else {
                    bar.highlightedImage = UIImage(named: "digit_\(barPosition.string)_fill")
                }
                bar.tag = barPosition.rawValue
                bars[barPosition] = bar
                
                view.addSubview(bar)
                layoutDigit(at: barPosition)
            }
    }
    
    func set(_ number: Int) {
        DigitBarLocation.allCases
            .forEach {
                bars[$0]?.isHighlighted = false
            }
        
        var highlightBars: [DigitBarLocation] = []
        
        switch number {
        case 0:
            highlightBars = DigitBarLocation.allCases.filter { $0 != .middle }
        case 1:
            highlightBars = [.topRight, .bottomRight]
        case 2:
            highlightBars = [.top, .topRight, .middle, .bottomLeft, .bottom]
        case 3:
            highlightBars = [.top, .bottomRight, .topRight, .middle, .bottom]
        case 4:
            highlightBars = [.topLeft, .topRight, .middle, .bottomRight]
        case 5:
            highlightBars = [.top, .topLeft, .middle, .bottomRight, .bottom]
        case 6:
            highlightBars = [.top, .topLeft, .middle, .bottomRight, .bottom]
        case 7:
            highlightBars = [.top, .topRight, .bottomRight]
        case 8:
            highlightBars = DigitBarLocation.allCases
        case 9:
            highlightBars = DigitBarLocation.allCases.filter { $0 != .bottomLeft }
        default:
            return
        }
        
        highlightBars.forEach { position in
            if let barImageView = bars[position] {
                barImageView.isHighlighted = true
            }
        }
    }
    
    private func layoutDigit(at position: DigitBarLocation) {
        guard let bar = bars[position] else { return }
        
        var size: CGSize = .zero
        switch position {
        case .bottom, .top:
            size = CGSize(width: 11.38, height: 3.57)
        case .bottomLeft, .bottomRight, .topLeft, .topRight:
            size = CGSize(width: 3.57, height: 10.4)
        case .middle:
            size = CGSize(width: 10.07, height: 3.9)
        }
        bar.snp.makeConstraints { make in
            make.size.equalTo(size)
        }
        
        switch position {
        case .bottom:
            bar.snp.makeConstraints { make in
                make.bottom.equalToSuperview()
                make.trailing.equalToSuperview().offset(-0.4)
            }
        case .bottomLeft:
            bar.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-1.3)
                make.leading.equalToSuperview()
            }
        case .bottomRight:
            bar.snp.makeConstraints { make in
                make.bottom.equalToSuperview().offset(-1.3)
                make.trailing.equalToSuperview()
            }
        case .middle:
            bar.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset(-1.3)
                make.bottom.equalToSuperview().offset(-9.43)
            }
        case .top:
            bar.snp.makeConstraints { make in
                make.top.equalToSuperview()
                make.trailing.equalToSuperview().offset(-0.65)
            }
        case .topLeft:
            bar.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(1.1)
                make.leading.equalToSuperview()
            }
        case .topRight:
            bar.snp.makeConstraints { make in
                make.top.equalToSuperview().offset(0.3)
                make.trailing.equalToSuperview()
            }
        }
    }
}

enum DigitBarLocation: Int {
    case bottom, bottomLeft, bottomRight, middle, top, topLeft, topRight
    
    static let allCases: [DigitBarLocation] = [
        bottom, bottomLeft, bottomRight, middle, top, topLeft, topRight
    ]
    
    var string: String {
        switch self {
        case .bottom:
            return "bottom"
        case .bottomLeft:
            return "bottomLeft"
        case .bottomRight:
            return "bottomRight"
        case .middle:
            return "middle"
        case .top:
            return "top"
        case .topLeft:
            return "topLeft"
        case .topRight:
            return "topRight"
        }
    }
}

