//
//  MessageBar.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/06/12.
//

import UIKit

class MessageBar: NeumorphicButton {
    private let keyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "key.fill.neumorphism")
        return imageView
    }()
    
    private let keyNoteLabel: UILabel = {
        let label = UILabel()
        label.attributedText = NSMutableAttributedString(
            string: "KeyNote",
            attributes: [
                NSMutableAttributedString.Key.font: UIFont.outFit(size: 11, family: .Medium),
                NSMutableAttributedString.Key.kern: -0.75,
                NSMutableAttributedString.Key.foregroundColor: UIColor.black
            ]
        )
        return label
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = .outFit(size: 16, family: .Light)
        label.numberOfLines = 0
        label.textColor = .grayC
        return label
    }()
    
    var userNotes: [UserNote] = []
    
    init(neumorphicType: NeumorphicType = .large) {
        super.init(color: .crayon, type: neumorphicType)
        layer.cornerRadius = 18
        
        layoutMessageBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setGoalEmptyMessage() {
        messageLabel.text = "Please add goal to track."
    }
    
    func setNewGoalPlaceHolderMessage() {
        messageLabel.text = "You can set a key-note here."
    }
    
    func configure(with userNotes: [UserNote]) {
        self.userNotes = userNotes
        
        if let firstNote = userNotes.first, firstNote.isKeyNote {
            messageLabel.text = firstNote.note
            messageLabel.textColor = .black
        } else {
            messageLabel.text = "No key-note"
            messageLabel.textColor = .grayB
        }
    }
    
    private func layoutMessageBar()  {
        [keyImageView, keyNoteLabel, messageLabel]
            .forEach(addSubview)
        
        keyImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(12)
            make.centerY.equalToSuperview()
            make.size.equalTo(26)
        }
        
        keyNoteLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(10)
            make.top.equalToSuperview().inset(7)
        }
        
        messageLabel.snp.makeConstraints { make in
            make.leading.equalTo(keyImageView.snp.trailing).offset(12)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().inset(10)
        }
    }
}
