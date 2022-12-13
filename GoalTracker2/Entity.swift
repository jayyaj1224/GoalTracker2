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
        
        switch title {
        case "1":
            qaInit_1()
            return
        case "2":
            qaInit_2()
            return
        case "3":
            qaInit_3()
            return
        case "4":
            qaInit_4()
            return
        case "5":
            qaInit_5()
            return
        default:
            break
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
            let date = today.add(i)
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
