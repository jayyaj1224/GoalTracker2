//
//  MessageBar.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/06/12.
//

import UIKit

class MessageBar: UIView {
    private let backgroundView: NeumorphicView = {
        let view = NeumorphicView(color: .crayon, shadowSize: .medium)
        view.layer.cornerRadius = 7
        return view
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .sfPro(size: 14, family: .Regular)
        return label
    }()
    
    enum NoticeColor {
        case blue, orange
    }
    
    enum MessageEmoji {
        case smileFace, clap, sunRise, moon, warning
        
        var string: String {
            switch self {
            case .smileFace:
                return "􀎸"
            case .clap:
                return "􀲯"
            case .sunRise:
                return "􀻟"
            case .moon:
                return "􀇀"
            case .warning:
                return "􀇿"
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        layer.cornerRadius = 7
        clipsToBounds = false
        
        layoutMessageBar()
    }
    
    public func message(_ text: String, color: NoticeColor, emoji: MessageEmoji) {
        messageLabel.text = emoji.string + " " + text
        
        switch color {
        case .blue:
            messageLabel.textColor = .blueB
        case .orange:
            messageLabel.textColor = .orangeB
        }
    }
    
    private func layoutMessageBar()  {
        [backgroundView, messageLabel]
            .forEach { addSubview($0) }
        
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(18)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
