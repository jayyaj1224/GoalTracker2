//
//  NoteViewModel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 02/12/2022.
//

import UIKit
import RxSwift
import RxCocoa

class UserNoteViewModel {
    let tableViewDatasourceRelay = BehaviorRelay<[UserNote]>(value: [])
    
    init(goalIdentifier: String) {
//        let key = Keys.userNoteKey(for: goalIdentifier)
//
//        if let encoded = UserDefaults.standard.data(forKey: key)  {
//            let userNotes = try? PropertyListDecoder().decode([UserNote].self, from: encoded)
//
//            tableViewDatasourceRelay.accept(userNotes ?? [])
//        }
        
        let dummy  = [
            UserNote(goalIdentifier: "", note: " getKeyboardDevicePropertiesForSenderID:shouldUpdate:usingSyntheticEv.", date: "", isKeyNote: false),
            UserNote(goalIdentifier: "", note: " failed to fetch device property for senderID (778835616971358209) use primary keyboard info instead.", date: "", isKeyNote: false),
            UserNote(goalIdentifier: "", note: "https://github.com/realm/realm-swift/blob/v10.33.0/CHANGELOG.md", date: "", isKeyNote: false)
        ]
        
        tableViewDatasourceRelay.accept(dummy)
    }
}
