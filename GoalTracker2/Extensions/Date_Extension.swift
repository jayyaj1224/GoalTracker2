//
//  Date+Extension.swift
//  HabitSquare
//
//  Created by Lee Jong Yun on 2021/12/17.
//

import Foundation

extension String {
    var asDate: StringToDate {
        return StringToDate.init(dateString: self)
    }
    
    var gtStandardDateStringTo: DateToString {
        let date = self.asDate.gtStandard
        return DateToString.init(date)
    }
    
    var th: Int {
        let count = self.asDate.daysCountToNow
        return count
    }
    
    var thText: String {
        switch "\(self)".last {
        case "1":
            return "st"
        case "2":
            return "nd"
        case "3":
            return "rd"
        default:
            return "th"
        }
    }
}

public struct StringToDate {
    var dateString: String
    
    init(dateString: String) {
        self.dateString = dateString
    }
    
    func stringToDate(string: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)
    }
    
    var yyMMddHHmmss_toDate: Date? {
        return self.stringToDate(string: self.dateString, format: "yyMMddHHmmss")
    }
    
    var asIdentifier_toDate: Date? {
        return self.stringToDate(string: self.dateString, format: "yyMMddHHmmss")
    }
    
    var yyMMdd_toDate: Date? {
        return self.stringToDate(string: self.dateString, format: "yyMMdd")
    }
    
    var gtStandard: Date {
        return self.stringToDate(string: self.dateString, format: "yyyyMMdd") ?? Date()
    }
    
    var daysCountToNow: Int {
        return Calendar.current.dateComponents([.day], from: self.gtStandard, to: Date()).day ?? 0
    }
}


extension Date {
    var asString: DateToString {
        return DateToString.init(self)
    }
    
    func stringToDate(string: String, format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: string)
    }
    
    
    var pastCount: Int {
        return Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
    }
    
    var futureCount: Int {
        return Calendar.current.dateComponents([.day], from: Date(), to: self).day ?? 0
    }
    
    func add(_ adding: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: adding, to: self)!
    }
}

public struct DateToString {
    var date: Date
    
    init(_ date: Date) {
        self.date = date
    }
    func format(_ format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: date)
    }
    var yyyyMMdd_slash: String {
        return self.format("yyyy/ MM/ dd")
    }
    var ddMMMM: String {
        return "\(self.format("dd"))th of \(self.format("MMMM"))"
    }
    var e요일: String {
        let dayNumber = self.format("e")
        switch dayNumber {
        case "1": return "월요일"
        case "2": return "화요일"
        case "3": return "수요일"
        case "4": return "목요일"
        case "5": return "금요일"
        case "6": return "토요일"
        default: return "일요일"
        }
    }
    var yyyyMMdd: String {
        return self.format("yyyyMMdd")
    }
    var yyyy_MM_dd: String {
        return self.format("yyyy_MM_dd")
    }
    var yyMMddHHmmss: String {
        return self.format("yyMMddHHmmss")
    }
    var identifier: String {
        return "DG_GOAL_IDENTIFIER_" + self.format("yyMMddHHmmss")
    }
    var yyMMdd_Dot: String {
        return self.format("yy.MM.dd")
    }
    var standard: String {
        return self.format("yyyyMMdd")
    }
    
    var ddMMMEEEE: String {
        return self.format("dd MMM, EEEE")
    }
}
