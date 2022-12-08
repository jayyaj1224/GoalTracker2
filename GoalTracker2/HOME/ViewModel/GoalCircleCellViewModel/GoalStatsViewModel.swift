//
//  GoalStatsViewModel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 30/10/2022.
//

import Foundation

class GoalStatsViewModel {
    var goal: Goal
    
    var executionRate: String
    var maxStreak: String = ""
    var daysLeft: String
    var dateRange: String
    var successCount: String
    var failCount: String
    
    
    init(goal: Goal) {
        self.goal = goal
        
        let daysCountToNow = Date.inAnyFormat(dateString: goal.startDate).daysCountToNow
        let rate = CGFloat(goal.successCount)/CGFloat(daysCountToNow)*100
        let rateString = String(format: "%.2f", rate)
        
        let daysLeft = Date.inAnyFormat(dateString: goal.endDate).futureCount
        
        
        let dateRangeString = [goal.startDate, goal.endDate]
            .map {
                Date.inAnyFormat(dateString: $0)
                    .stringFormat(of: .ddMMMyyyy)
            }
        
        self.executionRate = "\(rateString) %"
        self.daysLeft = "\(daysLeft) days left"
        self.dateRange = "\(dateRangeString[0]) - \(dateRangeString[1])"
        self.successCount = "\(goal.successCount)"
        self.failCount = "\(goal.failCount)/\(goal.failCap)"
        self.maxStreak = "\(calculateMaxStreak()) days"
    }
    
    private func calculateMaxStreak() -> Int {
        var maxStreak = 0
        var streak = 0
        
        let thisMonth = Date().stringFormat(of: .yyyyMM)
        let today = Date().stringFormat(of: .yyyyMMdd)
        
        goal.daysByMonth.forEach { month in
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

