//
//  SuccessFailCountView.swift
//  GoalTracker2
//
//  Created by Jay Lee on 30/10/2022.
//

import UIKit

/// * size is fixed, layout location
class DigitalScoreView: UIView {
    let successCountView = DigitalTrebleFigurePannel(title: "Success")
    
    let failCountView = DigitalTrebleFigurePannel(title: "Fail", isFailCount: true)
    
    let countViewStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.spacing = 8
        return stackView
    }()
    
    private let backgroundView = NeumorphicView(backgroundColor: .crayon, shadowSize: .small)
    
    init() {
        super.init(frame: .zero)
        
        initLayout()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func set(successCount: Int, failCount: Int) {
        successCountView.setNumber(successCount)
        
        failCountView.setNumber(failCount)
    }
    
    private func initLayout() {
        let centerLine = UIView()
        centerLine.backgroundColor = .lightGray.withAlphaComponent(0.3)
        
        [backgroundView, countViewStack, centerLine]
            .forEach(addSubview)
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        countViewStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(4)
            make.height.equalTo(35)
        }
        
        centerLine.snp.makeConstraints { make in
            make.width.equalTo(0.5)
            make.bottom.equalToSuperview().inset(2)
            make.top.equalToSuperview().inset(10)
            make.centerX.equalToSuperview()
        }

        [successCountView, failCountView]
            .forEach { countViewStack.addArrangedSubview($0) }
    }
}
