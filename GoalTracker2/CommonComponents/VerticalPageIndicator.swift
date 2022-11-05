//
//  VerticalPageIndicator.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/03/06.
//

import UIKit
import RxSwift

class VerticalPageIndicator: UIView {
    
    var indicatorStackView: UIStackView!
    
    var numberOfPages: Int = 0 {
        didSet {
            indicatorStackView.isHidden = (numberOfPages == 1)
        }
    }
    
    var indicators: [UIImageView] = []
    
    var indicatorSize: CGFloat = 12
    
    var spacing: CGFloat = 6
    
    var previousIndex: Int = -1
    
    var currentIndex: Int = 0 {
        didSet {
            guard currentIndex >= 0, currentIndex < numberOfPages else { return }
            indicators.forEach { $0.isHighlighted = false }
            indicators[currentIndex].isHighlighted = true
        }
    }
    
    convenience init() {
        self.init(frame: .zero)
        
        indicatorStackView = UIStackView()
        indicatorStackView.axis = .vertical
        indicatorStackView.spacing = spacing
        indicatorStackView.distribution = .equalSpacing
    }
    
    func set(numberOfPages: Int) {
        if self.numberOfPages != 0 {
            indicatorStackView.subviews.forEach {
                $0.removeFromSuperview()
            }
        }
        
        self.numberOfPages = numberOfPages
        
        if self.numberOfPages != 0 {
            for _ in 0...Int(numberOfPages-1) {
                let indicator = indicator()
                indicatorStackView.addArrangedSubview(indicator)
                
                addSubview(indicatorStackView)
                indicatorStackView.snp.makeConstraints { make in
                    make.width.equalTo(indicatorSize)
                    make.center.equalToSuperview()
                }
            }
        }
        currentIndex = 0
    }
    
    private func indicator() -> UIImageView {
        let indicator = UIImageView()
        indicator.image = UIImage(named: "indicator.unselected")
        indicator.highlightedImage = UIImage(named: "indicator.selected")
        indicator.snp.makeConstraints { make in
            make.size.equalTo(indicatorSize)
        }
        indicators.append(indicator)
        
        return indicator
    }
}

extension Reactive where Base: VerticalPageIndicator {
    var shouldSetPage: Binder<CGPoint> {
        Binder(base) { base, offset in
            base.currentIndex = Int((offset.y)/K.singleRowHeight)
        }
    }
}
