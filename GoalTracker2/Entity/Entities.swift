//
//  GoalModel.swift
//  HabitSquare
//
//  Created by Lee Jong Yun on 2021/12/23.
//

import RealmSwift

enum GoalTrackType: Int, Codable {
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

struct Day: Codable {
    var date: String = ""
    var index: Int = 0
    var status: String = ""
}

class GoalEncodedObject: Object {
    @Persisted(primaryKey: true) var identifier: String = ""
    @Persisted var goalEncoded: Data = Data()
    
    convenience init(goalEncoded: Data, identifier: String) {
        self.init()
        
        self.identifier = identifier
        self.goalEncoded = goalEncoded
    }
}

struct Goal: Codable {
    var identifier: String = ""
    var title: String = ""
    var detail: String = ""
    //var setType: GoalTrackType = .Period
    
    var totalDays: Int = 0
    var startDate: String = ""
    var endDate: String = ""
    
    var status: GoalStatus = .none
    
    var successCount: Int = 0
    var failCount: Int = 0
    var failCap: Int = 0
    
    var daysByMonth: [String: [Day]] = [:]
    
    var isPlaceHolder: Bool = false
    
    init(title: String, detail: String, totalDays: Int, failCap: Int) { //, setType: GoalTrackType) {
        let today = Date()
        
        switch title {
        case "1":
            dummyInit1()
            return
        case "2":
            dummyInit2()
            return
        case "3":
            dummyInit3()
            return
        default:
            break
        }
        
        self.title = title
        self.detail = detail
        self.identifier = today.stringFormat(of: .goalIdentifier)
        self.status = GoalStatus.none
        //self.setType = setType
        self.totalDays = totalDays
        self.startDate = today.stringFormat(of: .yyyyMMdd)
        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
        self.failCap = failCap
        
        Array(0...totalDays-1).forEach { i in
            let date = today.add(i-1)
            let yyyyMM = date.stringFormat(of: .yyyyMM)
            let yyyyMMdd = date.stringFormat(of: .yyyyMMdd)
            
            let day = Day(date: yyyyMMdd,index: i, status: "none")
            
            var temp = daysByMonth[yyyyMM] ?? []
            temp.append(day)
            daysByMonth[yyyyMM] = temp
        }
    }
}

struct UserNote: Codable {
    var goalIdentifier: String = ""
    var note: String = ""
    var date: String = "" //yyyymmdd
    var isKeyNote: Bool = false
}








extension Goal {
    mutating func dummyInit1() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        self.title = "2 hours workout every day. \n(no carbs & sugar) 49"
        self.detail = "aaaa"
        self.identifier = Date().stringFormat(of: .goalIdentifier)
        self.status = GoalStatus.none
        //self.setType = GoalTrackType.Period
        self.totalDays = 700
        
        let today = dateFormatter.date(from: "20220413") ?? Date()
        self.startDate = today.stringFormat(of: .yyyyMMdd)
        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
        self.failCap = 10
        self.successCount = 119
        self.failCount = 4
        
        for i in 1...totalDays {
            let date = today.add(i-1)
            let yyyyMM = date.stringFormat(of: .yyyyMM)
            let yyyyMMdd = date.stringFormat(of: .yyyyMMdd)
            
            var day = Day(date: yyyyMMdd,index: i, status: "none")
            
            switch i {
            case 100,102,103,105:
                day.status = GoalStatus.fail.rawValue
            case ...123:
                day.status = GoalStatus.success.rawValue
            default:
                day.status = GoalStatus.none.rawValue
            }
            
            var temp = daysByMonth[yyyyMM] ?? []
            temp.append(day)
            daysByMonth[yyyyMM] = temp
        }
    }
    
    mutating func dummyInit2() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        self.title = "1 hour reading every day. Self Reliance by R.W. Emerson. 60."
        self.detail = "aaaa"
        self.identifier = Date().stringFormat(of: .goalIdentifier)
        self.status = GoalStatus.none
        //self.setType = GoalTrackType.Period
        self.totalDays = 900
        
        let today = dateFormatter.date(from: "20220413") ?? Date()
        self.startDate = today.stringFormat(of: .yyyyMMdd)
        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
        self.failCap = 10
        self.successCount = 119
        self.failCount = 4
        
        for i in 1...totalDays {
            let date = today.add(i-1)
            let yyyyMM = date.stringFormat(of: .yyyyMM)
            let yyyyMMdd = date.stringFormat(of: .yyyyMMdd)
            
            var day = Day(date: yyyyMMdd,index: i, status: "none")
            
            switch i {
            case 100,102,103,105:
                day.status = GoalStatus.fail.rawValue
            case ...123:
                day.status = GoalStatus.success.rawValue
            default:
                day.status = GoalStatus.none.rawValue
            }
            
            var temp = daysByMonth[yyyyMM] ?? []
            temp.append(day)
            daysByMonth[yyyyMM] = temp
        }
    }
    
    mutating func dummyInit3() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        self.title = "30 minutes of meditation and self affirmation."
        self.detail = "aaaa"
        self.identifier = Date().stringFormat(of: .goalIdentifier)
        self.status = GoalStatus.none
        //self.setType = GoalTrackType.Period
        self.totalDays = 300
        
        let today = dateFormatter.date(from: "20220820") ?? Date()
        self.startDate = today.stringFormat(of: .yyyyMMdd)
        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
        self.failCap = 10
        self.successCount = 119
        self.failCount = 4
        
        for i in 1...totalDays {
            let date = today.add(i-1)
            let yyyyMM = date.stringFormat(of: .yyyyMM)
            let yyyyMMdd = date.stringFormat(of: .yyyyMMdd)
            
            var day = Day(date: yyyyMMdd,index: i, status: "none")
            
            switch i {
            case 100,102,103,105,106,107,108:
                day.status = GoalStatus.fail.rawValue
            case ...123:
                day.status = GoalStatus.success.rawValue
            default:
                day.status = GoalStatus.none.rawValue
            }
            
            var temp = daysByMonth[yyyyMM] ?? []
            temp.append(day)
            daysByMonth[yyyyMM] = temp
        }
    }
}
