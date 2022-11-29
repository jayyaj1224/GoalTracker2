//
//  Settings.swift
//  GoalTracker2
//
//  Created by Jay Lee on 29/11/2022.
//

import Foundation

class Settings {
    enum ScorePannelType { case Digital, Flap }
    
    static let shared = Settings()
    
    var scorePannelType: ScorePannelType = .Digital
    
    init() {
    }
    
}


