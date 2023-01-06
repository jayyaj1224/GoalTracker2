//
//  SingleDigitalNumber.swift
//  GoalTracker2
//
//  Created by Jay Lee on 30/10/2022.
//

import UIKit

/// * size: CGSize(width: 42, height: 22.6)
///
class DigitalNumber: UIView {
    enum DigitBarLocation: String {
        case bottom, bottomLeft, bottomRight, middle, top, topLeft, topRight
        
        static let allCases: [DigitBarLocation] = [
            bottom, bottomLeft, bottomRight, middle, top, topLeft, topRight
        ]
    }
    
    var bars: [DigitBarLocation: UIImageView] = [:]
    
    init(isFailCount: Bool=false) {
        super.init(frame: .zero)
        
        DigitBarLocation.allCases
            .forEach { barPosition in
                let highlightedImageName = isFailCount ? "digit_\(barPosition.rawValue)_fail" : "digit_\(barPosition.rawValue)_fill"
                
                let bar = UIImageView()
                bar.image = UIImage(named: "digit_\(barPosition.rawValue)_empty")
                bar.highlightedImage = UIImage(named: highlightedImageName)
                
                addSubview(bar)
                
                bars[barPosition] = bar
                layoutDigit(at: barPosition)
            }
        
        self.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 14, height: 22.6)).priority(999)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
