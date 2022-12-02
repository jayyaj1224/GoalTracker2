//
//  UserNoteCell.swift
//  GoalTracker2
//
//  Created by Jay Lee on 02/12/2022.
//

import UIKit

class UserNoteCell: UITableViewCell {
    private let noteLabel: UILabel = {
        let label = UILabel()
        label.font = .sfPro(size: 14, family: .Medium)
        label.textColor = .grayC
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with userNote: UserNote) {
        noteLabel.text = userNote.note
    }
    
    private func layout() {
        [noteLabel]
            .forEach(contentView.addSubview(_:))
        
        noteLabel.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(25)
            make.top.equalToSuperview().inset(30)
            make.bottom.equalToSuperview().inset(20)
        }
    }
    
    
    
}
