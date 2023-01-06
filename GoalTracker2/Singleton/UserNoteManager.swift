//
//  UserNoteManager.swift
//  GoalTracker2
//
//  Created by Jay Lee on 03/12/2022.
//

import Foundation

class UserNoteManager {
    static let shared = UserNoteManager()
    
    var userNotesDictionary: [String: [UserNote]] = [:]
    
    init() {
        if let encodedNotes = UserDefaults.standard.data(forKey: Keys.userNote) {
            if let userNotesDic = try? PropertyListDecoder().decode([String: [UserNote]].self, from: encodedNotes) {
                userNotesDictionary = userNotesDic
            }
        }
    }
    
    private func save() {
        if let encoded = try? PropertyListEncoder().encode(userNotesDictionary) {
            UserDefaults.standard.set(encoded, forKey: Keys.userNote)
        }
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
        var userNote = UserNote()
        userNote.isKeyNote = true
        userNote.note = "You can set a key-note here."
        
        userNotesDictionary[goalIdentifier] = [userNote]
        
        save()
    }
}
