//
//  QA Mode.swift
//  GoalTracker2
//
//  Created by Jay Lee on 08/12/2022.
//

import Foundation
import UIKit

extension Goal {
    mutating func qaInit_1() {
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
