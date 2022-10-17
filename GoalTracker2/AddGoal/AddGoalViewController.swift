//
//  AddGoalViewController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 18/09/2022.
//

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
        let attributedString = NSMutableAttributedString(
            string: "Save",
            attributes: [
                NSMutableAttributedString.Key.font: UIFont.sfPro(size: 16, family: .Light),
                NSMutableAttributedString.Key.foregroundColor: UIColor.orangeA
            ]
        )
        button.setAttributedTitle(attributedString, for: .normal)
        return button
    }()
    
    private let goalInputSectorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Goal Title 0 /50"
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
    
    private let descriptionInputTextView: UITextView = {
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
        label.font = .sfPro(size: 15, family: .Medium)
        return label
    }()
    
    private let yearlyTrackSwitchLabel: UILabel = {
        let label = UILabel()
        label.text = "yearly track"
        label.textColor = .grayB
        label.font = .sfPro(size: 13, family: .Medium)
        return label
    }()
    
    private let yearlyTrackSwitch = NeumorphicSwitch(toggleAnimationType: .withSpring, size: CGSize(width: 48, height: 20))
    
    private let daysSettingPickerView = UIPickerView()
    
    //MARK: - Logics
    private let periodSettingViewModel = PeriodSettingViewModel()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        datasourcesDelegatesSettings()
        uiSettings()
        bindings()
        
        addActionTargets()
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
        dismiss(animated: true, completion: nil)
    }
    
    @objc func handleDismiss(sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: view?.window)
        
        let modalScreenHieght = K.screenHeight*0.7
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
    
    private func bindings() {
        yearlyTrackSwitch.isOnSubjuect.subscribe(onNext: { [weak self] onOffValue in
            
            self?.changeTrackTypeLabel(trackAnually: onOffValue)
            
        })
        .disposed(by: disposeBag)
        
        let vm = periodSettingViewModel
        
//        daysSettingPickerView.rx.itemSelected
        
    }
    
    private func aimedPeriodPickerSettings() {
        periodSettingViewModel.datasourceRelay
            .bind(to: daysSettingPickerView.rx.dataSource) { (row, element, view) in
                let reuseView = (view as? AddGoalDatePickerRowView) ?? AddGoalDatePickerRowView()
                reuseView.rowLabel.text = " -- \(row)"
                return reuseView
            }
            .disposed(by: disposeBag)
       
        
        /*
         let items = Observable.just([
                "First Item",
                "Second Item",
                "Third Item"
            ])
         
         items
            .bind(to: pickerView.rx.items) { (row, element, view) in
                guard let myView = view as? MyView else {
                    let view = MyView()
                    view.configure(with: element)
                    return view
                }
                myView.configure(with: element)
                return myView
            }
            .disposed(by: disposeBag)
         
         */
        
    }
    
    private func changeTrackTypeLabel(trackAnually: Bool) {
        if trackAnually {
            self.aimedPeriodSectionLabel.text = "Track Annually"
        } else {
            self.aimedPeriodSectionLabel.text = "Aimed Period"
        }
    }
    
    private func datasourcesDelegatesSettings() {
        goalTitleInputTextView.delegate = self
        descriptionInputTextView.delegate = self
    }
}

//MARK: UIPickerView Datasource & Delgate
extension AddGoalViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let reuseView = (view as? AddGoalDatePickerRowView) ?? AddGoalDatePickerRowView()
        reuseView.rowLabel.text = " -- \(row)"
        return reuseView
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    /*
     1-10
     10, 20, ... 110 ... 990, 1000
     */
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            if yearlyTrackSwitch.isOn {
                return 1
            } else {
                return 1001
            }
        case 1:
            return 1000
        default:
            return 0
        }
    }
}

//MARK: UITextView Delgate
extension AddGoalViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if textView === goalTitleInputTextView {
            goalTitleTextViewDidChange(textView)
        }
        if textView === descriptionInputTextView {
            descriptionTextViewDidChange(textView)
        }
    }
    
    private func goalTitleTextViewDidChange(_ textView: UITextView) {
        var text = textView.text ?? ""
        
        goalInputTextViewPlaceholder.isHidden = text.isEmpty ? false : true
        
        if text.count > 50 {
            let endIndex = text.index(text.startIndex, offsetBy: 50)
            text = String(text[..<endIndex])
            goalTitleInputTextView.text = text
        } else {
            let characterCount = goalTitleInputTextView.text.count
            goalInputSectorTitleLabel.text = "Goal Title (\(characterCount) /50)"
        }
    }
    
    private func descriptionTextViewDidChange(_ textView: UITextView) {
        var text = textView.text ?? ""
        
        descriptionInputTextViewPlaceholder.isHidden = text.isEmpty ? false : true
        
        if text.count > 100 {
            let endIndex = text.index(text.startIndex, offsetBy: 100)
            text = String(text[..<endIndex])
            descriptionInputTextView.text = text
        } else {
            let characterCount = descriptionInputTextView.text.count
            descriptionInputSectorTitleLabel.text = "Description (optional) 􀁜  \(characterCount) /100"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var maximumTextLength = 0
        
        if textView === goalTitleInputTextView {
            maximumTextLength = 50
        }
        if textView === descriptionInputTextView {
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
        
        if textView === descriptionInputTextView {
            descriptionTextViewEndShadowView.isHidden = false
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView === goalTitleInputTextView {
            goalTitleTextViewEndShadowView.isHidden = true
        }
        
        if textView === descriptionInputTextView {
            descriptionTextViewEndShadowView.isHidden = true
        }
    }
}

//MARK: Initial UI Setting
extension AddGoalViewController {
    private func uiSettings() {
        view.backgroundColor = .crayon
        
        daysSettingPickerView.selectRow(9, inComponent: 0, animated: false)
        daysSettingPickerView.selectRow(9, inComponent: 1, animated: false)
        
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
            descriptionInputTextView,
            descriptionInputTextViewPlaceholder,
            descriptionTextViewEndShadowView,
            
            yearlyTrackSwitchLabel,
            yearlyTrackSwitch,
            
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
        
        descriptionInputTextView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(descriptionSectionDivider).inset(2)
            make.height.equalTo(120)
        }
        
        descriptionInputTextViewPlaceholder.snp.makeConstraints { make in
            make.trailing.equalTo(descriptionInputTextView)
            make.leading.equalTo(descriptionInputTextView).inset(6)
            make.top.equalTo(descriptionInputTextView).inset(10)
        }
        
        descriptionTextViewEndShadowView.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalTo(descriptionSectionDivider)
            make.height.equalTo(2)
        }
        
        yearlyTrackSwitchLabel.snp.makeConstraints { make in
            make.centerY.equalTo(yearlyTrackSwitch)
            make.trailing.equalTo(yearlyTrackSwitch.snp.leading).offset(-6)
        }
        
        yearlyTrackSwitch.snp.makeConstraints { make in
            make.bottom.equalTo(daysNumberSettingSectionDivider.snp.top).offset(-3.5)
            make.trailing.equalToSuperview().inset(15)
        }
        
        // daysNumberSettingSection
        daysNumberSettingSectionDivider.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(descriptionInputTextView.snp.bottom).offset(20)
        }
        
        aimedPeriodSectionLabel.snp.makeConstraints { make in
            make.bottom.equalTo(daysNumberSettingSectionDivider.snp.top).offset(-6)
            make.leading.equalTo(daysNumberSettingSectionDivider.snp.leading).offset(4)
        }
        
        daysSettingPickerView.snp.makeConstraints { make in
            make.top.equalTo(daysNumberSettingSectionDivider.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(30)
            make.height.equalTo(200)
        }
    }
}
