//
//  MessageBar.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/06/12.
//

import UIKit

class MessageBar: NeumorphicView {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .sfPro(size: 14, family: .Regular)
        return label
    }()
    
    init() {
        super.init(color: .crayon, shadowSize: .medium)
        layer.cornerRadius = 12
        
        layoutMessageBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func mock_setMessage() {
        messageLabel.text = "􀦅 You are the king of self-control!"
        messageLabel.textColor = .blueB
    }
    
    private func layoutMessageBar()  {
        addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(18)
            make.centerY.equalToSuperview()
        }
    }
}
