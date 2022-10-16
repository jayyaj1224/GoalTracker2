//
//  SwitchController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 16/10/2022.
//

import UIKit
import RxSwift
import RxCocoa

class NeumorphicSwitch: UIView {
    enum SwitchToggleAnimationType {
        case withSpring, normal, none
    }
    
    private let buttonLaneImageView: UIImageView = {
        let imageView = UIImageView(imageName: "switch_lane_off")
        imageView.highlightedImage = UIImage(named: "switch_lane_on")
        return imageView
    }()
    
    private let switchStoneView: UIView = {
        let view = UIView()
        view.setDropShadow(color: .black, width: 1, height: 1, blur: 1, spread: -1, opacity: 0.4)
        view.backgroundColor = .crayon
        return view
    }()
    
    private let onOffActionInputButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    public var isOnSubjuect = PublishSubject<Bool>()
    
    public var isOn: Bool = false
    
    private var toggleAnimationType: SwitchToggleAnimationType = .none
    
    private var switchOnTrailingingAnchor: NSLayoutConstraint?
    
    private var switchOffLeadingAnchor: NSLayoutConstraint?
    
    private var switchSize: CGSize = .zero
    
    override private init(frame: CGRect) {
        super.init(frame: .zero)
    }
    
    init(toggleAnimationType animationType: SwitchToggleAnimationType, size: CGSize = CGSize(width: 60, height: 24)) {
        super.init(frame: .zero)
        
        switchSize = size
        
        toggleAnimationType = animationType
        
        layout()
        
        onOffActionInputButton.addTarget(self, action: #selector(switchToggled(_:)), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func switchToggled(_ sender: UIButton) {
        isOn.toggle()
        
        isOnSubjuect.onNext(isOn)
        
        if isOn {
            switchOnAnimation()
        } else {
            switchOffAnimation()
        }
    }
    
    private func switchOnAnimation() {
        buttonLaneImageView.isHighlighted = true
        switchOffLeadingAnchor?.isActive = false
        
        switchAnimate { [weak self] in
            self?.switchOnTrailingingAnchor?.isActive = true
            self?.layoutSubviews()
        }
    }
    
    private func switchOffAnimation() {
        buttonLaneImageView.isHighlighted = false
        switchOnTrailingingAnchor?.isActive = false
        
        switchAnimate { [weak self] in
            self?.switchOffLeadingAnchor?.isActive = true
            self?.layoutSubviews()
        }
    }
    
    private func switchAnimate(_ animate: @escaping ()->Void) {
        switch toggleAnimationType {
        case .withSpring:
            UIView.animate(withDuration: 0.17, delay: 0, usingSpringWithDamping: 0.1, initialSpringVelocity: 0.03, options: .curveEaseOut) {
                animate()
            }
        case .normal:
            UIView.animate(withDuration: 0.05, delay: 0, options: .curveLinear) {
                animate()
            }
        case .none:
            animate()
        }
    }
}

//MARK: Layout
extension NeumorphicSwitch {
    private func layout() {
        self.snp.makeConstraints { make in
            make.width.equalTo(switchSize.width)
            make.height.equalTo(switchSize.height)
        }
        
        switchStoneView.layer.cornerRadius = (switchSize.height-5.4)/2
        
        [buttonLaneImageView, switchStoneView, onOffActionInputButton]
            .forEach { addSubview($0) }
        
        buttonLaneImageView.snp.makeConstraints { make in
            make.width.equalTo(switchSize.width)
            make.height.equalTo(switchSize.height)
            make.center.equalToSuperview()
        }
        
        switchStoneView.snp.makeConstraints { make in
            make.size.equalTo(switchSize.height-5.4)
            make.centerY.equalToSuperview()
        }
        
        switchStoneView.translatesAutoresizingMaskIntoConstraints = false
        switchOnTrailingingAnchor = switchStoneView.trailingAnchor.constraint(equalTo: buttonLaneImageView.trailingAnchor, constant: -3)
        switchOffLeadingAnchor = switchStoneView.leadingAnchor.constraint(equalTo: buttonLaneImageView.leadingAnchor, constant: 3)
        
        switchOnTrailingingAnchor?.isActive = false
        switchOffLeadingAnchor?.isActive = true
        
        onOffActionInputButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
    }
}
