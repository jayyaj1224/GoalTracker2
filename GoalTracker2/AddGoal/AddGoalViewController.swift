//
//  AddViewController.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/06/18.
//

import UIKit
import RxSwift
import RxCocoa

final class AddGoalViewController: UIViewController {
    //MARK: - Components
    class SectionTitleLabel: UILabel {
        convenience init(_ title: String, lines: Int=0) {
            self.init(frame: .zero)
            text = title
            font = .noto(size: 17, family: .Light)
            textColor = .grayB
            textAlignment = .left
            numberOfLines = lines
        }
    }
    
    class PickerSelectView: UIView {
        let label = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            label.font = .noto(size: 14, family: .Light)
            label.textColor = .black
            
            self.addSubview(label)
            label.snp.makeConstraints { make in
                make.center.equalToSuperview()
            }
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    //MARK: - Top Components
    let slideIndicator = NeuphShadowView(cornerRadius: 2)
    
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_cancel"), for: .normal)
        button.setImage(UIImage(named: "icon_cancel"), for: .highlighted)
        button.alpha = 0.6
        return button
    }()
    
    //MARK: - Goal Track Type Section
    let trackTypeSectionTitleLabel = SectionTitleLabel("Goal Type")
    
    let trackTypeSelectPickerView = UIPickerView()
    
    
    //MARK: - Goal Text Section
    let goalSectionTitleLabel = SectionTitleLabel("Goal")
    
    let textFieldBackGroundView: UIView = {
        let view = UIView()
        let imageView = UIImageView()
        imageView.image = UIImage(named: "boxInnerShadow")
        view.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        return view
    }()
    
    let goalTextView: UITextView = {
        let textView = UITextView()
        textView.showsVerticalScrollIndicator = true
        textView.backgroundColor = .clear
        textView.textColor = .black
        textView.font = .noto(size: 14, family: .Light)
        return textView
    }()
    
    let goalPlaceHolderLabel: UILabel = {
        let label = UILabel()
        label.text = "What is your goal?"
        label.font = .noto(size: 14, family: .Regular)
        label.textColor = .crayon
        return label
    }()
    
