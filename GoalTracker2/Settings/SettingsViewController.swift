//
//  SettingsViewController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 22/09/2022.
//

import UIKit

class SettingsViewController: UIViewController {
    private let backButton: UIButton = {
        var configuration = UIButton.Configuration.plain()
        configuration.image = UIImage(named: "back.bracket")
        configuration.imagePadding = 8
        let button = UIButton()
        button.configuration = configuration
        return button
    }()
    
    private let settingsLabel: UILabel = {
        let label = UILabel()
        label.text = "Settings"
        label.font = .sfPro(size: 15, family: .Semibold)
        return label
    }()
    
    private let scoreViewTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "ScoreViewType"
        label.font = .sfPro(size: 13, family: .Semibold)
        return label
    }()
    
    private let scoreViewTypePicker = UIPickerView()
    
    private let vibrateSettingLabel: UILabel = {
        let label = UILabel()
        label.text = "Vibrate"
        label.font = .sfPro(size: 13, family: .Semibold)
        return label
    }()
    
    private let vibrateSwitch = NeumorphicSwitch(
        toggleAnimationType: .withSpring,
        size: CGSize(width: 48, height: 20),
        onAction: {
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    )
    
    private let resetLabel: UILabel = {
        let label = UILabel()
        label.text = "Reset"
        label.font = .sfPro(size: 13, family: .Semibold)
        return label
    }()
    
    private let resetButton: UIButton = {
        let button = NeumorphicButton(color: .crayon, shadowSize: .medium)
        button.layer.cornerRadius = 6
        
        let attributedString = NSMutableAttributedString(
            string: "Delete all",
            attributes: [
                NSMutableAttributedString.Key.font: UIFont.sfPro(size: 11, family: .Medium),
                NSMutableAttributedString.Key.foregroundColor: UIColor.black
            ]
        )
        let attributedStringDisabled = NSMutableAttributedString(
            string: "Delete all",
            attributes: [
                NSMutableAttributedString.Key.font: UIFont.sfPro(size: 11, family: .Medium),
                NSMutableAttributedString.Key.foregroundColor: UIColor.grayA
            ]
        )
        button.setAttributedTitle(attributedString, for: .normal)
        button.setAttributedTitle(attributedStringDisabled, for: .disabled)
        
        return button
    }()
    
    
    
    private let aboutLabel: UILabel = {
        let label = UILabel()
        label.text = "About"
        label.font = .sfPro(size: 13, family: .Semibold)
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    @objc private func backButtonTapped(_ sender: UIButton) {
        saveScorePannelTypeSettings()
        
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func resetButtonTapped(_ sender: UIButton) {
        GTAlertViewController()
            .make(
                title: "Reset",
                titleFont: .sfPro(size: 14, family: .Medium),
                subTitle: "Are you sure delete everything?",
                subTitleFont: .sfPro(size: 14, family: .Light),
                text: "** It can not be recovered.",
                textFont: .sfPro(size: 12, family: .Light),
                buttonText: "Delete",
                cancelButtonText: "Cancel",
                buttonTextColor: .redA
            )
            .addAction { [weak self] in
                GoalRealmManager.shared.deleteAll()
                self?.resetButton.isEnabled = false
                self?.view.makeToast("Complete.", position: .center)
            }
            .show()
    }
    
    private func saveScorePannelTypeSettings() {
        switch scoreViewTypePicker.selectedRow(inComponent: 0) {
        case 0: Settings.shared.scorePannelType = .Digital
        case 1: Settings.shared.scorePannelType = .Flap
        default: break
        }
    }
    
    private func saveVibrateSettings() {
        Settings.shared.vibrate = vibrateSwitch.isOn
    }
}

extension SettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 30
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        if row == 0 { return pickerComponentView("digital") }
        
        if row == 1 { return pickerComponentView("flap") }
        
        return UIView()
    }
    
    private func pickerComponentView(_ text: String) -> UIView {
        let view = UIView()
        let label = UILabel()
        label.text = text
        label.textColor = .grayC
        label.font = .sfPro(size: 14, family: .Regular)
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return view
    }
}


//MARK: - ui setting
extension SettingsViewController {
    private func configure() {
        view.backgroundColor = .crayon
        
        scoreViewTypePicker.dataSource = self
        scoreViewTypePicker.delegate = self
        
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        layoutComponents()
        
        scoreViewTypePicker.selectRow(Settings.shared.scorePannelType.rawValue, inComponent: 0, animated: false)
        
        if Settings.shared.vibrate {
            vibrateSwitch.on()
        } else {
            vibrateSwitch.off()
        }
    }
    
    private func layoutComponents() {
        let sectionDivider: ()-> UIView = {
            let view = UIView()
            view.backgroundColor = .grayA
            return view
        }
        
        let settingSectionStartDivider = sectionDivider()
        let settingSectionEndDivider = sectionDivider()
        
        [
            backButton,
            settingsLabel,
            settingSectionStartDivider,
            
            scoreViewTypeLabel,
            scoreViewTypePicker,
            
            vibrateSettingLabel, vibrateSwitch,
            
            settingSectionEndDivider,
            
            resetLabel, resetButton,
            
            aboutLabel
            
        ]
            .forEach(view.addSubview(_:))
        
        
        backButton.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.leading.equalToSuperview().offset(20)
            make.size.equalTo(35)
        }
        
        settingsLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(120)
            make.leading.equalToSuperview().inset(30)
        }
        
        settingSectionStartDivider.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(25)
            make.height.equalTo(1)
            make.top.equalTo(settingsLabel.snp.bottom).offset(8)
        }
        
        scoreViewTypeLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(30)
            make.top.equalTo(settingSectionStartDivider.snp.bottom).offset(15)
        }
        
        scoreViewTypePicker.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(50)
            make.height.equalTo(120)
            make.top.equalTo(scoreViewTypeLabel).offset(5)
        }
        
        vibrateSettingLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(30)
            make.top.equalTo(scoreViewTypePicker.snp.bottom).offset(20)
        }
        
        vibrateSwitch.snp.makeConstraints { make in
            make.leading.equalTo(vibrateSettingLabel.snp.trailing).offset(20)
            make.centerY.equalTo(vibrateSettingLabel).offset(2)
        }
        
        settingSectionEndDivider.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(25)
            make.height.equalTo(1)
            make.top.equalTo(vibrateSettingLabel.snp.bottom).offset(30)
        }
        
        resetLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(30)
            make.top.equalTo(settingSectionEndDivider.snp.bottom).offset(40)
        }
        
        resetButton.snp.makeConstraints { make in
            make.width.equalTo(80)
            make.height.equalTo(22)
            make.leading.equalTo(resetLabel.snp.trailing).offset(16)
            make.centerY.equalTo(resetLabel)
        }
        
        aboutLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(30)
            make.top.equalTo(resetLabel.snp.bottom).offset(100)
        }
    }
}

