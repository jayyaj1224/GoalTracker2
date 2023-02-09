//
//  GoalModel.swift
//  HabitSquare
//
//  Created by Lee Jong Yun on 2021/12/23.
//

import RealmSwift

enum GoalStatus: String, Codable {
    case success, fail, none
}

struct Day: Codable {
    var date: String = ""
    var index: Int = 0
    var status: String = ""
}

struct Goal: Codable {
    var identifier: String = ""
    var status: GoalStatus = .none
    
    var title: String = ""
    var description: String = ""
    var totalDays: Int = 0
    
    var startDate: String = ""
    var endDate: String = ""
    
    var successCount: Int = 0
    var failCount: Int = 0
    var failCap: Int = 0
    
    var days: [Day]
    
    init(title: String, detail: String, totalDays: Int, failCap: Int) {
        let today = Date()
        
        self.title = title
        self.description = detail
        self.identifier = today.stringFormat(of: .goalIdentifier)
        self.status = GoalStatus.none
        self.totalDays = totalDays
        self.startDate = today.stringFormat(of: .yyyyMMdd)
        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
        self.failCap = failCap
        
        if title.hasPrefix("Qqq") {
            self.days = []
            
            qaInit()
            return
        }
        
        self.days = Array(0...totalDays-1)
            .map { i in
                let date = today.add(i)
                let yyyyMM = date.stringFormat(of: .yyyyMM)
                let yyyyMMdd = date.stringFormat(of: .yyyyMMdd)
                
                return Day(date: yyyyMMdd,index: i, status: "none")
            }
    }
}

//MARK: Realm
class GoalEncodedObject: Object {
    @Persisted(primaryKey: true) var identifier: String = ""
    @Persisted var goalEncoded: Data = Data()
    
    convenience init(goalEncoded: Data, identifier: String) {
        self.init()
        
        self.identifier = identifier
        self.goalEncoded = goalEncoded
    }
}

extension Goal {
    private mutating func qaInit() {
        switch String(title.last!) {
        case "1":    qaInit_1()
        case "2":    qaInit_2()
        case "3":    qaInit_3()
        case "4":    qaInit_4()
        case "5":    qaInit_5()
        default:        break
        }
    }
    mutating func qaInit_1() {
        self.title = "2 hours workout every day."
        self.description = "aaaa"
        self.identifier = Date().stringFormat(of: .goalIdentifier)
        self.status = GoalStatus.none
        self.totalDays = 700
        
        let today = Date.inAnyFormat(dateString: "20220413")
        self.startDate = today.stringFormat(of: .yyyyMMdd)
        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
        self.failCap = 30
        self.failCount = 29
        self.successCount = Date.inAnyFormat(dateString: startDate).daysCountToNow-failCount
        
        
        let randomFailed = Array(0...today.daysCountToNow)
            .shuffled()[0...self.failCount]
            .map { Int($0) }
        
        self.days = Array(0...totalDays-1)
            .map { i in
                let date = today.add(i)
                let yyyyMM = date.stringFormat(of: .yyyyMM)
                let yyyyMMdd = date.stringFormat(of: .yyyyMMdd)
                
                var day = Day(date: yyyyMMdd,index: i, status: "none")
                
                if day.date < Date().stringFormat(of: .yyyyMMdd) {
                    if randomFailed.contains(i) {
                        day.status = GoalStatus.fail.rawValue
                    } else {
                        day.status = GoalStatus.success.rawValue
                    }
                } else {
                    day.status = GoalStatus.none.rawValue
                }
                return day
            }
    }
    
    
    mutating func qaInit_2() {
        self.title = "1 hour reading every day.\nSelf Reliance-R.W.Emerson."
        self.description = "aaaa"
        self.identifier = Date().stringFormat(of: .goalIdentifier)
        self.status = GoalStatus.none
        self.totalDays = 700
        
        let today = Date.inAnyFormat(dateString: "20221113")
        self.startDate = today.stringFormat(of: .yyyyMMdd)
        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
        self.failCap = 30
        self.failCount = 24
        self.successCount = Date.inAnyFormat(dateString: startDate).daysCountToNow-failCount
        
        
        let randomFailed = Array(0...today.daysCountToNow)
            .shuffled()[0...self.failCount]
            .map { Int($0) }
        
        self.days = Array(0...totalDays-1)
            .map { i in
                let date = today.add(i-1)
                let yyyyMM = date.stringFormat(of: .yyyyMM)
                let yyyyMMdd = date.stringFormat(of: .yyyyMMdd)
                
                var day = Day(date: yyyyMMdd,index: i, status: "none")
                
                
                if day.date < Date().stringFormat(of: .yyyyMMdd) {
                    if randomFailed.contains(i) {
                        day.status = GoalStatus.fail.rawValue
                    } else {
                        day.status = GoalStatus.success.rawValue
                    }
                } else {
                    day.status = GoalStatus.none.rawValue
                }
                
                return day
                
            }
    }

