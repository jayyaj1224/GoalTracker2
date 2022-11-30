//
//  CalendarModel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 30/11/2022.
//

import Foundation

class CalendarModel {
    private var goalMonthByDate: [String:[GoalMonth]] = [:]
    
    func setData() {
        GoalRealmManager.shared.goals.forEach(addGoalByMonth)
    }
    
    func addGoalByMonth(goal: Goal) {
        let title = goal.title
        let identifier = goal.identifier
        
        goal.daysByMonth
            .forEach { day in
                var tempArray = goalMonthByDate[day.key] ?? []
                let count = tempArray.count
                
                tempArray.append(GoalMonth(title: title, days: day.value, identifier: identifier))
                goalMonthByDate[day.key] = tempArray
            }
    }
    
    func goalMonth(in date: String) -> [GoalMonth] {
        return goalMonthByDate[date] ?? []
    }
    
    func deleteGoal(with identifier: String, completion: (()->Void)?) {
        // Realm Delete
        GoalRealmManager.shared.deleteGoal(with: identifier)
        
        for goalMonths in goalMonthByDate {
            var goalMonthsTemp = goalMonths.value
            
            goalMonths.value
                .enumerated()
                .forEach { i, goal in
                    if goal.identifier == identifier {
                        goalMonthsTemp.remove(at: i)
                        return
                    }
                }
            
            goalMonthByDate[goalMonths.key] = goalMonthsTemp
        }
        
        completion?()
    }
}

struct GoalMonth {
    let title: String
    let days: [Day]
    let identifier: String
    
    init(title: String, days: [Day], identifier: String) {
        self.title = title
        self.days = days
        self.identifier = identifier
    }
}
