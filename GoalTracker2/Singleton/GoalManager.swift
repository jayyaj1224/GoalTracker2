//
//  GoalManager.swift
//  GoalTracker
//
//  Created by 이종윤 on 2022/02/14.
//
import RealmSwift
import RxCocoa
import RxSwift

class GoalManager {
    public static let shared = GoalManager()
    
    private var realm: Realm!
    
    var numberOfGoals: Int {
        return realm.objects(GoalEncodedObject.self).count
    }
    
    private init() {
        configureRealm()
    }
    
    var goals: [Goal] {
        var goalsTemp = [Goal]()
        self.realm.objects(GoalEncodedObject.self)
            .sorted { $0.identifier < $1.identifier }
            .map(\.goalEncoded)
            .forEach { data in
                if let goal = try? PropertyListDecoder().decode(Goal.self, from: data) {
                    goalsTemp.append(goal)
                }
            }
        
        return goalsTemp
    }
    
    private func configureRealm() {
        do {
            let customMigration = Realm.Configuration(
                schemaVersion: 1,
                migrationBlock: { migration, oldVersion in
                    migration.enumerateObjects(ofType: "Goal") { old, new in
                        
                    }
                }
            )
            self.realm = try Realm(configuration: customMigration)
        }
        catch {
            let resetConfiguration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
            self.realm = try! Realm(configuration: resetConfiguration)
        }
    }
}

extension GoalManager {
    func realmWriteGoal(_ goal: Goal) {
        if let goalEncoded = try? PropertyListEncoder().encode(goal) {
            let goalEncodedObject = GoalEncodedObject(goalEncoded: goalEncoded, identifier: goal.identifier)
            
            try! self.realm.write {
                self.realm.add(goalEncodedObject)
            }
        }
    }
        
    func deleteGoal(with identifier: String) {
        if let goal = realm.object(ofType: GoalEncodedObject.self, forPrimaryKey: identifier) {
            try! realm.write {
                realm.delete(goal)
            }
        }
    }
    
    func deleteAll() {
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func update(_ goal: Goal) {
        if let goalEncoded = try? PropertyListEncoder().encode(goal) {
            let goalEncodedObject = GoalEncodedObject(goalEncoded: goalEncoded, identifier: goal.identifier)
             
            try! self.realm.write {
                self.realm.add(goalEncodedObject, update: .modified)
            }
        }
    }
}
