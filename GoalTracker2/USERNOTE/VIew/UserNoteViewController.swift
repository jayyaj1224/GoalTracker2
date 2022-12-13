//
//  NoteViewController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 02/12/2022.
//

import UIKit
import RxSwift

class UserNoteViewController: UIViewController {
    //MARK: - UI Components
    private let userNoteContentView: NeumorphicView = {
        let view = NeumorphicView(backgroundColor: .crayon, type: .mediumShadow)
        view.layer.cornerRadius = 22
        return view
    }()
    
    private let messageBar = MessageBar(neumorphicType: .mediumShadow)
    
    private let noteTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Note"
        label.textColor = .grayC
        label.font = .outFit(size: 16, family: .Semibold)
        label.lineBreakMode = .byCharWrapping
        return label
    }()
    
    private let noteTypeTextField: UITextField = {
        let textField = UITextField()
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.grayA.cgColor
        textField.setLeftPaddingPoints(10)
        textField.setRightPaddingPoints(5)
        textField.backgroundColor = .crayon
        textField.font = .outFit(size: 17, family: .Light)
        return textField
    }()
    
    private let wordCountLabel: UILabel = {
        let label = UILabel()
        label.text = "(0 /100)"
        label.textColor = .grayB
        label.font = .outFit(size: 13, family: .Medium)
        return label
    }()
    
    private let noteTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(UserNoteCell.self, forCellReuseIdentifier: "GoalNoteCell")
        tableView.separatorColor = .grayA
        return tableView
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "􀎸 Empty."
        label.textColor = .grayA
        label.font = .sfPro(size: 20, family: .Semibold)
        label.isHidden = true
        return label
    }()
    
    private let closePanGestureView = UIView()
    
    private let closeButton: UIButton = {
        let button = UIButton()
        let attributedString = NSMutableAttributedString(
            string: "Close",
            attributes: [
                NSMutableAttributedString.Key.font: UIFont.outFit(size: 19, family: .Regular),
                NSMutableAttributedString.Key.foregroundColor: UIColor.white
            ]
        )
        button.contentHorizontalAlignment = .trailing
        button.setAttributedTitle(attributedString, for: .normal)
        button.alpha = 0
        return button
    }()
    
    //MARK: - Logic
    let noteViewModel: UserNoteViewModel
    
    let disposeBag = DisposeBag()
    
    init(goalIdentifier: String) {
        noteViewModel = UserNoteViewModel(goalIdentifier: goalIdentifier)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialUISetting()
        
        tableViewBinding()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.8) {
            self.messageBar.transform = .identity
            self.userNoteContentView.transform = .identity
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) { self.closeButton.alpha = 1 }
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}

//MARK: UITextField Delgate
extension UserNoteViewController: UITextFieldDelegate {
    private func bindTextField() {
        noteTypeTextField.rx.text
            .subscribe(onNext: { text in
                var text = text ?? ""
                let textCount = text.count
                
                if textCount > 100 {
                    let endIndex = text.index(text.startIndex, offsetBy: 100)
                    text = String(text[..<endIndex])
                    self.noteTypeTextField.text = text
                } else {
                    self.wordCountLabel.text = "(\(textCount) /100)"
                }
            })
            .disposed(by: disposeBag)
        
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return false }
        let newLength = text.count + string.count - range.length
        if newLength > 100 && range.location < 100 {
            return false
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let note = textField.text ?? ""
        let filtered = note.filter { !$0.isWhitespace }
        
        noteTypeTextField.text = ""
        
        guard !filtered.isEmpty else {
            return false
        }
        
        noteViewModel.addNewNote(note)
        return true
    }
}

//MARK: -
extension UserNoteViewController {
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
}

//MARK: - MessageBar
extension UserNoteViewController {
    private func bindMessageBarToTableView() {
        noteViewModel.tableViewDatasourceRelay
            .bind { [weak self] noteArray in
                self?.messageBar.configure(with: noteArray)
            }
            .disposed(by: disposeBag)
    }
}

