//
//  AddGoalViewController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 18/09/2022.
//

import UIKit


class AddGoalViewController: UIViewController {
    //MARK: - Components SubClass
    
    
    //MARK: - UI Components
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
        label.text = "Goal Title (0 /100)"
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
    
    private let descriptionInputSectorTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Description (optional) 􀁜"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        goalTitleInputTextView.delegate = self
        descriptionInputTextView.delegate = self
        
        goalTitleInputTextView.becomeFirstResponder()
    }
    
    //MARK: - Button Actions
    @objc private func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func saveButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: - View Setting
    private func setupView() {
        view.backgroundColor = .crayon
        
        layoutComponents()
        
        addButtonTargets()
    }
    
    private func addButtonTargets() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped(_:)), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped(_:)), for: .touchUpInside)
        
    }
    
    private func layoutComponents() {
        let sectionDivider: ()-> UIView = {
            let view = UIView()
            view.backgroundColor = .grayA
            return view
        }
        
        /// Under the cancel, save button
        let goalTitleSectionDivider = sectionDivider()
        
        /// Under the goal input textView
        let descriptionSectionDivider = sectionDivider()
        
        [
            cancelButton, saveButton,
            
            goalInputSectorTitleLabel,
            goalTitleSectionDivider,
            goalInputTextViewPlaceholder,
            goalTitleInputTextView,
//            characterCountLabel,
            
            descriptionInputSectorTitleLabel,
            descriptionSectionDivider,
            descriptionInputTextView,
            descriptionInputTextViewPlaceholder
            
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
        
        goalInputSectorTitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(goalTitleSectionDivider.snp.top).offset(-3)
            make.leading.equalTo(goalTitleSectionDivider.snp.leading).offset(4)
        }
        
        goalTitleSectionDivider.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(100)
        }
        
        goalTitleInputTextView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(goalTitleSectionDivider).inset(5)
            make.height.equalTo(80)
        }
        
        goalInputTextViewPlaceholder.snp.makeConstraints { make in
            make.trailing.equalTo(goalTitleInputTextView)
            make.leading.equalTo(goalTitleInputTextView).inset(6)
            make.top.equalTo(goalTitleInputTextView).inset(10)
        }
        
        descriptionInputSectorTitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(descriptionSectionDivider.snp.top).offset(-3)
            make.leading.equalTo(descriptionSectionDivider.snp.leading).offset(4)
        }
        
        descriptionSectionDivider.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(goalTitleSectionDivider.snp.bottom).offset(140)
        }
        
        descriptionInputTextView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(descriptionSectionDivider).inset(5)
            make.height.equalTo(80)
        }
        
        descriptionInputTextViewPlaceholder.snp.makeConstraints { make in
            make.trailing.equalTo(descriptionInputTextView)
            make.leading.equalTo(descriptionInputTextView).inset(6)
            make.top.equalTo(descriptionInputTextView).inset(10)
        }
    }
}

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
        
        if text.count > 80 {
            let endIndex = text.index(text.startIndex, offsetBy: 80)
            text = String(text[..<endIndex])
            goalTitleInputTextView.text = text
        } else {
            let characterCount = goalTitleInputTextView.text.count
            goalInputSectorTitleLabel.text = "Goal Title (\(characterCount) /80)"
        }
    }
    
    private func descriptionTextViewDidChange(_ textView: UITextView) {
        var text = textView.text ?? ""
        
        descriptionInputTextViewPlaceholder.isHidden = text.isEmpty ? false : true
        
        if text.count > 150 {
            let endIndex = text.index(text.startIndex, offsetBy: 150)
            text = String(text[..<endIndex])
            descriptionInputTextView.text = text
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        var maximumTextLength = 0
        
        if textView === goalTitleInputTextView {
            maximumTextLength = 80
        }
        if textView === descriptionInputTextView {
            maximumTextLength = 150
        }
        
        guard let textViewText = textView.text else { return false }
        
        let newLength = textViewText.count + text.count - range.length
        if newLength > maximumTextLength && range.location < maximumTextLength {
            return false
        }
        return true
    }
}

