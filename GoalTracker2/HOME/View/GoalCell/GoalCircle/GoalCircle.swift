//
//  GoalCircle.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/03/01.
//

import UIKit
import RxSwift
import RxCocoa
import Lottie

class GoalCircle: UIView {
    private let circleRimImageView = UIImageView(imageName: "circle_rim")
    
    private let innerCircleImageView = UIImageView(imageName: "circle_inner_216")
    
    private let circleInnerShadow = UIImageView(imageName: "circle_inner_shadow")
    
    private var dialImageView: UIImageView = {
        let imageView = UIImageView(imageName: "dial.ver3")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 294/380*K.circleRadius/2
        return imageView
    }()
    
    private let innerCircleContentView = UIView()
    
    private let processArc = ArcProcessBar()
    
    private let percentageLabel: UILabel = {
        let label = UILabel()
        label.font = .outFit(size: 11, family: .Medium)
        label.textColor = .grayC
        return label
    }()
    
    private let goalTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .noto(size: 17, family: .Light)
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        label.numberOfLines = 3
        label.textAlignment = .center
        label.textColor = .black
        return label
    }()
    
    var scoreView: ScorePannel!
    
    private let blueDiamondLottieView: AnimationView = {
        let animationView = AnimationView.init(name: "blue-diamond")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1
        return animationView
    }()
    
    private let yellowDiamondLottieView: AnimationView = {
        let animationView = AnimationView.init(name: "yellow-diamond2")
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 1
        return animationView
    }()
    
    private let diamondShadowImageView = UIImageView(imageName: "diamond.shadow-1")
    
    let circleSize = 222 / 380 * K.circleRadius
    
    let rimSize = 294 / 380 * K.circleRadius
    
    init() {
        super.init(frame: .zero)
        
        configureScoreView()
        
        initLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let disposebag = DisposeBag()
    
    func setup(with viewModel: GoalCircleViewModel) {
        let goal = viewModel.goal
        
        goalTitleLabel.text = goal.title
        
        processArc.processPercentage = viewModel.executionRate
        processArc.setNeedsDisplay()
        
        executionRateSet(with: viewModel.executionRate)
        
        if scoreView.type != SettingsManager.shared.scorePannelType {
            if let scoreUIView = scoreView as? UIView {
                scoreUIView.removeFromSuperview()
                
                self.scoreView = nil
                
                configureScoreView { newScoreView in
                    newScoreView.set(success: goal.successCount, fail: goal.failCount)
                }
            }
        } else {
            scoreView.set(success: goal.successCount, fail: goal.failCount)
        }
    }
    
    private func configureScoreView(completion: ((ScorePannel)->Void)? = nil) {
        switch SettingsManager.shared.scorePannelType {
        case .Flap:
            scoreView = FlapScoreView()
            completion?(scoreView)
        case .Digital:
            scoreView = DigitalScoreView()
            completion?(scoreView)
        }
        scoreViewLayout()
    }
    
    private func executionRateSet(with executionRate: CGFloat) {
        percentageLabel.text = "\(Int(executionRate))"
        diamondShadowImageView.isHidden = true
        
        switch Int(executionRate) {
        case 98...:
            yellowDiamondLottieView.isHidden = false
            diamondShadowImageView.isHidden = false
            yellowDiamondLottieView.play()
            
            blueDiamondLottieView.isHidden = true
            blueDiamondLottieView.stop()
            percentageLabel.font = .outFit(size: 12, family: .Semibold)
        case 91...97:
            blueDiamondLottieView.isHidden = false
            blueDiamondLottieView.play()
            
            yellowDiamondLottieView.isHidden = true
            yellowDiamondLottieView.stop()
            percentageLabel.font = .outFit(size: 11, family: .Medium)
        default:
            diamondShadowImageView.isHidden = true
            [blueDiamondLottieView, yellowDiamondLottieView]
                .forEach { lottie in
                    lottie.isHidden = true
                    lottie.stop()
                }
            percentageLabel.font = .outFit(size: 11, family: .Regular)
        }
    }
    
    private func initLayout() {
        [
            processArc, circleInnerShadow, circleRimImageView,
            innerCircleImageView, innerCircleContentView,
            processArc.nowPointView, dialImageView, percentageLabel,
            diamondShadowImageView, yellowDiamondLottieView, blueDiamondLottieView
            
        ].forEach(addSubview)
        
        [circleInnerShadow, circleRimImageView, innerCircleImageView]
            .forEach { view in
                view.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        
        processArc.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(circleSize+8)
        }
        
        innerCircleContentView.snp.makeConstraints { make in
            make.size.equalTo(circleSize)
            make.center.equalTo(innerCircleImageView)
        }
        
        percentageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(-2)
            make.top.equalTo(dialImageView).inset(9)
        }
        
        dialImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(rimSize+6)
        }
        
        processArc.nowPointView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(circleSize+17)
            make.width.equalTo((circleSize+17)/740*25)
        }
        
        blueDiamondLottieView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(10)
            make.size.equalTo(40)
        }
        
        yellowDiamondLottieView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(2)
            make.size.equalTo(60)
        }
        
        diamondShadowImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(2)
            make.size.equalTo(60)
        }
        
        [goalTitleLabel]
            .forEach(innerCircleContentView.addSubview)

        goalTitleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-20)
        }
        
        scoreViewLayout()
    }
    
    private func scoreViewLayout() {
        guard let scoreView = scoreView as? UIView else { return }
        
        [scoreView]
            .forEach(innerCircleContentView.addSubview)
        
        switch SettingsManager.shared.scorePannelType {
        case .Flap:
            scoreView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().inset(28)
            }
        case .Digital:
            scoreView.snp.makeConstraints { make in
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().inset(33)
            }
        }
    }
}
