//
//  MonthsMenuCell.swift
//  GoalTracker2
//
//  Created by Jay Lee on 25/11/2022.
//

import UIKit

class MonthsMenuCell: UICollectionViewCell {
    let monthsLabel: UILabel = {
        let label = UILabel()
        label.font = .sfPro(size: 14, family: .Semibold)
        label.textColor = .grayB
        label.textAlignment = .center
        return label
    }()
    
    private let underbarView: UIView = {
        let view = UIView()
        view.backgroundColor = .grayA
        view.isHidden = true
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
            layoutUnderbarIfNeeded()
            
            monthsLabel.textColor = self.isSelected ? .black : .grayB
            underbarView.isHidden = self.isSelected ? false : true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(monthsString: String) {
        monthsLabel.text = monthsString
        
        layoutUnderbarIfNeeded()
    }
    
    private func layoutUnderbarIfNeeded() {
        guard isSelected else { return }
        
        let monthString = monthsLabel.text ?? ""
        let font = UIFont.sfPro(size: 14, family: .Semibold)
        let rect = monthString.boundingRect(
            with: CGSize(width: .min, height: .min),
            options: .usesLineFragmentOrigin,
            attributes: [NSAttributedString.Key.font:font], context: nil
        )

        underbarView.snp.remakeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
            make.width.equalTo(rect.width+10)
            make.height.equalTo(1)
        }
    }
    
    private func layout() {
        [monthsLabel, underbarView]
            .forEach(contentView.addSubview)
        
        monthsLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
