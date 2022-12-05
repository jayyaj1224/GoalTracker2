//
//  UserNoteManager.swift
//  GoalTracker2
//
//  Created by Jay Lee on 03/12/2022.
//

import Foundation

class UserNoteManager {
    static let shared = UserNoteManager()
    
    private let encoder = PropertyListEncoder()
    private let decoder = PropertyListDecoder()
    
    var userNotesDictionary: [String: [UserNote]] = [:]
    
    init() {
        setUserNotes()
    }
    
    private func setUserNotes() {
        userNotesDictionary = getUserNotes()
    }
    
    private func getUserNotes() -> [String: [UserNote]] {
        if let encodedNotes = UserDefaults.standard.data(forKey: Keys.userNote) {
            if let userNotesDic = try? decoder.decode([String: [UserNote]].self, from: encodedNotes) {
                return userNotesDic
            }
        }
        return [:]
    }
    
    func saveNewNote(identifier: String, newNote: UserNote) {
        var userNotesTemp = userNotesDictionary[identifier] ?? []
        userNotesTemp.append(newNote)
        
        userNotesDictionary[identifier] = userNotesTemp
        
        save()
    }
    
    func saveNotesArray(identifier: String, newNotesArray: [UserNote]) {
        userNotesDictionary[identifier] = newNotesArray
        
        save()
    }
    
    func saveNewGoalDefaultUserNote(goalIdentifier: String) {
        let newGoalDefaultUserNote = UserNote.makeNewGoalDefault(identifier: goalIdentifier)
        
        userNotesDictionary[goalIdentifier] = [newGoalDefaultUserNote]
        
        save()
    }
    
    private func save() {
        if let encoded = try? encoder.encode(userNotesDictionary) {
            UserDefaults.standard.set(encoded, forKey: Keys.userNote)
        }
    }
}
