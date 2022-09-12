//
//  Constants.swift
//  HabitSquare
//
//  Created by Lee Jong Yun on 2021/12/23.
//

import UIKit

enum K {
    /// Returns `true` if the device has a notch
    static var hasNotch: Bool {
        guard let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first else {
            return false
        }
        return window.safeAreaInsets.top >= 44
    }
    
    static var isLarge: Bool {
        if screenWidth < 375 {
            return false
        } else {
            return true
        }
    }
    
    static let ratioFactor: CGFloat = UIScreen.main.bounds.width/375
    
    static var singleRowHeight: CGFloat {
        let screenHeight = UIScreen.main.bounds.height
        return round(circleRadius + screenHeight*0.15)
    }
    
    static var circleRadius: CGFloat { UIScreen.main.bounds.width }
    
    static var screenWidth: CGFloat { UIScreen.main.bounds.width }
    
    static var screenHeight: CGFloat { UIScreen.main.bounds.height }
}

enum KeyStrings {
    static let FirstLaunch: String = "UserDefaultKey_FirstLaunch"
    
    // Goal
    static let Profile: String = "UserDefaultKey_Profile"
    static let GoalModel: String = "UserDefaultKey_GoalModel"
 
    // Setting
    static let Setting_Graph: String = "UserDefaultKey_Setting_Graph"
    static let Setting_Colour: String = "UserDefaultKey_Setting_Colour"
    static let Setting_GraphNumber: String = "UserDefaultKey_GraphNumber"
    static let Setting_PushNoti: String = "UserDefaultKey_PushNoti"
    
    // Notification
    static let Noti_goal_ended: String = "Noti_goal_ended"
}

func now() -> CFTimeInterval {
    return CACurrentMediaTime()
}
