//
//  GoalModel.swift
//  HabitSquare
//
//  Created by Lee Jong Yun on 2021/12/23.
//

import RealmSwift

enum GoalTrackType: Int {
    case Yearly, Period
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
    @Persisted var detail: String = ""
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
    
    convenience init(title: String, detail: String, totalDays: Int, failCap: Int, setType: GoalTrackType) {
        self.init()
        
        if title == "1" {
            self.dummyInit()
            return 
        }
        
        if title == "2" {
            self.dummyInit2()
            return
        }
        
        if title == "3" {
            self.dummyInit3()
            return
        }
        
        let today = Date()
        
        self.title = title
        self.detail = detail
        self.identifier = today.stringFormat(of: .goalIdentifier)
        self.status = GoalStatus.none.rawValue
        self.setType = setType.rawValue
        self.totalDays = totalDays
        self.startDate = today.stringFormat(of: .yyyyMMdd)
        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
        self.failCap = failCap
        
        Array(0...totalDays-1).forEach { i in
            let day = Day()
            day.date = today.add(i-1).stringFormat(of: .yyyyMMdd)
            day.index = i
            day.status = GoalStatus.none.rawValue
            self.dayList.append(day)
        }
    }
    
    func dummyInit() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        self.title = "2 hours workout every day. \n(no carbs & sugar) 49"
        self.detail = "aaaa"
        self.identifier = Date().stringFormat(of: .goalIdentifier)
        self.status = GoalStatus.none.rawValue
        self.setType = GoalTrackType.Period.rawValue
        self.totalDays = 700
        
        let today = dateFormatter.date(from: "20220413") ?? Date()
        self.startDate = today.stringFormat(of: .yyyyMMdd)
        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
        self.failCap = 10
        self.successCount = 119
        self.failCount = 4
        
        for i in 1...totalDays {
            let day = Day()
            day.date = today.add(i-1).stringFormat(of: .yyyyMMdd)
            day.index = i
            switch i {
            case 100,102,103,105:
                day.status = GoalStatus.fail.rawValue
            case ...123:
                day.status = GoalStatus.success.rawValue
            default:
                day.status = GoalStatus.none.rawValue
            }
            self.dayList.append(day)
        }
    }
    
    func dummyInit2() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        self.title = "1 hour reading every day. Self Reliance by R.W. Emerson. 60."
        self.detail = "aaaa"
        self.identifier = Date().stringFormat(of: .goalIdentifier)
        self.status = GoalStatus.none.rawValue
        self.setType = GoalTrackType.Period.rawValue
        self.totalDays = 900
        
        let today = dateFormatter.date(from: "20220413") ?? Date()
        self.startDate = today.stringFormat(of: .yyyyMMdd)
        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
        self.failCap = 10
        self.successCount = 119
        self.failCount = 4
        
        for i in 1...totalDays {
            let day = Day()
            day.date = today.add(i-1).stringFormat(of: .yyyyMMdd)
            day.index = i
            switch i {
            case 100,102,103,105:
                day.status = GoalStatus.fail.rawValue
            case ...123:
                day.status = GoalStatus.success.rawValue
            default:
                day.status = GoalStatus.none.rawValue
            }
            self.dayList.append(day)
        }
    }
    
    func dummyInit3() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        self.title = "30 minutes of meditation and self affirmation."
        self.detail = "aaaa"
        self.identifier = Date().stringFormat(of: .goalIdentifier)
        self.status = GoalStatus.none.rawValue
        self.setType = GoalTrackType.Period.rawValue
        self.totalDays = 300
        
        let today = dateFormatter.date(from: "20220820") ?? Date()
        self.startDate = today.stringFormat(of: .yyyyMMdd)
        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
        self.failCap = 10
        self.successCount = 119
        self.failCount = 4
        
        for i in 1...totalDays {
            let day = Day()
            day.date = today.add(i-1).stringFormat(of: .yyyyMMdd)
            day.index = i
            switch i {
            case 100,102,103,105,106,107,108:
                day.status = GoalStatus.fail.rawValue
            case ...123:
                day.status = GoalStatus.success.rawValue
            default:
                day.status = GoalStatus.none.rawValue
            }
            self.dayList.append(day)
        }
    }
}


class Day: Object {
    @Persisted var date: String = ""
    @Persisted var index: Int = 0
    @Persisted var status: String = ""
}
