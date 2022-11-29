//
//  FlapScoreView.swift
//  GoalTracker2
//
//  Created by Jay Lee on 08/11/2022.
//

import UIKit

class FlapScoreView: UIView {
    private let scoreFrameImageView = UIImageView(imageName: "scorePannel.flap")
    
    private let successScoreLabel: UILabel = {
        let label = UILabel()
        label.text = "000"
        label.textAlignment = .center
        label.textColor = .black.withAlphaComponent(0.8)
        label.font = .sfPro(size: 19, family: .Bold)
        label.withKern(value: -0.8)
        return label
    }()
    
    private let failScoreLabel: UILabel = {
        let label = UILabel()
        label.text = "000"
        label.textAlignment = .center
        label.textColor = .black.withAlphaComponent(0.6)
        label.font = .sfPro(size: 19, family: .Bold)
        label.withKern(value: -0.8)
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setScore(success: Int, fail: Int) {
        successScoreLabel.text = "\(success)"
        failScoreLabel.text = "\(fail)"
    }
    
    private func layout() {
        self.snp.makeConstraints { make in
            let ratio = 61.0/124.0
            make.width.equalTo(120)
            make.height.equalTo(Int(120*ratio))
        }
        
        [scoreFrameImageView, successScoreLabel, failScoreLabel]
            .forEach(addSubview(_:))
        
        scoreFrameImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        successScoreLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-25.1)
            make.centerY.equalToSuperview().offset(5)
        }
        
        failScoreLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(25.5)
            make.centerY.equalToSuperview().offset(5)
        }
    }
}
