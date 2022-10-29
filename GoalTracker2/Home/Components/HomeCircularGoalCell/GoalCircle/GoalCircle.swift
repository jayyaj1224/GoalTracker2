//
//  GoalCircle.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/03/01.
//

import UIKit
import RxSwift
import RxCocoa

class GoalCircle: UIView {
    //View Model
//    private var viewModel: GoalCircleViewModel!
    
    //User Interface
    private var circleRim: UIImageView!
    private var innerCircle: UIImageView!
    
    private var innerCircleContent: UIView!
    
    private var innerCircleBackContent: UIView!
    
    private var dateCheckImage: UIImageView!
    
    private var checkImageView: UIImageView!
    
    var checkButton: UIButton!
    
    private var processArc: ArcProcessBar!
    private var dialImage: UIImageView!
    
    private var digitView_success: DigitalCountPannel!
    private var digitView_fail: DigitalCountPannel!
    
    private var titleLabel: UILabel!
    
    private let disposebag = DisposeBag()
    
    private var isViewFlipped: Bool = false
    
    func setup(with viewModel: GoalCircleViewModel) {
        let goal = viewModel.goal
        
        titleLabel.text = goal.title
        
        digitView_success.setNumber(goal.successCount)
        digitView_fail.setNumber(goal.failCount)
        
        processArc.fillPercentage = viewModel.processPercentage
    }
    
    
    func flip() {
        if isViewFlipped {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: .curveEaseIn,
                animations: {
                    self.innerCircle.transform = .identity
                    self.innerCircle.alpha = 1
                    self.innerCircleBackContent.alpha = 0
                },
                completion: { _ in
                    self.isViewFlipped = false
                }
            )
        } else {
            UIView.animate(
                withDuration: 0.3,
                delay: 0,
                options: .curveLinear,
                animations: {
                    self.innerCircle.layer.transform = CATransform3DMakeRotation(180.pi.cgFloat, 0, 1, 0)
                    self.innerCircle.alpha = 0
                    self.innerCircleBackContent.alpha = 1
                },
                completion: { _ in
                    self.isViewFlipped = true
                }
            )
        }
    }
    
    func flipBack() {
        if isViewFlipped {
            self.innerCircle.transform = .identity
            self.innerCircle.alpha = 1
            self.innerCircleBackContent.alpha = 0
            self.isViewFlipped = false
        }
    }

    
    convenience init() {
        self.init(frame: .zero)
        
        let circleSize = 222/380*K.circleRadius

        processArc = ArcProcessBar()
        self.addSubview(processArc)
        processArc.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(circleSize+8)
        }
        
        let circleInnerShadow = UIImageView(imageName: "circle_inner_shadow")
        circleRim = UIImageView(imageName: "circle_rim")
        innerCircle = UIImageView(imageName: "circle_inner_216")
        
        [circleInnerShadow, circleRim, innerCircle]
            .forEach { view in
                guard let view = view else { return }
                addSubview(view)
                view.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }

        innerCircleContent = UIView()
        innerCircle.addSubview(innerCircleContent)
        innerCircleContent.snp.makeConstraints { make in
            make.size.equalTo(circleSize)
            make.center.equalToSuperview()
        }
        
        innerCircleBackContent = UIView()
        addSubview(innerCircleBackContent)
        innerCircleBackContent.snp.makeConstraints { make in
            make.size.equalTo(circleSize)
            make.center.equalToSuperview()
        }
        let innerBackImage = UIImageView(imageName: "circle_inner_216")
        innerCircleBackContent.addSubview(innerBackImage)
        innerBackImage.snp.makeConstraints { make in
            make.size.equalTo(self)
            make.center.equalToSuperview()
        }
        
        dateCheckImage = UIImageView(imageName: "Group 145")
        innerCircleBackContent.addSubview(dateCheckImage)
        dateCheckImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(224)
            make.height.equalTo(46)
        }
        
        innerCircleBackContent.alpha = 0
        
        titleLabel = UILabel()
        titleLabel.font = .sfPro(size: 16, family: .Light)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.8
        titleLabel.numberOfLines = 3
        titleLabel.textAlignment = .center
        
        innerCircleContent.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview().offset(-5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-20)
        }
        
        let rimSize = 294/380*K.circleRadius
        dialImage = UIImageView(imageName: "yearly_dial")
        dialImage.clipsToBounds = true
        dialImage.layer.cornerRadius = rimSize/2
        addSubview(dialImage)
        dialImage.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(rimSize-6)
        }
        
        let pannelView = UIView()
        pannelView.backgroundColor = .crayon
//        pannelView.setShadow(alpha: 0.4, colour: UIColor.black.cgColor, rd: 1, width: 1, height: 1)
        innerCircleContent.addSubview(pannelView)
        pannelView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-28)
            make.width.equalTo(110)
            make.height.equalTo(45)
        }
        
        let scorePannel = UIStackView()
        scorePannel.setDropShadow(color: .black, width: 1, height: 1, blur: 1, spread: 0.5, opacity: 0.4)
        scorePannel.axis = .horizontal
        scorePannel.spacing = 10
        scorePannel.distribution = .equalSpacing
        
        innerCircleContent.addSubview(scorePannel)
        scorePannel.snp.makeConstraints { make in
            make.height.equalTo(35)
            make.center.equalTo(pannelView)
        }
        
        let sucView = makeScorePannel(title: "Success") { digitView in
            digitView_success = digitView
        }
        
        let failView = makeScorePannel(title: "Fail", failDigit: true) { digitView in
            digitView_fail = digitView
        }
     
        scorePannel.addArrangedSubview(sucView)
        scorePannel.addArrangedSubview(failView)
        
        let line = UIView()
        line.backgroundColor = .lightGray.withAlphaComponent(0.3)
        
        scorePannel.addSubview(line)
        line.snp.makeConstraints { make in
            make.width.equalTo(0.5)
            make.height.equalTo(30)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        addSubview(processArc.nowPoint!)
        
//        checkImageView = UIImageView(imageName: "check_pannel")
//        innerCircleContent.addSubview(checkImageView)
//        checkImageView.snp.makeConstraints { make in
//            make.size.equalTo(20)
//            make.leading.equalTo(pannelView.snp.trailing).offset(6)
////            make.top.equalTo(pannelView).offset(-6)
//            make.centerY.equalTo(pannelView).offset(-6)
//        }
//
//        checkButton = UIButton()
//        checkButton.layer.cornerRadius = 30
////        checkButton.backgroundColor = .red.withAlphaComponent(0.3)
//        addSubview(checkButton)
//        checkButton.snp.makeConstraints { make in
//            make.size.equalTo(60)
//            make.center.equalTo(checkImageView)
//        }
        
//        
//        innerCircleContent.layer.borderWidth = 1
//        innerCircleContent.layer.borderColor = .black
//        
//        let button
    }
    
    private func makeScorePannel(title: String, failDigit: Bool=false, digitView completion: (DigitalCountPannel)->Void) -> UIView {
        let contentView = UIView()
        
        let digitView = DigitalCountPannel(digitCount: 3, failDigit: failDigit)
        contentView.addSubview(digitView)
        digitView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.size.equalTo(digitView.size)
            make.bottom.equalToSuperview()
        }
        
        digitView.setNumber(100)
        
        let label = UILabel()
        label.text = title
        label.font = .outFit(size: 9, family: .Thin)
        label.textAlignment = .center
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.width.equalTo(digitView.size.width+6)
        }
        
        completion(digitView)
        
        return contentView
    }
}
