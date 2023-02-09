//
//  YearSelectViewController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 26/11/2022.
//

import UIKit
import RxSwift
import RxCocoa

class YearSelectViewController: UIViewController {
    // UI Components
    private let yearSelectView: UIView = {
        let view = NeumorphicView(backgroundColor: .crayon, type: .mediumShadow)
        view.layer.cornerRadius = 10
        return view
    }()
    
    private let yearSelectCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: 60, height: 20)
        layout.minimumLineSpacing = 10
        
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = .clear
        cv.isScrollEnabled = false
        cv.register(YearSelectCell.self, forCellWithReuseIdentifier: "YearSelectCell")
        
        return cv
    }()
    
    private let backGroundView = UIView()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        button.configuration = UIButton.Configuration.plain()
        button.configuration?.image = UIImage(named: "x.neumorphism")?.withAlignmentRectInsets(UIEdgeInsets(top: -4, left: -4, bottom: -4, right: -4))
        return button
    }()
    
    // Logic
    var minYear: Int = 0
    var maxYear: Int = 0
    
    var selectedYear = ""
    
    let yearSelectedSubject = PublishSubject<String>()
    
    init(goals: [Goal]) {
        super.init(nibName: nil, bundle: nil)
        
        let thisYear = Calendar.current.component(.year, from: Date())
        var minDate = "\(thisYear)", maxDate = "\(thisYear)"
        
        goals.forEach { goal in
            minDate = min(minDate, goal.startDate)
            maxDate = max(maxDate, goal.endDate)
        }
        
        let minYear = String(minDate.prefix(4))
        let maxYear = String(maxDate.prefix(4))
        
        self.minYear = Int(minYear) ?? thisYear
        self.maxYear = Int(maxYear) ?? thisYear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialUiSetting()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewDidAppearAnimate()
    }
    
    private func viewDidAppearAnimate() {
        UIView.animate(withDuration: 0.2, delay: 0) {
            self.backGroundView.backgroundColor = .black.withAlphaComponent(0.3)
        }
    }
    
    @objc private func shouldDismiss() {
        dismiss(animated: false)
    }
    
    private func initialUiSetting() {
        yearSelectCollectionView.dataSource = self
        yearSelectCollectionView.delegate = self
        
        
        backGroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(shouldDismiss)))
        closeButton.addTarget(self, action: #selector(shouldDismiss), for: .touchUpInside)
        
        layout()
    }
    
    private func layout() {
        [backGroundView, yearSelectView]
            .forEach(view.addSubview)
        
        backGroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        yearSelectView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(300)
            make.centerX.equalToSuperview()
        }
        
        [yearSelectCollectionView, closeButton]
            .forEach(yearSelectView.addSubview)
        
        yearSelectCollectionView.snp.makeConstraints { make in
            make.width.equalTo(200)
            make.height.equalTo(24)
            make.leading.trailing.bottom.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(50)
        }
        
        closeButton.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(6)
            make.size.equalTo(30)
        }
    }
}

extension YearSelectViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return maxYear - minYear + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "YearSelectCell", for: indexPath) as? YearSelectCell else {
            return UICollectionViewCell()
        }
        let row = indexPath.row
        cell.configure(year: "\(minYear+row)", selectedYear: selectedYear)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        yearSelectedSubject.onNext("\(minYear+indexPath.row)")
        
        shouldDismiss()
    }
}


class YearSelectCell: UICollectionViewCell {
    private let yearLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [yearLabel]
            .forEach(contentView.addSubview)
        
        yearLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(year: String, selectedYear: String) {
        yearLabel.text = year
        
        if year == selectedYear {
            yearLabel.font = .outFit(size: 14, family: .Semibold)
        } else {
            yearLabel.font = .outFit(size: 14, family: .Light)
        }
    }
}
