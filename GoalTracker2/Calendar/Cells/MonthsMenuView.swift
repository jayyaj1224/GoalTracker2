//
//  MonthsMenuView.swift
//  GoalTracker2
//
//  Created by Jay Lee on 24/11/2022.
//

import UIKit

class MonthsMenuCollectionView: UICollectionView {
    private let monthsStringModel: [String] = [
        "January", "February", "March", "April", "May", "June", "July", "August", "September", "November", "December"
    ]
    
    init() {
        let layout = UICollectionViewFlowLayout()
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        register(MonthsMenuCell.self, forCellWithReuseIdentifier: "MonthsMenuCell")
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MonthsMenuCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        monthsStringModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MonthsMenuCell", for: indexPath) as? MonthsMenuCell else { return UICollectionViewCell() }
        
        cell.monthsLabel.text = monthsStringModel[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
}


class MonthsMenuCell: UICollectionViewCell {
    let monthsLabel: UILabel = {
        let label = UILabel()
        label.font = .sfPro(size: 14, family: .Semibold)
        label.textColor = .grayB
        return label
    }()
    
    private let underbarView: UIView = {
        let view = UIView()
        view.backgroundColor = .grayA
        return view
    }()
    
    override var isSelected: Bool {
        didSet {
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
}

extension MonthsMenuCell {
    private func layout() {
        [monthsLabel, underbarView]
            .forEach(contentView.addSubview)
        
        monthsLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        underbarView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(monthsLabel.snp.bottom).offset(10)
        }
    }
}