//MARK: - TableView Datsource & Delegate
extension UserNoteViewController: UITableViewDelegate {
    private func tableViewBinding() {
        noteViewModel.tableViewDatasourceRelay
            .bind(to: noteTableView.rx.items) { tv, row, note in
                guard let cell = tv.dequeueReusableCell(withIdentifier: "GoalNoteCell", for: IndexPath(row: row, section: 0)) as? UserNoteCell else { return UITableViewCell() }
                
                cell.configure(with: note, at: row)
                
                return cell
            }
            .disposed(by: disposeBag)
        
        noteTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            self.noteViewModel.deleteNote(at: indexPath.row)
            
            success(true)
        })
        deleteAction.image =  UIImage(systemName: "trash")?
            .withTintColor(.grayC)
            .withSize(CGSize(width: 20, height: 20))
        deleteAction.backgroundColor = .lightGrayA
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let pinAction = UIContextualAction(style: .destructive, title: "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            self.noteViewModel.keyButtonTapped(at: indexPath.row)
            success(true)
        })
        
        pinAction.image = UIImage(systemName: "key.horizontal")?
            .withTintColor(.grayB)
            .withSize(CGSize(width: 28, height: 16))
        
        pinAction.backgroundColor = .lightGrayA
        
        return UISwipeActionsConfiguration(actions: [pinAction])
    }
}

//MARK: - Initial UI Setting
extension UserNoteViewController {
    private func initialUISetting() {
        configure()
        layout()
        
        bindMessageBarToTableView()
        bindTextField()
        
        emptySettingIfNeeded()
        
        messageBar.transform = CGAffineTransform(translationX: 0, y: 100)
        userNoteContentView.transform = CGAffineTransform(translationX: 0, y: 50)
    }
    
    private func configure() {
        view.backgroundColor = .clear
        
        noteTypeTextField.delegate = self
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handleDismiss))
        closePanGestureView.addGestureRecognizer(panGestureRecognizer)
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    private func emptySettingIfNeeded() {
        if noteViewModel.tableViewDatasourceRelay.value.isEmpty {
            messageBar.setGoalEmptyMessage()
            emptyLabel.isHidden = false
//            noteTypeTextField.isEnabled = false
        }
    }
    
    private func layout() {
        [messageBar, userNoteContentView, closePanGestureView, closeButton]
            .forEach(view.addSubview)
        
        messageBar.snp.makeConstraints { make in
            make.height.equalTo(60*K.ratioFactor)
            make.leading.trailing.equalToSuperview().inset(18)
            make.top.equalToSuperview().inset(40)
        }
        
        let vcHeight = K.screenHeight*0.7
        userNoteContentView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(18)
            make.top.equalTo(messageBar.snp.bottom).offset(15)
            make.height.equalTo(vcHeight-(50*K.ratioFactor)-90)
        }
        
        closePanGestureView.snp.makeConstraints { make in
            make.leading.trailing.top.equalToSuperview()
            make.bottom.equalTo(messageBar)
        }
        
        closeButton.snp.makeConstraints { make in
            make.trailing.equalTo(messageBar).offset(-12)
            make.bottom.equalTo(messageBar.snp.top).offset(1)
            make.width.equalTo(60)
        }
        
        [noteTitleLabel, noteTypeTextField, wordCountLabel, noteTableView, emptyLabel]
            .forEach(userNoteContentView.addSubview)

        noteTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(22)
            make.top.equalToSuperview().inset(10)
        }

        noteTypeTextField.snp.makeConstraints { make in
            make.height.equalTo(40)
            make.top.equalToSuperview().inset(38)
            make.leading.trailing.equalToSuperview().inset(25)
        }

        wordCountLabel.snp.makeConstraints { make in
            make.trailing.equalTo(noteTypeTextField)
            make.top.equalTo(noteTypeTextField.snp.bottom).offset(2)
        }

        noteTableView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.top.equalTo(noteTypeTextField.snp.bottom).offset(20)
            make.bottom.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

