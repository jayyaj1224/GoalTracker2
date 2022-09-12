//
//  GoalCell.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/03/07.
//

import UIKit
import RxSwift
import RxCocoa

class HomeCircularGoalCell: UICollectionViewCell {
    static var cellIdentifier = 0
    
    var scrollView: UIScrollView!
    
    var scrollContent: UIView!
    
    var goalCircle: GoalCircle!
    
    var tileBoard: TileBoardCollectionView!
    
    var deleteImageView: UIImageView!
    
    var doubleTapView: UIView!
    
    let mainViewDidScrollSubject = PublishSubject<CGPoint>()
//    let mainViewDidEndDecelerateSubject = PublishSubject<CGPoint>()
    
    let shouldPresentTilesSubject = PublishSubject<Bool>()
    var tilesDisappearedSignal: Signal<Void>!
    
    var currentGoalDidScrollHorizontally: Signal<CGFloat>!
    
    let disposeBag = DisposeBag()
    
    var reuseBag = DisposeBag()
    
    var identifier: Int = -1
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        HomeCircularGoalCell.cellIdentifier+=1
        identifier = HomeCircularGoalCell.cellIdentifier
//        print("init cell id: \(identifier)")
        
        layout()
        bind()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        print(" reusing cell id: \(identifier)")
        reuseBag = DisposeBag()
    }
    
    func setupCell(_ viewModel: GoalViewModel) {
        goalCircle.setup(with: viewModel.goalCircleViewModel)
        
//        tileBoard.setup(with: viewModel.tileVm)
    }
    
    private func bind() {
        mainViewDidScrollSubject
            .subscribe(self.rx.shouldSetContentOffsetZero)
            .disposed(by: disposeBag)
        
        let didScrollContentOffsetShare = scrollView.rx.didScroll
            .withLatestFrom(scrollView.rx.contentOffset)
            .map { $0.x }
            .share()
        
        currentGoalDidScrollHorizontally = didScrollContentOffsetShare
            .asSignal(onErrorSignalWith: .empty())
        
        tilesDisappearedSignal = didScrollContentOffsetShare
            .filter { $0 <= 0 }
            .map { _ in }
            .asSignal(onErrorSignalWith: .empty())
        
        shouldPresentTilesSubject
            .subscribe(onNext: { [weak self] present in
                let x = present ? K.screenWidth : 0
                self?.scrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func layout() {
        let goalCircleLeadingOffset = (K.screenWidth-K.circleRadius)/2
        
        let goalCircleImageInset = K.circleRadius/380*70
        
        let deleteImageOffset = goalCircleLeadingOffset + goalCircleImageInset
        
        deleteImageView = UIImageView(imageName: "icon_delete")
        deleteImageView.alpha = 0
        contentView.addSubview(deleteImageView)
        deleteImageView.snp.makeConstraints { make in
            make.size.equalTo(36)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(deleteImageOffset)
        }
        
        scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = false
        scrollView.backgroundColor = .clear
        
        contentView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
            make.trailing.equalToSuperview().offset(-7)
        }
        
        scrollContent = UIView()
        scrollView.addSubview(scrollContent)
        scrollContent.snp.makeConstraints { make in
            make.height.equalToSuperview()
            make.centerY.equalToSuperview()
            make.leading.trailing.equalToSuperview()
        }
        
        goalCircle = GoalCircle()
        scrollContent.addSubview(goalCircle)
        goalCircle.snp.makeConstraints { make in
            make.size.equalTo(K.circleRadius)
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(goalCircleLeadingOffset)
        }
        
        tileBoard = TileBoardCollectionView()
        scrollContent.addSubview(tileBoard)
        
        doubleTapView = UIView()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        gestureRecognizer.numberOfTapsRequired = 2
        doubleTapView.addGestureRecognizer(gestureRecognizer)
        scrollContent.addSubview(doubleTapView)
        doubleTapView.snp.makeConstraints { make in
            make.trailing.equalToSuperview()
            make.leading.equalTo(tileBoard)
            make.height.equalToSuperview().offset(-100).priority(999)
            make.centerY.equalToSuperview()
        }
        
        tileBoard.snp.makeConstraints { make in
            make.leading.equalTo(goalCircle.snp.trailing).offset(70)
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview().offset(-100)
        }
        
        let tileBoardLabel = UILabel()
        tileBoardLabel.text = "Progress Board"
        tileBoardLabel.font = .sfPro(size: 16, family: .Thin)
        tileBoardLabel.textColor = .lightGray
        
        scrollContent.addSubview(tileBoardLabel)
        tileBoardLabel.snp.makeConstraints { make in
            make.leading.equalTo(tileBoard).offset(10)
            make.bottom.equalTo(tileBoard.snp.top).offset(-10)
        }
        
        scrollContent.bringSubviewToFront(tileBoard)
        scrollContent.bringSubviewToFront(doubleTapView)
    }
    
    @objc private func doubleTap() {
        scrollView.setContentOffset(.zero, animated: true)
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        if let circleLayoutAtt = layoutAttributes as? LayoutCircularAttributes {
            self.layer.anchorPoint = circleLayoutAtt.anchorPoint
            self.center.x += (circleLayoutAtt.anchorPoint.x - 0.5) * self.bounds.width
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension Reactive where Base: HomeCircularGoalCell {
    var shouldSetContentOffsetZero: Binder<CGPoint> {
        Binder(base) { base, _ in
            UIView.animate(withDuration: 0.2, delay: 0.2) {
                base.scrollView.setContentOffset(.zero, animated: false)
            }
        }
    }
}
