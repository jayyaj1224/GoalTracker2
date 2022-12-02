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
    private let noteTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Note"
        label.textColor = .grayC
        label.font = .sfPro(size: 14, family: .Semibold)
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
        textField.font = .sfPro(size: 16, family: .Light)
        return textField
    }()
    
    private let wordCountLabel: UILabel = {
        let label = UILabel()
        label.text = "(0 /100)"
        label.textColor = .grayB
        label.font = .sfPro(size: 13, family: .Medium)
        return label
    }()
    
    private let noteTableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .clear
        tableView.register(UserNoteCell.self, forCellReuseIdentifier: "GoalNoteCell")
        return tableView
    }()
    
    //MARK: - Logic
    private let noteViewModel: UserNoteViewModel
    
    private let disposeBag = DisposeBag()
    
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
        
        return true
    }
}

//MARK: - TableView Datsource & Delegate
extension UserNoteViewController: UITableViewDelegate {
    private func tableViewBinding() {
        noteViewModel.tableViewDatasourceRelay
            .bind(to: noteTableView.rx.items) { tv, row, note in
                guard let cell = tv.dequeueReusableCell(withIdentifier: "GoalNoteCell", for: IndexPath(row: row, section: 0)) as? UserNoteCell else { return UITableViewCell() }
                
                cell.configure(with: note)
                
                return cell
            }
            .disposed(by: disposeBag)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            success(true)
        })
        deleteAction.image =  UIImage(systemName: "trash")?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
        deleteAction.backgroundColor = .crayon
        
        let pinAction = UIContextualAction(style: .destructive, title: "", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
            
            success(true)
        })
        pinAction.image = UIImage(systemName: "key.horizontal")?.withTintColor(.darkGray, renderingMode: .alwaysOriginal)
        pinAction.backgroundColor = .crayon
        
        return UISwipeActionsConfiguration(actions: [deleteAction, pinAction])
    }
    
}

//MARK: - Initial UI Setting
extension UserNoteViewController {
    private func initialUISetting() {
        configure()
        layout()
        
        bindTextField()
    }
    
    private func configure() {
        view.backgroundColor = .crayon
        
        noteTypeTextField.delegate = self
    }
    
    private func layout() {
        [noteTitleLabel, noteTypeTextField, wordCountLabel, noteTableView]
            .forEach(view.addSubview)
        
        noteTitleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(30)
            make.top.equalToSuperview().inset(15)
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
            make.top.equalTo(noteTypeTextField.snp.bottom)
            make.bottom.equalToSuperview()
        }
    }
}

