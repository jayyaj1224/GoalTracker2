//
//  GoalModel.swift
//  HabitSquare
//
//  Created by Lee Jong Yun on 2021/12/23.
//

import RealmSwift

enum GoalTrackType: Int {
    case Continuous, Period
}

enum GoalStatus: String, Codable {
    case success
    case fail
    case none
}

struct Profile: Codable {
    var totalTrialCount: Int
    var totalGoalAchievementsCount: Int
    var totalSuccessCount: Int
    var totalFailCount: Int
    
    init() {
        self.totalTrialCount = 0
        self.totalGoalAchievementsCount = 0
        self.totalSuccessCount = 0
        self.totalFailCount = 0
    }
}

class Goal: Object {
    @Persisted(primaryKey: true) var identifier: String = ""
    @Persisted var title: String = ""
    @Persisted var status: String = ""
    @Persisted var setType: Int = 0

    @Persisted var totalDays: Int = 0
    @Persisted var startDate: String = ""
    @Persisted var endDate: String = ""

    @Persisted var successCount: Int = 0
    @Persisted var failCount: Int = 0
    @Persisted var failCap: Int = 0
    
    @Persisted var dayList: List<Day> = List<Day>()
    
    @Persisted var isPlaceHolder: Bool = false
    
    var dayArray: [Day] {
        get {
            return dayList.map{$0}
        }
        set {
            dayList.removeAll()
            dayList.append(objectsIn: newValue)
        }
    }
    
    convenience init(title: String, totalDays: Int, failCap: Int, setType: GoalTrackType) {
        let today = Date()
        
        self.init()
        self.title = title
        self.identifier = Date().asString.identifier
        self.status = GoalStatus.none.rawValue
        self.setType = setType.rawValue
        self.totalDays = totalDays
        self.startDate = today.asString.standard
        self.endDate = today.add(totalDays-1).asString.standard
        self.failCap = failCap
        
        Array(0...totalDays-1).forEach { i in
            let day = Day()
            day.date = today.add(i-1).asString.standard
            day.index = i
            day.status = GoalStatus.none.rawValue
            self.dayList.append(day)
        }
    }
}


class Day: Object {
    @Persisted var date: String = ""
    @Persisted var index: Int = 0
    @Persisted var status: String = ""
}
