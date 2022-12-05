//
//  UserNoteViewModel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 02/12/2022.
//

import UIKit
import RxSwift
import RxCocoa

class UserNoteViewModel {
    let tableViewDatasourceRelay = BehaviorRelay<[UserNote]>(value: [])
    
    var goalIdentifier = ""
    
    let userNoteSubject = PublishSubject<[UserNote]>()
    
    init(goalIdentifier: String) {
        self.goalIdentifier = goalIdentifier
        
        let userNotes = UserNoteManager.shared.userNotesDictionary[goalIdentifier]

        tableViewDatasourceRelay.accept(userNotes ?? [])
    }
    
    func addNewNote(_ note: String) {
        let newNote = UserNote(goalIdentifier: goalIdentifier, note: note, date: Date().stringFormat(of: .yyyyMMdd), isKeyNote: false)
        
        var datasourceTemp = tableViewDatasourceRelay.value
        datasourceTemp.append(newNote)
        tableViewDatasourceRelay.accept(datasourceTemp)
        
        UserNoteManager.shared.saveNewNote(identifier: goalIdentifier, newNote: newNote)
    }
    
    func deleteNote(at row: Int) {
        var datasourceTemp = tableViewDatasourceRelay.value
        datasourceTemp.remove(at: row)
        tableViewDatasourceRelay.accept(datasourceTemp)
        
        UserNoteManager.shared.saveNotesArray(
            identifier: goalIdentifier,
            newNotesArray: datasourceTemp
        )
        
        userNoteSubject.onNext(datasourceTemp)
    }
    
    func keyButtonTapped(at row: Int) {
        var noteArrayTemp = tableViewDatasourceRelay.value
        
        if noteArrayTemp[row].isKeyNote {
            noteArrayTemp[row].isKeyNote = false
        } else {
            noteArrayTemp.indices.forEach {
                noteArrayTemp[$0].isKeyNote = false
            }
            noteArrayTemp[row].isKeyNote = true
            noteArrayTemp.insert(noteArrayTemp[row], at: 0)
            noteArrayTemp.remove(at: row+1)
        }
        
        userNoteSubject.onNext(noteArrayTemp)
        
        tableViewDatasourceRelay.accept(noteArrayTemp)
        
        UserNoteManager.shared.saveNotesArray(
            identifier: goalIdentifier,
            newNotesArray: noteArrayTemp
        )
    }
}
