//
//  GoalStatsViewModel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 30/10/2022.
//


class GoalStatsViewModel {
    var goal: Goal
    
    var executionRate: String
    var maxStreak: String
    var daysLeft: String
    var dateRange: String
    var successCount: String
    var failCount: String
    
    
    init(goal: Goal) {
        self.goal = goal
        self.executionRate = "98.32 %"
        self.maxStreak = "37 days"
        self.daysLeft = "132 daysLeft"
        self.dateRange = "12 Aug 2022 - 31 Dec 2023"
        self.successCount = "132"
        self.failCount = "2"
    }
}

