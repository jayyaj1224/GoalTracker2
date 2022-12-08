//
//  Settings.swift
//  GoalTracker2
//
//  Created by Jay Lee on 29/11/2022.
//

import Foundation

class SettingsManager {
    enum ScorePannelType: Int { case Digital, Flap }
    
    static let shared = SettingsManager()
    
    var scorePannelType: ScorePannelType {
        didSet {
            UserDefaults.standard.set(scorePannelType.rawValue, forKey: Keys.setting_scoreViewType)
        }
    }
    
    var vibrate: Bool {
        didSet {
            UserDefaults.standard.set(vibrate, forKey: Keys.setting_vibrate)
        }
    }
    
    init() {
        let scorePannelTypeRaw = UserDefaults.standard.integer(forKey: Keys.setting_scoreViewType)
        scorePannelType = ScorePannelType(rawValue: scorePannelTypeRaw) ?? .Digital
        vibrate = UserDefaults.standard.bool(forKey: Keys.setting_vibrate)
    }
}


