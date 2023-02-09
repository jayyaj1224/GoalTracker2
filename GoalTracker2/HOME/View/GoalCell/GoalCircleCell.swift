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
    
    private let statsTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .outFit(size: 19, family: .Thin)
        label.textColor = .grayC
        return label
    }()
    
    private let goalStatsView = GoalStatsStackView()
    
    private let doubleTapView = UIView()
    
    private let copyButton: UIButton = {
        let button = UIButton()
        button.configuration = UIButton.Configuration.plain()
        button.configuration?.image = UIImage(named: "copy.neumorphism")
        return button
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .sfPro(size: 14, family: .Regular)
        label.textColor = .grayC
        label.numberOfLines = 0
        return label
    }()
    
    var viewModel: GoalViewModel!
    
    /// current goal's scroll 'x' offset
    var didScrollToXSignal: Signal<CGFloat>!
    
    fileprivate var backButtonTapScrolling = true
    
    private let disposeBag = DisposeBag()
    
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
            layer.anchorPoint = circleLayoutAtt.anchorPoint
            center.x += bounds.width*(circleLayoutAtt.anchorPoint.x - 0.5)
        }
    }
    
    func setupCell(_ viewModel: GoalViewModel) {
        self.viewModel = viewModel
        
        goalCircle.setup(with: viewModel)
        
        tileBoard.setup(with: viewModel)
        
        goalStatsView.setStat(with: viewModel)
        
        let goal = viewModel.goal
        let dayOrDays = (goal.totalDays>1) ? "Days" : "Day"
        let attrString = NSMutableAttributedString(string: "\(goal.totalDays) \(dayOrDays) of Challenge")
        let style = NSMutableParagraphStyle()

        attrString.addAttribute(NSAttributedString.Key.font, value: UIFont.outFit(size: 19, family: .Regular), range: NSRange(location: 0, length: String(goal.totalDays).count))
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0, length: attrString.length))

        statsTitleLabel.attributedText = attrString
        
        descriptionLabel.text = goal.description
    }

    @objc private func doubleTap() {
        scrollView.setContentOffset(.zero, animated: true)
    }
    
    @objc private func copyButtonTapped() {
        GTAlertViewController()
            .make(
                title: "Copy",
                subTitle: "Which data would you like to copy?",
                buttonText: "Tile Board",
                buttonFont: .sfPro(size: 15, family: .Medium),
                cancelButtonText: "Analysis Stats",
                cancelButtonFont: .sfPro(size: 15, family: .Medium),
                buttonTextColor: .black,
                cancelButtonTextColor: .black
            )
            .addAction {
                self.copyTileBoard()
            }
            .addCancelAction {
                self.copyGoalStats()
            }
            .onCompletion {
                self.showCopyCompletedToast()
            }
            .show()
    }
    
    private func copyTileBoard() {
        let image = tileBoard.capture()
        
        UIPasteboard.general.image = image
    }
    
    private func copyGoalStats() {
        UIPasteboard.general.string = viewModel.getGoalCopyStrings()
    }
    
    private func showCopyCompletedToast() {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            topController.view.hideAllToasts()
            topController.view.makeToast("Copied", position: .bottom)
        }
    }
}

extension Reactive where Base: GoalCircleCell {
    var setContentOffsetZero: Binder<Void> {
        Binder(base) { base, _ in
            base.backButtonTapScrolling = true
            
            UIView.animate(withDuration: 0.2, delay: 0.2) {
                base.scrollView.setContentOffset(.zero, animated: false)
                
            } completion: { _ in
                base.backButtonTapScrolling = false
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
        
        let hidingView = [statsTitleLabel, tileBoard, goalStatsView]
        hidingView.forEach { $0.alpha = 0}
        
        didScrollToXSignal
            .filter { _ in self.backButtonTapScrolling == false }
            .emit(onNext: { x in
                
                var alpha: CGFloat = 0
                
                switch x {
                case -30..<70:
                    alpha = 0
                case 70...250:
                    alpha = (x-70)/250
                default:
                    alpha = 1
                }
                
                DispatchQueue.main.async {
                    hidingView.forEach { $0.alpha = alpha }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func addTargets() {
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTap))
        gestureRecognizer.numberOfTapsRequired = 2
        doubleTapView.addGestureRecognizer(gestureRecognizer)
        
        copyButton.addTarget(self, action: #selector(copyButtonTapped), for: .touchUpInside)
    }
    
    private func layout() {
        contentView.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        
        [goalCircle, statsTitleLabel, tileBoard, goalStatsView, descriptionLabel, doubleTapView, copyButton]
            .forEach(scrollContentView.addSubview)
        
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
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(tileBoard.snp.bottom).offset(10)
            make.leading.equalTo(tileBoard).inset(3)
            make.width.equalTo(300)
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
            make.trailing.lessThanOrEqualToSuperview().offset(-60)
        }
        
        goalStatsView.snp.makeConstraints { make in
            make.bottom.equalTo(tileBoard.snp.top).offset(-12)
            make.leading.equalTo(tileBoard).inset(3)
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        
        copyButton.snp.makeConstraints { make in
            make.leading.equalTo(statsTitleLabel.snp.trailing).offset(-10)
            make.centerY.equalTo(statsTitleLabel)
            make.size.equalTo(60)
        }
        
        statsTitleLabel.snp.makeConstraints { make in
            make.leading.equalTo(tileBoard).inset(1)
            make.bottom.equalTo(goalStatsView.snp.top).offset(-8)
        }
    }
}
