//
//  PlusMenuViewController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 17/09/2022.
//

import UIKit

class PlusMenuViewController: UIViewController {
    
    //MARK: - Components SubClass
    private class MenuButtonView: UIView {
        private let iconImageView = UIImageView()
        
        private let menuLabel: UILabel = {
            let label = UILabel()
            label.font = .sfPro(size: 16, family: .Medium)
//            label.textColor = .grayB
            label.textColor = .crayon
            return label
        }()
        
        init(imageName: String, title: String) {
            super.init(frame: .zero)
            
            iconImageView.image = UIImage(named: imageName)
            menuLabel.text = title
            layout()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func layout() {
            [iconImageView, menuLabel]
                .forEach {
                    addSubview($0)
                }
            
            iconImageView.snp.makeConstraints { make in
                make.centerY.equalToSuperview()
                make.leading.equalToSuperview().inset(7)
                make.size.equalTo(22)
            }
            
            menuLabel.snp.makeConstraints { make in
                make.leading.equalTo(iconImageView.snp.trailing).offset(5)
                make.centerY.equalToSuperview()
            }
        }
    }
    
    //MARK: - Components
    private let firstMenuBox: UIView = {
//        let boxView = NeumorphicView(color: .crayon, shadowSize: .medium)
        let boxView = UIView()
        boxView.backgroundColor = .crayon
        boxView.layer.cornerRadius = 15
//        boxView.setShadowOpacity(0.1)
        return boxView
    }()

    private let secondMenuBox: UIView = {
//        let boxView = NeumorphicView(color: .crayon, shadowSize: .medium)
        let boxView = UIView()
        boxView.backgroundColor = .crayon
        boxView.layer.cornerRadius = 15
//        boxView.setShadowOpacity(0.1)
        return boxView
    }()
    
    private let settingButton = MenuButtonView(imageName: "gear.neumorphism", title: "Setting")
    
    private let deleteGoalButton = MenuButtonView(imageName: "bin.neumorphism", title: "Delete Goal")
    
    private let addGoalButton = MenuButtonView(imageName: "plus.small.neumorphism", title: "Add Goal")
    
    private let backgroundDimView: UIView = {
        let view = UIView()
        view.backgroundColor = .dimB
        view.alpha = 0
        return view
    }()
    
    private let cancelRotatingButton: RotatingButtonView = {
        let button = RotatingButtonView(imageName: "x.neumorphism")
        button.iconImageView.alpha = 0
        button.setShadowOpacity(0.15)
        return button
    }()
    
    private let plusIconImageView = UIImageView(imageName: "plus.neumorphism")
    
    var secondBoxBottomConstraint: NSLayoutConstraint!
    
    var dismissCompletionHandler: (()->Void)?
    
    //MARK: - Logics
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutComponents()
        
        addButtonTargets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cancelButtonViewDidAppearAnimation()
    }
    
    private func layoutComponents() {
        [backgroundDimView, cancelRotatingButton, plusIconImageView, firstMenuBox, secondMenuBox]
            .forEach {
                view.addSubview($0)
            }
        
        firstMenuBox.snp.makeConstraints { make in
            make.height.equalTo(80)
            make.width.equalTo(150*K.ratioFactor)
            make.trailing.equalToSuperview().inset(21)
            make.bottom.equalTo(secondMenuBox.snp.top).offset(-13)
        }
        
        secondMenuBox.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.width.equalTo(150*K.ratioFactor)
            make.trailing.equalToSuperview().inset(21)
        }
        
        secondMenuBox.translatesAutoresizingMaskIntoConstraints = false
        secondBoxBottomConstraint = secondMenuBox.bottomAnchor.constraint(equalTo: cancelRotatingButton.bottomAnchor)
        secondBoxBottomConstraint.constant = -55
        secondBoxBottomConstraint.isActive = true
        
        firstMenuBox.addSubview(settingButton)
        firstMenuBox.addSubview(deleteGoalButton)
        
        secondMenuBox.addSubview(addGoalButton)
        
        settingButton.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.height.equalTo(40)
            make.leading.trailing.equalToSuperview()
        }
        
        deleteGoalButton.snp.makeConstraints { make in
            make.top.equalTo(settingButton.snp.bottom)
            make.height.equalTo(40)
            make.leading.trailing.equalToSuperview()
        }
        
        addGoalButton.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.leading.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        backgroundDimView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        cancelRotatingButton.snp.makeConstraints { make in
            make.size.equalTo(40)
            make.trailing.equalToSuperview().inset(18)
            make.bottom.equalToSuperview().inset((K.hasNotch ? 125 : 86)*K.ratioFactor)
        }

        plusIconImageView.snp.makeConstraints { make in
            make.center.equalTo(cancelRotatingButton)
            make.size.equalTo(22)
        }
    }
    
    private func addButtonTargets() {
        cancelRotatingButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
    }
    
    @objc private func cancelButtonTapped() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            self.cancelRotatingButton.iconImageView.transform = CGAffineTransform(rotationAngle: -135.pi.cgFloat)
            self.backgroundDimView.alpha = 0
        } completion: { _ in
            self.dismiss(animated: false, completion: self.dismissCompletionHandler)
        }
    }
    
    private func cancelButtonViewDidAppearAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0.05, options: .curveLinear) {
            self.plusIconImageView.transform = CGAffineTransform(rotationAngle: 135.pi.cgFloat)
            self.backgroundDimView.alpha = 1
        } completion: { _ in
            self.cancelRotatingButton.iconImageView.alpha = 1
            self.plusIconImageView.alpha = 0
        }
    }
    
    private func menuButtonsViewDidAppearAnimation() {
        UIView.animate(withDuration: 0.3, delay: 0.05, options: .curveLinear) {
            self.secondBoxBottomConstraint.constant = 12
            
            self.firstMenuBox.alpha = 1
            self.secondMenuBox.alpha = 1
        } completion: { _ in
            
        }
    }
}
