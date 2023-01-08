//
//  Constants.swift
//  HabitSquare
//
//  Created by Lee Jong Yun on 2021/12/23.
//

import UIKit

enum K {
    static let ratioFactor: CGFloat = UIScreen.main.bounds.width/375
    
    static var singleRowHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return round(circleRadius + screenHeight*0.15)
    }
    
    static var circleRadius: CGFloat { UIScreen.main.bounds.width }
    
    static var screenWidth: CGFloat { UIScreen.main.bounds.width }
    
    static var screenHeight: CGFloat { UIScreen.main.bounds.height }
}

enum Keys {
    static let firstLaunchCheck: String = "UserDefaultKey_FirstLaunch"
    
    
    // Setting
    static let setting_scoreViewType: String = "UserDefaultKey_Setting_ScoreViewType"
    static let setting_handSide: String = "UserDefaultKey_Setting_HandSide"
    static let setting_vibrate: String = "UserDefaultKey_Setting_Vibrate"
    
    static let userNote: String = "UserDefaultKey_UserNote"
    
    
    
    
    // Goal
//    static let Profile: String = "UserDefaultKey_Profile"
//    static let GoalModel: String = "UserDefaultKey_GoalModel"

    
    
//    static let Setting_Graph: String = "UserDefaultKey_Setting_Graph"
//    static let Setting_Colour: String = "UserDefaultKey_Setting_Colour"
//    static let Setting_GraphNumber: String = "UserDefaultKey_GraphNumber"
//    static let Setting_PushNoti: String = "UserDefaultKey_PushNoti"
    
    // Notification
//    static let Noti_goal_ended: String = "Noti_goal_ended"
}

func now() -> CFTimeInterval {
    return CACurrentMediaTime()
}
