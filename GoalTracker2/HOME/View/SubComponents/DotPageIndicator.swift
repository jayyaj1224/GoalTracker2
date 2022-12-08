//
//  VerticalPageIndicator.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/03/06.
//

import UIKit
import RxSwift

class DotPageIndicator: UIView {
    
    var indicatorStackView: UIStackView!
    
    var indicators: [UIImageView] = []
    
    private var pageSize: CGFloat = 0
    
    private let dotSize: CGFloat = 12
    
    var numberOfPages: Int = 0
    
    var currentIndex: Int = 0
    
    convenience init(pageSize: CGFloat) {
        self.init(frame: .zero)
        
        self.pageSize = pageSize
        
        indicatorStackView = UIStackView()
        indicatorStackView.axis = .vertical
        indicatorStackView.spacing = 6
        indicatorStackView.distribution = .equalSpacing
    }
    
    func setDots(_ numberOfPages: Int) {
        removeAllDots()
        
        self.numberOfPages = numberOfPages
        
        if numberOfPages < 2 {
            indicatorStackView.isHidden = true
            return
        } else {
            indicatorStackView.isHidden = false
        }
        
        for _ in 0...Int(numberOfPages-1) {
            let dot = indicatorDot()
            indicatorStackView.addArrangedSubview(dot)
            
            addSubview(indicatorStackView)
            indicatorStackView.snp.makeConstraints { make in
                make.width.equalTo(dotSize)
                make.center.equalToSuperview()
            }
        }
    }
    
    func updateIndicators(offset: CGFloat) {
        currentIndex = Int((offset)/K.singleRowHeight)
        
        guard currentIndex >= 0, currentIndex < numberOfPages else {
            return
        }
        
        guard indicators.count > currentIndex else {
            return
        }
        
        indicators.forEach { $0.isHighlighted = false }
        indicators[currentIndex].isHighlighted = true
    }
    
    private func removeAllDots() {
        indicatorStackView.subviews.forEach { $0.removeFromSuperview() }
        indicators.removeAll()
    }
    
    private func indicatorDot() -> UIImageView {
        let indicator = UIImageView()
        indicator.image = UIImage(named: "indicator.unselected")
        indicator.highlightedImage = UIImage(named: "indicator.selected")
        indicator.snp.makeConstraints { make in
            make.size.equalTo(dotSize)
        }
        indicators.append(indicator)
        
        return indicator
    }
}

extension Reactive where Base: DotPageIndicator {
    var updateIndicators: Binder<CGFloat> {
        Binder(base) { base, offset in
            base.updateIndicators(offset: offset)
        }
    }
    
    var numberOfPages: Binder<(numberOfPages: Int, offsetY: CGFloat)> {
        Binder(base) { base, data in
            base.setDots(data.numberOfPages)
            
            base.updateIndicators(offset: data.offsetY)
        }
    }
}
