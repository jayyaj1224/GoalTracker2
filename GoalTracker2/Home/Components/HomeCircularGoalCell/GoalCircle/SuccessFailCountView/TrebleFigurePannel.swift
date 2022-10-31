//
//  DigitView.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/03/05.
//

import UIKit

class TrebleFigurePannel: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .outFit(size: 9, family: .Thin)
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    private let digitsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 1.5
        return stackView
    }()
    
    var numbers: [DigitalNumber] = []
    
    init(title: String, isFailCount: Bool=false) {
        super.init(frame: .zero)
        
        titleLabel.text = title
        
        for _ in 1...3 {
            numbers.append(DigitalNumber(isFailCount: isFailCount)   )
        }
        
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initLayout() {
        numbers.forEach { digitsStackView.addArrangedSubview($0) }
        
        [titleLabel, digitsStackView]
            .forEach { addSubview($0) }
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        digitsStackView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom)
        }
    }
    
    func setNumber(_ num: Int) {
        String(format: "%03d", num)
            .enumerated()
            .forEach { (i, numString) in
                let n = Int(String(numString))!
                self.numbers[i].set(n)
            }
        
        setNumbersAlpha(num: num)
    }
    
    private func setNumbersAlpha(num: Int) {
        switch num {
        case ...9:
            numbers[0].alpha = 0.7
            numbers[1].alpha = 0.7
            numbers[2].alpha = 1
        case 10...99:
            numbers[0].alpha = 0.7
            numbers[1].alpha = 0.7
            numbers[2].alpha = 1
        case 100...999:
            numbers[0].alpha = 1
            numbers[1].alpha = 1
            numbers[2].alpha = 1
        default:
            break
        }
    }
}

