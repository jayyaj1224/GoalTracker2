//
//  CalendarGoalCell.swift
//  GoalTracker2
//
//  Created by Jay Lee on 25/11/2022.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class GoalMonthlyCell: UITableViewCell {
    private let goalTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .sfPro(size: 14, family: .Medium)
        label.numberOfLines = 3
        label.minimumScaleFactor = 0.5
        return label
    }()

    private let goalTitleSubLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayC
        label.font = .sfPro(size: 12, family: .Medium)
        label.alpha = 0
        label.textAlignment = .center
        return label
    }()
    
    
    private let daysCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 22, height: 32)
        layout.minimumLineSpacing = 3
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.register(GoalMonthlyTileCell.self, forCellWithReuseIdentifier: "GoalMonthlyTileCell")
        cv.contentInset = UIEdgeInsets(top: 0, left: 180, bottom: 0, right: 30)
        cv.backgroundColor = .clear
        cv.showsHorizontalScrollIndicator = false
        
        return cv
    }()
    
    private let daysInMonthRelay: BehaviorRelay<[Day]> = BehaviorRelay(value: [])
    
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .crayon
        
        layout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        DispatchQueue.main.async {
            self.daysCollectionView.setContentOffset(CGPoint(x: -172, y: 0), animated: false)
        }
        
        DispatchQueue.main.async {
            self.daysCollectionView.setContentOffset(CGPoint(x: -185, y: 0), animated: true)
        }
    }
    
    func configure(goalMonthly: GoalMonthlyViewModel) {
        daysInMonthRelay.accept(goalMonthly.days)
        
        let title = goalMonthly.title.filter { !$0.isNewline }
        
        goalTitleLabel.text = title
        goalTitleSubLabel.text = title
    }
    
    private func bind()  {
        daysInMonthRelay
            .bind(to: daysCollectionView.rx.items) { collectionView, row, day in
                guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GoalMonthlyTileCell", for: IndexPath(row: row, section: 0)) as? GoalMonthlyTileCell else { return UICollectionViewCell() }

                cell.configure(day: day)
                
                return cell
            }
            .disposed(by: disposeBag)
        
        daysCollectionView.rx.didScroll
            .subscribe(onNext: { [weak self] _ in
                let x = self?.daysCollectionView.contentOffset.x ?? 0
                
                switch x {
                case ...(-150):
                    self?.goalTitleLabel.alpha = 1
                    self?.goalTitleSubLabel.alpha = 0
                case (-151)...(-30):
                    self?.goalTitleLabel.alpha = 1 - (x+151)/100
                    self?.goalTitleSubLabel.alpha = (x+151)/100
                default:
                    self?.goalTitleLabel.alpha = 0
                    self?.goalTitleSubLabel.alpha = 1
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func layout() {
        [goalTitleLabel, goalTitleSubLabel, daysCollectionView]
            .forEach(contentView.addSubview)
        
        goalTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.centerY.equalTo(daysCollectionView)
            make.width.equalTo(156)
        }
        
        goalTitleSubLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(240)
            make.bottom.equalToSuperview()
        }
        
        daysCollectionView.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalTo(goalTitleSubLabel.snp.top)
        }
    }
}
