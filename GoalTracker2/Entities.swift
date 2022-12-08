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
    
    var totalDays: Int = 0
    var startDate: String = ""
    var endDate: String = ""
    
    var status: GoalStatus = .none
    
    var successCount: Int = 0
    var failCount: Int = 0
    var failCap: Int = 0
    
    var daysByMonth: [String: [Day]] = [:]
    var monthsArray: [String] = []
    
    var isPlaceHolder: Bool = false
    
    init(title: String, detail: String, totalDays: Int, failCap: Int) {
        let today = Date()
        
        if title == "1" {
            dummyInit1()
            return
        }
        
        self.title = title
        self.detail = detail
        self.identifier = today.stringFormat(of: .goalIdentifier)
        self.status = GoalStatus.none
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
            
            if (i == 0) || (date.stringFormat(of: .dd) == "01") {
                monthsArray.append(yyyyMM)
            }
        }
    }
}

extension Goal {
    func maxStreak() -> Int {
        var maxStreak = 0
        var streak = 0
        
        let thisMonth = Date().stringFormat(of: .yyyyMM)
        let today = Date().stringFormat(of: .yyyyMMdd)
        
        daysByMonth.forEach { month in
            guard month.key <= thisMonth else { return }
            
            for day in month.value {
                guard day.date <= today else { return }
                
                if day.status == GoalStatus.success.rawValue {
                    streak+=1
                } else {
                    maxStreak = max(maxStreak, streak)
                    streak = 0
                }
            }
        }
        return maxStreak
    }
}



//MARK: TEST TEST TEST TEST
extension Goal {
    mutating func dummyInit1() {
        self.title = "2 hours workout every day. \n(no carbs & sugar) 49"
        self.detail = "aaaa"
        self.identifier = Date().stringFormat(of: .goalIdentifier)
        self.status = GoalStatus.none
        self.totalDays = 700
        
        let today = Date.inAnyFormat(dateString: "20220413")
        self.startDate = today.stringFormat(of: .yyyyMMdd)
        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
        self.failCap = 10
        self.successCount = Date.inAnyFormat(dateString: startDate).daysCountToNow-4
        self.failCount = 4
        
        for i in 1...totalDays {
            let date = today.add(i-1)
            let yyyyMM = date.stringFormat(of: .yyyyMM)
            let yyyyMMdd = date.stringFormat(of: .yyyyMMdd)
            
            var day = Day(date: yyyyMMdd,index: i, status: "none")
            
            if day.date <= Date().stringFormat(of: .yyyyMMdd) {
                switch i {
                case 100,102,103,105:
                    day.status = GoalStatus.fail.rawValue
                default:
                    day.status = GoalStatus.success.rawValue
                }
            } else {
                day.status = GoalStatus.none.rawValue
            }
            
            var temp = daysByMonth[yyyyMM] ?? []
            temp.append(day)
            daysByMonth[yyyyMM] = temp
            
            if (i == 0) || (date.stringFormat(of: .dd) == "01") {
                monthsArray.append(yyyyMM)
            }
        }
    }
    
    
    
//
//    mutating func dummyInit2() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyyMMdd"
//
//        self.title = "1 hour reading every day. Self Reliance by R.W. Emerson. 60."
//        self.detail = "aaaa"
//        self.identifier = Date().stringFormat(of: .goalIdentifier)
//        self.status = GoalStatus.none
//        //self.setType = GoalTrackType.Period
//        self.totalDays = 900
//
//        let today = dateFormatter.date(from: "20220413") ?? Date()
//        self.startDate = today.stringFormat(of: .yyyyMMdd)
//        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
//        self.failCap = 10
//        self.successCount = 119
//        self.failCount = 4
//
//        for i in 1...totalDays {
//            let date = today.add(i-1)
//            let yyyyMM = date.stringFormat(of: .yyyyMM)
//            let yyyyMMdd = date.stringFormat(of: .yyyyMMdd)
//
//            var day = Day(date: yyyyMMdd,index: i, status: "none")
//
//            switch i {
//            case 100,102,103,105:
//                day.status = GoalStatus.fail.rawValue
//            case ...123:
//                day.status = GoalStatus.success.rawValue
//            default:
//                day.status = GoalStatus.none.rawValue
//            }
//
//            var temp = daysByMonth[yyyyMM] ?? []
//            temp.append(day)
//            daysByMonth[yyyyMM] = temp
//        }
//    }
//
//    mutating func dummyInit3() {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyyMMdd"
//
//        self.title = "30 minutes of meditation and self affirmation."
//        self.detail = "aaaa"
//        self.identifier = Date().stringFormat(of: .goalIdentifier)
//        self.status = GoalStatus.none
//        //self.setType = GoalTrackType.Period
//        self.totalDays = 300
//
//        let today = dateFormatter.date(from: "20220820") ?? Date()
//        self.startDate = today.stringFormat(of: .yyyyMMdd)
//        self.endDate = today.add(totalDays-1).stringFormat(of: .yyyyMMdd)
//        self.failCap = 10
//        self.successCount = 119
//        self.failCount = 4
//
//        for i in 1...totalDays {
//            let date = today.add(i-1)
//            let yyyyMM = date.stringFormat(of: .yyyyMM)
//            let yyyyMMdd = date.stringFormat(of: .yyyyMMdd)
//
//            var day = Day(date: yyyyMMdd,index: i, status: "none")
//
//            switch i {
//            case 100,102,103,105,106,107,108:
//                day.status = GoalStatus.fail.rawValue
//            case ...123:
//                day.status = GoalStatus.success.rawValue
//            default:
//                day.status = GoalStatus.none.rawValue
//            }
//
//            var temp = daysByMonth[yyyyMM] ?? []
//            temp.append(day)
//            daysByMonth[yyyyMM] = temp
//        }
//    }
}
