//
//  GoalCircleCell.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/03/07.
//

import UIKit
import RxSwift
import RxCocoa

class GoalCircleCell: UICollectionViewCell {
    let scrollView: UIScrollView = {
        let scrollV = UIScrollView()
        scrollV.showsHorizontalScrollIndicator = false
        scrollV.clipsToBounds = false
        scrollV.backgroundColor = .clear
        return scrollV
    }()
    
    private let scrollContentView = UIView()
    
    private let goalCircle = GoalCircle()
    
    private let tileBoard = TileBoardCollectionView()
    
    private let GoalAnalysisLabel: UILabel = {
        let label = UILabel()
        label.text = "Analysis"
        label.font = .outFit(size: 19, family: .Thin)
        label.textColor = .grayC
        return label
    }()
    
    private let goalStatsView = GoalStatsStackView()
    
    private let doubleTapView = UIView()
    
    /// current goal's scroll 'x' offset
    var didScrollToXSignal: Signal<CGFloat>!
    
    let disposeBag = DisposeBag()
    
    var reuseBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        reuseBag = DisposeBag()
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let circleLayoutAtt = layoutAttributes as? LayoutCircularAttributes {
            self.layer.anchorPoint = circleLayoutAtt.anchorPoint
            self.center.x += (circleLayoutAtt.anchorPoint.x - 0.5) * self.bounds.width
        }
    }
    
    func setupCell(_ viewModel: GoalViewModel) {
        goalCircle.setup(with: viewModel.goalCircleViewModel)
        
        tileBoard.setup(with: viewModel.tileViewModel)
        
        goalStatsView.setStat(with: viewModel.goalStatsViewModel)
    }

    @objc private func doubleTap() {
        scrollView.setContentOffset(.zero, animated: true)
    }
}

extension Reactive where Base: GoalCircleCell {
    var setContentOffsetZero: Binder<Void> {
        Binder(base) { base, _ in
            UIView.animate(withDuration: 0.2, delay: 0.2) {
                base.scrollView.setContentOffset(.zero, animated: false)
            }
        }
    }
}

//MARK: Initial UI Setting
extension GoalCircleCell {
    private func configure() {
        bind()
        addTargets()
        layout()
    }
    
    private func bind() {
        didScrollToXSignal = scrollView.rx.didScroll
            .withLatestFrom(scrollView.rx.contentOffset)
            .map { $0.x }
            .share()
            .asSignal(onErrorSignalWith: .empty())
    }
    
    private func addTargets() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        gestureRecognizer.numberOfTapsRequired = 2
        doubleTapView.addGestureRecognizer(gestureRecognizer)
    }
    
    private func layout() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        [goalCircle, GoalAnalysisLabel, tileBoard, goalStatsView, doubleTapView]
            .forEach(scrollContentView.addSubview(_:))
        
        // - frames
        scrollView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-7)
        }
        
        scrollContentView.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }

        // - contents
        goalCircle.snp.makeConstraints { make in
            make.size.equalTo(K.circleRadius)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset((K.screenWidth-K.circleRadius)/2)
        }
        
        doubleTapView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalTo(tileBoard)
            make.height.equalToSuperview().offset(-100).priority(999)
            make.centerY.equalToSuperview()
        }
        
        tileBoard.snp.makeConstraints { make in
            make.leading.equalTo(goalCircle.snp.trailing).offset(70)
            make.centerY.equalToSuperview().offset(36)
            make.trailing.equalToSuperview().offset(-80)
        }
        
        goalStatsView.snp.makeConstraints { make in
            make.bottom.equalTo(tileBoard.snp.top).offset(-12)
            make.leading.equalTo(tileBoard).inset(3)
        }
        
        GoalAnalysisLabel.snp.makeConstraints { make in
            make.leading.equalTo(tileBoard).inset(1)
            make.bottom.equalTo(goalStatsView.snp.top).offset(-8)
        }
    }
}
