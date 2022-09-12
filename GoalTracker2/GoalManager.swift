//
//  GoalManager.swift
//  GoalTracker
//
//  Created by 이종윤 on 2022/02/14.
//
import RealmSwift

class GoalManager {
    public static let shared = GoalManager()
    
    private var realm: Realm!
    
    var goals: [Goal] {
        return realm.objects(Goal.self)
            .sorted { $0.identifier > $1.identifier }
    }
    
    private init() {
        configureRealm()
    }
    
    private func configureRealm() {
        let customMigration = Realm.Configuration(
            schemaVersion: 1,
            migrationBlock: { migration, oldVersion in
                migration.enumerateObjects(ofType: "Goal") { old, new in
                    
                }
            }
        )
        do {
            realm = try Realm(configuration: customMigration)
        }
        catch {
            let resetConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            realm = try! Realm(configuration: resetConfiguration)
        }
    }
}

extension GoalManager {
    func newGoal(_ goal: Goal) {
        var info = getProfile()
        info.totalTrialCount+=1
        saveProfile(profile: info)
        
        try! realm.write {
            realm.add(goal)
        }
    }
   
    func daySuccess(identifier: String, dayIndex: Int) {
        guard let goal = realm.object(ofType: Goal.self, forPrimaryKey: identifier) else {
            return
        }
        try! realm.write {
            goal.dayArray[dayIndex].status = GoalStatus.success.rawValue
            goal.successCount+=1
        }
        
        if goal.endDate <= Date().asString.standard {
            goal.dayArray.forEach {
                if $0.status == GoalStatus.none.rawValue {
                    // Check unchecked day alert
                    return
                }
            }
            
            goalSuccess(identifier: goal.identifier)
        }
    }
    
    func dayFail(identifier: String, dayIndex: Int) {
        guard let goal = realm.object(ofType: Goal.self, forPrimaryKey: identifier) else {
            return
        }
        
        try! realm.write {
            goal.dayArray[dayIndex].status = GoalStatus.fail.rawValue
            goal.failCount+=1
        }
        
        if goal.failCount > goal.failCap {
            goalFail(identifier: goal.identifier)
        }
    }
    
    func goalSuccess(identifier: String) {
        // 프로필 Success + 1
        var profile = getProfile()
        profile.totalSuccessCount+=1
        saveProfile(profile: profile)
        
        // Goal Success
        if let goal = realm.object(ofType: Goal.self, forPrimaryKey: identifier) {
            try! realm.write {
                goal.status = GoalStatus.success.rawValue
            }
        }
        
        postGoalEndedNoti(status: .success)
    }
    
    func goalFail(identifier: String) {
        // 프로필 Fail +1
        var profile = getProfile()
        profile.totalFailCount+=1
        saveProfile(profile: profile)
        
        // Goal Fail
        if let goal = realm.object(ofType: Goal.self, forPrimaryKey: identifier) {
            try! realm.write {
                goal.status = GoalStatus.fail.rawValue
            }
        }
        
        postGoalEndedNoti(status: .fail)
    }
    
    func deleteGoal(identifier: String) {
        var profile = getProfile()
        profile.totalTrialCount-=1
        saveProfile(profile: profile)
        
        if let goal = realm.object(ofType: Goal.self, forPrimaryKey: identifier) {
            try! realm.write {
                realm.delete(goal)
            }
        }
    }
    
    private func postGoalEndedNoti(status: GoalStatus) {
        NotificationCenter.default.post(
            name: NSNotification.Name(KeyStrings.Noti_goal_ended),
            object: status.rawValue
        )
    }
    
    
    // Profile
    private func saveProfile(profile: Profile) {
        UserDefaults.standard.set(try? PropertyListEncoder().encode(profile), forKey: KeyStrings.Profile)
    }
    
    private func getProfile() -> Profile {
        if let data = UserDefaults.standard.data(forKey: KeyStrings.Profile),
           let userInfo = try? PropertyListDecoder().decode(Profile.self, from: data) {
            return userInfo
        }
        return Profile()
    }
}
