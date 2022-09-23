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
                NSMutableAttributedString.Key.font: UIFont.sfPro(size: 18, family: .Light),
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
                NSMutableAttributedString.Key.font: UIFont.sfPro(size: 18, family: .Light),
                NSMutableAttributedString.Key.foregroundColor: UIColor.orangeA
            ]
        )
        button.setAttributedTitle(attributedString, for: .normal)
        return button
    }()
    
    private let goalInputTextView: UITextView = {
        let textView = UITextView()
        textView.font = .sfPro(size: 18, family: .Light)
        textView.backgroundColor = .clear
        return textView
    }()
    
    private let goalInputTextViewPlaceholder: UILabel = {
        let label = UILabel()
        label.textColor = .grayB
        label.alpha = 0.7
        label.font = .outFit(size: 18, family: .Light)
        label.text = "Please enter your goal."
        return label
    }()
    
    private let characterCountLabel: UILabel = {
        let label = UILabel()
        label.font = .outFit(size: 13, family: .Medium)
        label.textColor = .grayB
        label.text = "0 /100 Character"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        
        goalInputTextView.delegate = self
        goalInputTextView.becomeFirstResponder()
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
    
    private func componentDividerLine() -> UIView {
        let view = UIView()
        view.backgroundColor = .grayA
        return view
    }
    
    private func layoutComponents() {
        /// Under the cancel, save button
        let firstDividerLine = componentDividerLine()
        
        /// Under the goal input textView
        let secondDividerLine = componentDividerLine()
        
        [
            cancelButton, saveButton,
            firstDividerLine,
            goalInputTextViewPlaceholder,
            goalInputTextView,
            characterCountLabel,
            secondDividerLine
            
        ].forEach {
            view.addSubview($0)
        }
        
        cancelButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(25)
        }
        
        saveButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(20)
            make.top.equalToSuperview().inset(25)
        }
        
        firstDividerLine.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(goalInputTextView).offset(-9)
        }
        
        goalInputTextView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalToSuperview().inset(70)
            make.height.equalTo(120)
        }
        
        goalInputTextViewPlaceholder.snp.makeConstraints { make in
            make.trailing.equalTo(goalInputTextView)
            make.leading.equalTo(goalInputTextView).inset(6)
            make.top.equalTo(goalInputTextView).inset(10)
        }
        
        secondDividerLine.snp.makeConstraints { make in
            make.height.equalTo(0.5)
            make.leading.trailing.equalToSuperview().inset(15)
            make.top.equalTo(goalInputTextView.snp.bottom)
        }
        
        characterCountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(goalInputTextView)
            make.top.equalTo(goalInputTextView.snp.bottom).offset(6)
        }
    }
}

extension AddGoalViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        var text = textView.text ?? ""
        
        if text.isEmpty {
            goalInputTextViewPlaceholder.isHidden = false
        } else {
            goalInputTextViewPlaceholder.isHidden = true
        }
        
        if text.count > 100 {
            let endIndex = text.index(text.startIndex, offsetBy: 100)
            text = String(text[..<endIndex])
            textView.text = text
        } else {
            let characterCount = goalInputTextView.text.count
            characterCountLabel.text = "\(characterCount) /100 Character"
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard let textViewText = textView.text else { return false }
        
        let newLength = textViewText.count + text.count - range.length
        if newLength > 100 && range.location < 100 {
            return false
        }
        return true
    }
}

