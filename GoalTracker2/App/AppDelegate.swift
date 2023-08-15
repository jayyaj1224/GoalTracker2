//
//  AppDelegate.swift
//  GoalTracker2
//
//  Created by Jay Lee on 12/09/2022.
//

import UIKit
import SnapKit
import IQKeyboardManagerSwift
import RxSwift
import RxCocoa
import RealmSwift
//import Toast_Swift
import Lottie

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        firstLaunchSettings()
        iqKeyboardManagerSetting()
        
        return true
    }
    
    private func firstLaunchSettings() {
        let firstLaunchCheck = UserDefaults.standard.bool(forKey: Keys.firstLaunchCheck)
        
        if firstLaunchCheck == false {
            UserDefaults.standard.set(0, forKey: Keys.setting_scoreViewType)
            UserDefaults.standard.set(true, forKey: Keys.setting_vibrate)
            
            UserDefaults.standard.set(true, forKey: Keys.firstLaunchCheck)
        }
    }

    private func iqKeyboardManagerSetting() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 100
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "Cancel"
        IQKeyboardManager.shared.toolbarTintColor = .black
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

