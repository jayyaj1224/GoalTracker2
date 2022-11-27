//
//  Date+Extension.swift
//  HabitSquare
//
//  Created by Lee Jong Yun on 2021/12/17.
//

import Foundation

//MARK: - Date Calculate
extension Date {
    var pastCount: Int {
        return Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
    }
    
    var futureCount: Int {
        return Calendar.current.dateComponents([.day], from: Date(), to: self).day ?? 0
    }
    
    func add(_ adding: Int) -> Date {
        return Calendar.current.date(byAdding: .day, value: adding, to: self)!
    }
    
    var daysCountToNow: Int {
        return Calendar.current.dateComponents([.day], from: self, to: Date()).day ?? 0
    }
}


//MARK: - Date To String
extension Date {
    func stringFormat(of dateFormat: Date.Format) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.rawValue
        dateFormatter.locale = Locale(identifier: "en_US")
        
        if dateFormat == Date.Format.goalIdentifier  {
            return "DG_GOAL_IDENTIFIER_" + dateFormatter.string(from: self)
        }
        
        return dateFormatter.string(from: self)
    }
}


//MARK: - String to Date
extension Date {
    static func inAnyFormat(dateString: String) -> Date {
        for format in Date.Format.allCases {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = format.rawValue
            
            if let date = dateFormatter.date(from: dateString) {
                return date
            }
        }
        
        return Date()
    }
    
    static func inFormat(of dateFormat: Date.Format, dateString: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat.rawValue
        
        return dateFormatter.date(from: dateString) ?? Date()
    }
}

//MARK: - Date Format
extension Date {
    enum Format: String {
        case yyyy,          MMMM,           MM,         M,
             dd,            d,              EEEE,
             yyyyMMdd,      yyyy_MM_dd,     yyMMddHHmmss,
             ddMMMM,        yyyyMM
             
        
        case yyyyMMdd_Slash = "yyyy/ MM/ dd"

        case goalIdentifier = "yyyyMMddHHmmss"

        case yyMMdd_Dot = "yy.MM.dd"

        case ddMMMEEEE_Comma_Space = "dd MMM, EEEE"

        static let allCases: [Format] = [
            yyyyMMdd_Slash,         ddMMMM,         EEEE,           goalIdentifier,
            yyyyMMdd,               yyyy_MM_dd,     yyMMddHHmmss,   yyMMdd_Dot,
            ddMMMEEEE_Comma_Space,  yyyy,           MM,             M,
            dd,                     d,              MMMM,           yyyyMM
        ]
    }
}
