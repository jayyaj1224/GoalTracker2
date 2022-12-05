//
//  UserNote.swift
//  GoalTracker2
//
//  Created by Jay Lee on 03/12/2022.
//

import UIKit

struct UserNote: Codable {
    var goalIdentifier: String = ""
    var note: String = ""
    var date: String = "" //yyyymmdd
    var isKeyNote: Bool = false
    
    static func makeNewGoalDefault(identifier: String)-> UserNote {
        var userNote = UserNote()
        userNote.isKeyNote = true
        userNote.goalIdentifier = identifier
        userNote.date = Date().stringFormat(of: .yyyyMMdd)
        userNote.note = "You can set a key-note here."
        return userNote
    }
}



