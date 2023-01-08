//
//  AddGoalViewController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 18/09/2022.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class AddGoalViewController: UIViewController {
    //MARK: UI Components
    private let cancelButton: UIButton = {
        let button = UIButton()
        let attributedString = NSMutableAttributedString(
            string: "Cancel",
            attributes: [
                NSMutableAttributedString.Key.font: UIFont.sfPro(size: 16, family: .Light),
                NSMutableAttributedString.Key.foregroundColor: UIColor.grayB
            ]
        )
        button.setAttributedTitle(attributedString, for: .normal)
        return button
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        let enabledAttributedString = NSMutableAttributedString(
            string: "Save",
            attributes: [
                NSMutableAttributedString.Key.font: UIFont.sfPro(size: 16, family: .Light),
                NSMutableAttributedString.Key.foregroundColor: UIColor.orangeA
            ]
        )
        let disabledAttributedString = NSMutableAttributedString(
            string: "Save",
            attributes: [
                NSMutableAttributedString.Key.font: UIFont.sfPro(size: 16, family: .Light),
                NSMutableAttributedString.Key.foregroundColor: UIColor.grayB
            ]
        )
        button.setAttributedTitle(enabledAttributedString, for: .normal)
        button.setAttributedTitle(disabledAttributedString, for: .disabled)
        button.isEnabled = false
        return button
    }()
    
    private let goalInputSectorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Goal Title 0 /60"
        label.textColor = .grayB
        label.font = .sfPro(size: 13, family: .Medium)
        return label
    }()
    
    private let goalTitleInputTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .grayC
        textView.font = .sfPro(size: 18, family: .Light)
        textView.backgroundColor = .clear
        return textView
    }()
    
    private let goalInputTextViewPlaceholder: UILabel = {
        let label = UILabel()
        label.textColor = .grayA
        label.font = .outFit(size: 16, family: .Light)
        label.text = "Please enter your goal."
        return label
    }()
    
    private let goalTitleTextViewEndShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .crayon
        view.setDropShadow(customLayer: nil, color: .grayB, width: 0.6, height: 0.6, blur: 3, spread: -1, opacity: 0.5)
        view.isHidden = true
        return view
    }()
    
    private let descriptionInputSectorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Description (optional) 􀁜  0 /100"
        label.textColor = .grayB
        label.font = .sfPro(size: 13, family: .Medium)
        return label
    }()
    
    private let detailInputTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .grayC
        textView.font = .sfPro(size: 18, family: .Light)
        textView.backgroundColor = .clear
        return textView
    }()
    
    private let descriptionInputTextViewPlaceholder: UILabel = {
        let label = UILabel()
        label.textColor = .grayA
        label.font = .outFit(size: 16, family: .Light)
        label.text = "Additional info about your goal"
        return label
    }()
    
    private let descriptionTextViewEndShadowView: UIView = {
        let view = UIView()
        view.backgroundColor = .crayon
        view.setDropShadow(customLayer: nil, color: .grayB, width: 0.6, height: 0.6, blur: 3, spread: -1, opacity: 0.5)
        view.isHidden = true
        return view
    }()
    
    private let aimedPeriodSectionLabel: UILabel = {
        let label = UILabel()
        label.text = "Aimed Period"
        label.textColor = .grayB
        label.font = .sfPro(size: 13, family: .Medium)
        return label
    }()
    
    private let daysSettingPickerView = UIPickerView()
    
    //MARK: - Logics
    private let periodSettingViewModel = PeriodSettingViewModel()
    
    var saveButtonTappedSubject = PublishSubject<Goal>()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datasourcesDelegatesSettings()
        
        uiSettings()
        
        aimedPeriodPickerSettings()
        
        addActionTargets()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        periedPickerViewinitialSetting()
    }
    
    private func addActionTargets() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismiss))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveButtonTapped(_ sender: UIButton) {
        let goal = Goal(
            title: goalTitleInputTextView.text ?? "",
            detail: detailInputTextView.text ?? "",
            totalDays: daysSettingPickerView.selectedRow(inComponent: 0),
            failCap: daysSettingPickerView.selectedRow(inComponent: 1)-1
        )

        GoalManager.shared.realmWriteGoal(goal)
        
        saveButtonTappedSubject.onNext(goal)
        
        if let plusMenuViewController = self.presentingViewController {
            plusMenuViewController.view.alpha = 0
        }
        
        if let homeNavigationController = self.presentingViewController?.presentingViewController {
            homeNavigationController.dismiss(animated: true)
        }
        
        UserNoteManager.shared.saveNewGoalDefaultUserNote(goalIdentifier: goal.identifier)
    }
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: view?.window)
        
        let modalScreenHieght = K.screenHeight*0.8
        let initialHeightPoint = K.screenHeight-modalScreenHieght
        
        switch sender.state {
        case .changed:
            if touchPoint.y > initialHeightPoint {
                view.frame.origin.y = touchPoint.y
            }
        case .ended, .cancelled:
            if touchPoint.y - initialHeightPoint >  K.screenHeight*0.3 {
                dismiss(animated: true, completion: nil)
                
            } else {
                UIView.animate(
                    withDuration: 0.2,
                    animations: {
                        self.view.frame = CGRect(
                            x: 0,
                            y: K.screenHeight-modalScreenHieght,
                            width: self.view.frame.size.width,
                            height: self.view.frame.size.height
                        )
                    }
                )
            }
            
        default:
            break
        }
    }
    
    private func checkAbleToSave() {
        let goalTitleText = (goalTitleInputTextView.text ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        if goalTitleText.isEmpty {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
    }
}

//MARK: Datasource & Delegate setting
extension AddGoalViewController {
    private func datasourcesDelegatesSettings() {
        goalTitleInputTextView.delegate = self
        detailInputTextView.delegate = self
    }
    
    private func periedPickerViewinitialSetting() {
        daysSettingPickerView.selectRow(99, inComponent: 0, animated: false)
        daysSettingPickerView.selectRow(99, inComponent: 1, animated: false)
    }
    
    private func aimedPeriodPickerSettings() {
        let vm = periodSettingViewModel
        
        vm.datasourceRelay
            .bind(to: daysSettingPickerView.rx.items(adapter: vm.viewPickerAdapter))
            .disposed(by: disposeBag)

        //pickerView row height
        Observable.just(40)
            .bind(to: daysSettingPickerView.rx.rowHeight)
            .disposed(by: disposeBag)

        //pickerView row width
        Observable.just(140)
            .bind(to: daysSettingPickerView.rx.rowWidth)
            .disposed(by: disposeBag)
        
        let pickerItemSelected = daysSettingPickerView.rx.itemSelected.share()
        
        let totalDaysSelected = pickerItemSelected
            .filter { $0.component == 0 }
        
        let maxFailSelected = pickerItemSelected
            .filter { $0.component == 1 }
        
        totalDaysSelected
            .map { $0.row+1 }
            .bind(to: vm.rx.shouldChangeMaxFailRange)
            .disposed(by: disposeBag)
        
        maxFailSelected
            .subscribe(onNext: { [weak self] _ in
                self?.daysSettingPickerView.reloadComponent(1)
            })
            .disposed(by: disposeBag)
    }
}


//MARK: UITextView Delgate
extension AddGoalViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === goalTitleInputTextView {
            goalTitleTextViewDidChange(textView)
        }
        if textView === detailInputTextView {
            descriptionTextViewDidChange(textView)
        }
    }
    
    private func goalTitleTextViewDidChange(_ textView: UITextView) {
        var text = textView.text ?? ""
        
        goalInputTextViewPlaceholder.isHidden = text.isEmpty ? false : true
        
        if text.count > 60 {
            let endIndex = text.index(text.startIndex, offsetBy: 60)
            text = String(text[..<endIndex])
            goalTitleInputTextView.text = text
        } else {
            let characterCount = goalTitleInputTextView.text.count
            goalInputSectorTitleLabel.text = "Goal Title (\(characterCount) /60)"
        }
        
        checkAbleToSave()
    }
    
    private func descriptionTextViewDidChange(_ textView: UITextView) {
        var text = textView.text ?? ""
        
        descriptionInputTextViewPlaceholder.isHidden = text.isEmpty ? false : true
        
        if text.count > 100 {
            let endIndex = text.index(text.startIndex, offsetBy: 100)
            text = String(text[..<endIndex])
            detailInputTextView.text = text
        } else {
            let characterCount = detailInputTextView.text.count
            descriptionInputSectorTitleLabel.text = "Description (optional)  \(characterCount) /100"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var maximumTextLength = 0
        
        if textView === goalTitleInputTextView {
            maximumTextLength = 60
        }
        if textView === detailInputTextView {
            maximumTextLength = 100
        }
        
        guard let textViewText = textView.text else { return false }
        
        let newLength = textViewText.count + text.count - range.length
        if newLength > maximumTextLength && range.location < maximumTextLength {
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView === goalTitleInputTextView {
            goalTitleTextViewEndShadowView.isHidden = false
        }
        
        if textView === detailInputTextView {
            descriptionTextViewEndShadowView.isHidden = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView === goalTitleInputTextView {
            goalTitleTextViewEndShadowView.isHidden = true
        }
        
        if textView === detailInputTextView {
            descriptionTextViewEndShadowView.isHidden = true
        }
    }
}

//MARK: UI Setting
extension AddGoalViewController {
    private func uiSettings() {
        view.backgroundColor = .crayon
        
        layoutComponents()
    }

    private func layoutComponents() {
        let sectionDivider: ()-> UIView = {
            let view = UIView()
            view.backgroundColor = .grayA
            return view
        }
        
        /// Under the cancel, save button
        let goalTitleSectionDivider = sectionDivider()
        
        /// Under the description input section title
        let descriptionSectionDivider = sectionDivider()
        
        /// Under the number of days input section title
        let daysNumberSettingSectionDivider = sectionDivider()
        
        [
            cancelButton, saveButton,
            
            goalInputSectorTitleLabel,
            goalTitleSectionDivider,
            goalInputTextViewPlaceholder,
            goalTitleInputTextView,
            goalTitleTextViewEndShadowView,
            
            descriptionInputSectorTitleLabel,
            descriptionSectionDivider,
            detailInputTextView,
            descriptionInputTextViewPlaceholder,
            descriptionTextViewEndShadowView,
            
//            yearlyTrackSwitchLabel,
//            yearlyTrackSwitch,
            
            aimedPeriodSectionLabel,
            daysNumberSettingSectionDivider,
            daysSettingPickerView
            
        ].forEach {
            view.addSubview($0)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(15)
        }
        
        saveButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(15)
        }
        
        //goalTitleSection
        goalTitleSectionDivider.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(80)
        }
        
        goalInputSectorTitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(goalTitleSectionDivider.snp.top).offset(-3)
            make.leading.equalTo(goalTitleSectionDivider.snp.leading).offset(4)
        }
        
        goalTitleInputTextView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(goalTitleSectionDivider).inset(2)
            make.height.equalTo(100)
        }
        
        goalInputTextViewPlaceholder.snp.makeConstraints { make in
            make.trailing.equalTo(goalTitleInputTextView)
            make.leading.equalTo(goalTitleInputTextView).inset(6)
            make.top.equalTo(goalTitleInputTextView).inset(10)
        }
        
        goalTitleTextViewEndShadowView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(goalTitleSectionDivider)
            make.height.equalTo(2)
        }
        
        // descriptionSection
        descriptionSectionDivider.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(goalTitleInputTextView.snp.bottom)
        }
        
        descriptionInputSectorTitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(descriptionSectionDivider.snp.top).offset(-3)
            make.leading.equalTo(descriptionSectionDivider.snp.leading).offset(4)
        }
        
        detailInputTextView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(descriptionSectionDivider).inset(2)
            make.height.equalTo(120)
        }
        
        descriptionInputTextViewPlaceholder.snp.makeConstraints { make in
            make.trailing.equalTo(detailInputTextView)
            make.leading.equalTo(detailInputTextView).inset(6)
            make.top.equalTo(detailInputTextView).inset(10)
        }
        
        descriptionTextViewEndShadowView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(descriptionSectionDivider)
            make.height.equalTo(2)
        }
        
//        yearlyTrackSwitchLabel.snp.makeConstraints { make in
//            make.centerY.equalTo(yearlyTrackSwitch)
//            make.trailing.equalTo(yearlyTrackSwitch.snp.leading).offset(-6)
//        }
//
//        yearlyTrackSwitch.snp.makeConstraints { make in
//            make.bottom.equalTo(daysNumberSettingSectionDivider.snp.top).offset(-3.5)
//            make.trailing.equalToSuperview().inset(15)
//        }
        
        // daysNumberSettingSection
        daysNumberSettingSectionDivider.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(detailInputTextView.snp.bottom).offset(20)
        }
        
        aimedPeriodSectionLabel.snp.makeConstraints { make in
            make.bottom.equalTo(daysNumberSettingSectionDivider.snp.top).offset(-6)
            make.leading.equalTo(daysNumberSettingSectionDivider.snp.leading).offset(4)
        }
        
        daysSettingPickerView.snp.makeConstraints { make in
            make.top.equalTo(daysNumberSettingSectionDivider.snp.bottom).offset(10)
            make.leading.trailing.equalToSuperview().inset(20)
//            make.height.equalTo(200)
        }
    }
}