    let textCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .grayB
        label.font = .noto(size: 12, family: .Regular)
        label.textAlignment = .right
        label.text = "0/100"
        return label
    }()
    
    //MARK: - Days Set Section
    private let daysTotalLabel = SectionTitleLabel("Days Total")
    
    let totalPickerView = UIPickerView()
    
    private let maxFailLabel = SectionTitleLabel("Set Maximum Fail Count")
    
    let maxFailPickerView = UIPickerView()
    
    let saveButton: NeuphShadowButton = {
        let button = NeuphShadowButton(cornerRadius: 10)
        let attString = NSMutableAttributedString(
            string: "Save",
            attributes: [
                NSAttributedString.Key.foregroundColor: UIColor.redA,
                NSAttributedString.Key.font: UIFont.noto(size: 16, family: .Regular)
            ]
        )
        button.setAttributedTitle(attString, for: .normal)
        return button
    }()
    
    //MARK: - Layout
    private func layout() {
        let contentsStackView = UIStackView()
        contentsStackView.axis = .vertical
        contentsStackView.distribution = .fill

        [contentsStackView, slideIndicator, saveButton]
            .forEach { self.view.addSubview($0) }
        
        contentsStackView.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.leading.trailing.equalToSuperview().inset(20)
        }
        
        slideIndicator.snp.makeConstraints { make in
            make.width.equalTo(120)
            make.height.equalTo(4)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(20)
        }

        let spacer: (CGFloat) -> UIView = { height in
            let view = UIView()
            view.snp.makeConstraints { make in
                make.height.equalTo(height)
            }
            return view
        }

        let viewComponentsStack = [
            // Goal Track Type
            trackTypeSectionTitleLabel,
            trackTypeSelectPickerView,
            
            // Goal Text
            goalSectionTitleLabel,
            spacer(10),
            textFieldBackGroundView,
            spacer(3),
            textCountLabel,
            spacer(7),
            
            // Days Total
            daysTotalLabel,
            totalPickerView,
            spacer(10),
            
            // Fail Cap
            maxFailLabel,
            maxFailPickerView
        ]
        
        trackTypeSelectPickerView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        viewComponentsStack
            .forEach { contentsStackView.addArrangedSubview($0) }
        
        textFieldBackGroundView.snp.makeConstraints { make in
            make.height.equalTo(73)
        }
        
        textFieldBackGroundView.addSubview(goalTextView)
        
        goalTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        
        totalPickerView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        maxFailPickerView.snp.makeConstraints { make in
            make.height.equalTo(100)
        }
        
        self.view.addSubview(closeButton)
        
        closeButton.snp.makeConstraints { make in
            make.size.equalTo(60)
            make.top.equalToSuperview().inset(5)
            make.trailing.equalToSuperview()
        }
        
        goalTextView.addSubview(goalPlaceHolderLabel)
        
        goalPlaceHolderLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(5)
            make.top.equalToSuperview().inset(7)
            make.trailing.equalToSuperview()
        }
        
        saveButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(300)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().inset(45)
        }
    }
    
    //MARK: - Logic
    var hasSetPointOrigin = false
    
    var pointOrigin: CGPoint?
    
    var newGoalAddedSubject = PublishSubject<Goal>()
    
    let viewModel = AddGoalViewModel()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        layout()
        bind()
        bindPickerViewDatasource()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.slideIndicator.setNeuphShadowSmall()
        self.saveButton.setNeuphShadowMedium()
    }
    
    override func viewDidLayoutSubviews() {
        if !hasSetPointOrigin {
            hasSetPointOrigin = true
            pointOrigin = self.view.frame.origin
        }
    }

    private func configure() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction))
        self.view.addGestureRecognizer(panGesture)
        self.view.backgroundColor = .crayon

        goalTextView.delegate = self
        
        saveButton.addTarget(self, action: #selector(saveGoalButtonTapped), for: .touchUpInside)
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private func bind() {
        goalTextView.rx.text
            .bind(to: self.rx.textFieldDidChange)
            .disposed(by: disposeBag)
    }
    
    private func bindPickerViewDatasource() {
        let vm = viewModel
        
        vm.goalTrackTypePickerDatasource
            .bind(to: trackTypeSelectPickerView.rx.items)(vm.trackTypePickerFactory)
            .disposed(by: disposeBag)
        
        vm.totalDaysDatasource
            .bind(to: totalPickerView.rx.items){ [weak self] row, num, view in
                self?.goalTextView.resignFirstResponder()
                return vm.daysSelectPickerFactory(row, num, view)
            }
            .disposed(by: disposeBag)
        
        viewModel.maxFailDatasource
            .bind(to: maxFailPickerView.rx.items)(vm.daysSelectPickerFactory)
            .disposed(by: disposeBag)
        
        totalPickerView.rx.itemSelected
            .subscribe(vm.totalDaysPickerViewValue)
            .disposed(by: disposeBag)
    }
    
    
    @objc func panGestureRecognizerAction(sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        guard translation.y >= 0 else { return }
        
        self.goalTextView.resignFirstResponder()
        
        view.frame.origin = CGPoint(x: 0, y: self.pointOrigin!.y + translation.y)
        
        if sender.state == .ended {
            let velocity = sender.velocity(in: view)
            if velocity.y >= 1300 {
                self.dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame.origin = self.pointOrigin ?? CGPoint(x: 0, y: 400)
                }
            }
        }
    }
    
    @objc func saveGoalButtonTapped() {
        goalTextView.endEditing(true)
        
        let trackTypePickerSelectedRow = trackTypeSelectPickerView.selectedRow(inComponent: 0)
        let trackType = GoalTrackType.init(rawValue: trackTypePickerSelectedRow)!
        
        let totalDaysPickerSelectedRow = totalPickerView.selectedRow(inComponent: 0)
        let totalDays = totalPickerView.view(forRow: totalDaysPickerSelectedRow, forComponent: 0)?.tag ?? 0
        
        let maxFail = maxFailPickerView.selectedRow(inComponent: 0)
        
        let goal = Goal(
            title: goalTextView.text!,
            totalDays: totalDays,
            failCap: maxFail,
            setType: trackType
        )
        
        GoalManager.shared.newGoal(goal)
        
        newGoalAddedSubject.onNext(goal)
        
        self.dismiss(animated: true)
    }
    
    @objc func closeButtonTapped() {
        self.dismiss(animated: true)
    }
}

extension AddGoalViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if (textView.text ?? "").count >= 100 && text != "" {
            return false
        }
        return true
    }
}

extension Reactive where Base: AddGoalViewController {
    var textFieldDidChange: Binder<String?> {
        Binder(base) { base, text in
            guard let text = text  else  { return }
            
            DispatchQueue.main.async {
                // placeholder label
                base.goalPlaceHolderLabel.isHidden = !text.isEmpty
                
                // text count label
                base.textCountLabel.text = "\(text.count)/100"
            }
        }
    }
}

