//
//  PlusMenuViewController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 17/09/2022.
//

import UIKit
import RxSwift
import RxCocoa

class PlusMenuViewController: UIViewController {
    //MARK: - Components SubClass
    private class MenuButton: UIButton {
        init(title: String, imageName: String) {
            super.init(frame: .zero)
            
            let attributedString = NSMutableAttributedString(
                string: title,
                attributes: [
                    NSMutableAttributedString.Key.font: UIFont.sfPro(size: 17, family: .Semibold),
                    NSMutableAttributedString.Key.foregroundColor: UIColor.crayon
                ]
            )
            setAttributedTitle(attributedString, for: .normal)
            contentHorizontalAlignment = .left
            
            var config = UIButton.Configuration.plain()
            config.image = UIImage(named: imageName)
            config.imagePlacement = .leading
            config.imagePadding = 8
            self.configuration = config
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    //MARK: - Components
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.distribution = .fill
        return stackView
    }()
    
    private let settingButton = MenuButton(title: "Setting", imageName: "gear.neumorphism")
    
    private let deleteGoalButton = MenuButton(title: "Delete Goal", imageName: "bin.neumorphism")
    
    private let addGoalButton = MenuButton(title: "Add Goal", imageName: "plus.small.neumorphism")
    
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
    
    //MARK: - Logics
    let newGoalSavedSubject = PublishSubject<Goal>()

    let viewDismissSubject = PublishSubject<Void>()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layoutComponents()
        
        addButtonTargets()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cancelButtonViewDidAppearAnimation()
        menuButtonsViewDidAppearAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.viewDismissSubject.onNext(())
    }
    
    
    //MARK: - Button Actions
    private func addButtonTargets() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundDimViewTapped))
        backgroundDimView.addGestureRecognizer(tapGestureRecognizer)
        
        cancelRotatingButton.addTarget(self, action: #selector(cancelButtonActionWithAnimation), for: .touchUpInside)
        
        settingButton.addTarget(self, action: #selector(settingButtonTapped(_:)), for: .touchUpInside)
        deleteGoalButton.addTarget(self, action: #selector(deleteGoalButtonTapped(_:)), for: .touchUpInside)
        addGoalButton.addTarget(self, action: #selector(addGoalButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func settingButtonTapped(_ sender: UIButton) {
        let settingsViewController = SettingsViewController()
//        settingsViewController.modalPresentationStyle = .custom
//        settingsViewController.transitioningDelegate = self
        
        present(settingsViewController, animated: true, completion: nil)
    }
    
    @objc private func deleteGoalButtonTapped(_ sender: UIButton) {
        print("deleteGoalButtonTapped")
        GoalManager.shared.deleteAll()
    }
    
    @objc private func addGoalButtonTapped(_ sender: UIButton) {
        let addgoalViewController = AddGoalViewController()
        addgoalViewController.modalPresentationStyle = .custom
        addgoalViewController.transitioningDelegate = self
        
        addgoalViewController.saveButtonTappedSubject
            .bind(to: newGoalSavedSubject)
            .disposed(by: disposeBag)
        
        present(addgoalViewController, animated: true, completion: nil)
    }
    
    @objc private func backgroundDimViewTapped() {
        dismiss(animated: false)
    }
    
    //MARK: - animations
    @objc private func cancelButtonActionWithAnimation() {
        //let feedBackGenerator = UIImpactFeedbackGenerator(style: .medium)
        //feedBackGenerator.impactOccurred()

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveLinear) {
            self.cancelRotatingButton.iconImageView.transform = CGAffineTransform(rotationAngle: -135.pi.cgFloat)
            self.buttonStackView.transform = CGAffineTransform(translationX: 0, y: 50)
            self.backgroundDimView.alpha = 0
            self.buttonStackView.alpha = 0
            
        } completion: { _ in
            self.dismiss(animated: false)
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
        UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveLinear) {
            self.buttonStackView.transform = .identity
            self.buttonStackView.alpha = 1
        } completion: { _ in
            
        }
    }
    
    //MARK: -  View Settings
    private func layoutComponents() {
        [backgroundDimView, buttonStackView, cancelRotatingButton, plusIconImageView]
            .forEach {
                view.addSubview($0)
            }
        
        [settingButton, deleteGoalButton, addGoalButton]
            .forEach {
                buttonStackView.addArrangedSubview($0)
            }
        
        buttonStackView.snp.makeConstraints { make in
            make.width.equalTo(148*K.ratioFactor)
            make.trailing.equalToSuperview().inset(20)
            make.bottom.equalTo(cancelRotatingButton.snp.top).offset(-19)
        }
        
        // initial animation preperation
        buttonStackView.alpha = 0
        buttonStackView.transform = CGAffineTransform(translationX: 0, y: 50)
        
        settingButton.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        deleteGoalButton.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        
        addGoalButton.snp.makeConstraints { make in
            make.height.equalTo(40)
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
}

extension PlusMenuViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {

        return PresentationController(contentHeight: K.screenHeight*0.7, presentedViewController: presented, presenting: presenting)
    }
}

