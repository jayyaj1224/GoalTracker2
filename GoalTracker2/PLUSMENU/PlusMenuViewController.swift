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
                    NSMutableAttributedString.Key.font: UIFont.noto(size: 17, family: .Medium),
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
    
    private let calendarButton = MenuButton(title: "Calendar", imageName: "calendar.neumorphism")
    
    private let deleteGoalButton = MenuButton(title: "Delete Goal", imageName: "bin.neumorphism")
    
    private let addGoalButton = MenuButton(title: "Add Goal", imageName: "plus.small.neumorphism")
    
    private let backgroundDimView: UIView = {
        let view = UIView()
        view.backgroundColor = .dimB
        view.alpha = 0
        return view
    }()
    
    private let cancelRotatingButton: NeumorphicButton = {
        let button = NeumorphicButton(color: .crayon, type: .smallShadow)
        button.layer.cornerRadius = 20
        return button
    }()
    
    private lazy var cancelRotatingButtonContainingImageView: UIImageView = {
        let imageView = UIImageView(imageName: "x.neumorphism")
        cancelRotatingButton.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(22)
        }
        return imageView
    }()
    
    private let plusIconImageView = UIImageView(imageName: "plus.neumorphism")
    
    //MARK: - Logics
    let newGoalSavedSubject = PublishSubject<Goal>()

    let viewDismissSubject = PublishSubject<Void>()
    
    var goalDeletedIdentifierSubject = PublishSubject<String>()
    
    let disposeBag = DisposeBag()
    
    var selectedGoalIdentifier: String?
    var selectedGoalTitle: String?
    
    var presentCalendarViewCompletion: (()->Void)?
    
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
        
        calendarButton.addTarget(self, action: #selector(calendarButtonTapped(_:)), for: .touchUpInside)
        deleteGoalButton.addTarget(self, action: #selector(deleteGoalButtonTapped(_:)), for: .touchUpInside)
        addGoalButton.addTarget(self, action: #selector(addGoalButtonTapped(_:)), for: .touchUpInside)
    }
    
    @objc private func calendarButtonTapped(_ sender: UIButton) {
        cancelButtonActionWithAnimation()
        
        presentCalendarViewCompletion?()
    }
    
    @objc private func deleteGoalButtonTapped(_ sender: UIButton) {
        guard let title = selectedGoalTitle, let id = selectedGoalIdentifier else {
            GTAlertViewController()
                .make(
                    subTitle: "There is no goal to delete.",
                    subTitleFont: .sfPro(size: 14, family: .Medium),
                    buttonText: "Close"
                )
                .show()
            return
        }
        
        GTAlertViewController()
            .make(
                title: "Delete Goal",
                titleFont: .sfPro(size: 14, family: .Medium),
                subTitle: "\(title.filter({ !$0.isNewline }))",
                subTitleFont: .sfPro(size: 14, family: .Light),
                text: "** Deleted goals can not be recovered.",
                textFont: .sfPro(size: 12, family: .Light),
                buttonText: "Delete",
                cancelButtonText: "Cancel",
                buttonTextColor: .redA
            )
            .addAction {
                GoalManager.shared.deleteGoal(with: id)
                
                self.goalDeletedIdentifierSubject.onNext(id)
                self.dismiss(animated: false)
            }
            .show()
    }
    
    @objc private func addGoalButtonTapped(_ sender: UIButton) {
//        guard GoalRealmManager.shared.numberOfGoals < 5 else {
//            GTAlertViewController()
//                .make(
//                    subTitle: "Maximum number of goal is five.",
//                    subTitleFont: .sfPro(size: 14, family: .Medium),
//                    buttonText: "Confirm"
//                )
//                .addCancelAction {
//                }
//                .onCompletion {
//                }
//                .show()
//            
//            return
//        }
//
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
            self.cancelRotatingButtonContainingImageView.transform = CGAffineTransform(rotationAngle: -135.pi.cgFloat)
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
            self.cancelRotatingButtonContainingImageView.alpha = 1
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
        
        [calendarButton, deleteGoalButton, addGoalButton]
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
        
        calendarButton.snp.makeConstraints { make in
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
            make.bottom.equalToSuperview().inset((K.hasNotch ? 120 : 86)*K.ratioFactor)
        }

        plusIconImageView.snp.makeConstraints { make in
            make.center.equalTo(cancelRotatingButton)
            make.size.equalTo(22)
        }
    }
}

extension PlusMenuViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {

        return PresentationController(contentHeight: K.screenHeight*0.8, presentedViewController: presented, presenting: presenting)
    }
}

