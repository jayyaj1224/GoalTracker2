//
//  UserNoteCell.swift
//  GoalTracker2
//
//  Created by Jay Lee on 02/12/2022.
//

import UIKit
import RxSwift
import RxCocoa

class UserNoteCell: UITableViewCell {
    private let keyImageView = UIImageView(imageName: "key.fill.neumorphism")
    
    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    private let noteLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        return label
    }()
    
    var isKeyNote = false
    
    var reuseBag = DisposeBag()
    
    public var pinButtonTappedAtSignal: Signal<Int>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.backgroundColor = .crayon
        
        layout()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        reuseBag = DisposeBag()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with userNote: UserNote, at row: Int) {
        noteLabel.text = userNote.note
        isKeyNote = userNote.isKeyNote
        
        if userNote.isKeyNote {
            noteLabel.font = .outFit(size: 16, family: .Regular)
            noteLabel.textColor = .black
            keyImageView.isHidden = false
        } else {
            noteLabel.font = .outFit(size: 16, family: .Regular)
            noteLabel.textColor = .grayC
            keyImageView.isHidden = true
        }
    }
    
    private func layout() {
        [contentStackView]
            .forEach(contentView.addSubview)
        
        contentStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(22)
            make.top.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(24)
            make.trailing.equalToSuperview().inset(10)
        }
        
        [keyImageView, noteLabel]
            .forEach(contentStackView.addArrangedSubview)
        
        keyImageView.snp.makeConstraints { make in
            make.size.equalTo(26)
        }
    }
}