    mutating func qaInit_3() {
        self.title = "30 minutes of meditation and self affirmation."
        self.description = "aaaa"
        self.identifier = Date().stringFormat(of: .goalIdentifier)
        self.status = GoalStatus.none
        self.totalDays = 700
        
        let today = Date.inAnyFormat(dateString: "20220413")
        self.startDate = today.stringFormat(of: .yyyyMMdd)
        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
        self.failCap = 30
        self.failCount = 0
        self.successCount = Date.inAnyFormat(dateString: startDate).daysCountToNow-failCount
        
        
        let randomFailed = Array(0...today.daysCountToNow)
            .shuffled()[0...self.failCount]
            .map { Int($0) }
        
        self.days = Array(0...totalDays-1)
            .map { i in
                let date = today.add(i-1)
                let yyyyMM = date.stringFormat(of: .yyyyMM)
                let yyyyMMdd = date.stringFormat(of: .yyyyMMdd)
                
                var day = Day(date: yyyyMMdd,index: i, status: "none")
                
                
                if day.date < Date().stringFormat(of: .yyyyMMdd) {
                    if randomFailed.contains(i) {
                        day.status = GoalStatus.fail.rawValue
                    } else {
                        day.status = GoalStatus.success.rawValue
                    }
                } else {
                    day.status = GoalStatus.none.rawValue
                }
                return day
            }
    }
    
    mutating func qaInit_4() {
        self.title = "30 minutes of meditation and self affirmation."
        self.description = "aaaa"
        self.identifier = Date().stringFormat(of: .goalIdentifier)
        self.status = GoalStatus.none
        self.totalDays = 700
        
        let today = Date.inAnyFormat(dateString: "20220813")
        self.startDate = today.stringFormat(of: .yyyyMMdd)
        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
        self.failCap = 30
        self.failCount = 8
        self.successCount = Date.inAnyFormat(dateString: startDate).daysCountToNow-failCount
        
        
        let randomFailed = Array(0...today.daysCountToNow)
            .shuffled()[0...self.failCount]
            .map { Int($0) }
        
        self.days = Array(0...totalDays-1)
            .map { i in
                let date = today.add(i-1)
                let yyyyMM = date.stringFormat(of: .yyyyMM)
                let yyyyMMdd = date.stringFormat(of: .yyyyMMdd)
                
                var day = Day(date: yyyyMMdd,index: i, status: "none")
                
                
                if day.date < Date().stringFormat(of: .yyyyMMdd) {
                    if randomFailed.contains(i) {
                        day.status = GoalStatus.fail.rawValue
                    } else {
                        day.status = GoalStatus.success.rawValue
                    }
                } else {
                    day.status = GoalStatus.none.rawValue
                }
                
                return day
            }
    }
    
    mutating func qaInit_5() {
        self.title = "2 hour algorithm per day"
        self.description = "aaaa"
        self.identifier = Date().stringFormat(of: .goalIdentifier)
        self.status = GoalStatus.none
        self.totalDays = 700
        
        let today = Date.inAnyFormat(dateString: "20220413")
        self.startDate = today.stringFormat(of: .yyyyMMdd)
        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
        self.failCap = 30
        self.failCount = 29
        self.successCount = Date.inAnyFormat(dateString: startDate).daysCountToNow-failCount
        
        
        let randomFailed = Array(0...today.daysCountToNow)
            .shuffled()[0...self.failCount]
            .map { Int($0) }
        
        self.days = Array(0...totalDays-1)
            .map { i in
                let date = today.add(i-1)
                let yyyyMM = date.stringFormat(of: .yyyyMM)
                let yyyyMMdd = date.stringFormat(of: .yyyyMMdd)
                
                var day = Day(date: yyyyMMdd,index: i, status: "none")
                
                
                if day.date < Date().stringFormat(of: .yyyyMMdd) {
                    if randomFailed.contains(i) {
                        day.status = GoalStatus.fail.rawValue
                    } else {
                        day.status = GoalStatus.success.rawValue
                    }
                } else {
                    day.status = GoalStatus.none.rawValue
                }
                
                return day
            }
    }
}
