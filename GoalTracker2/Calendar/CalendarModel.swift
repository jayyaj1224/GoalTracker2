//
//  CalendarModel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 30/11/2022.
//

import Foundation

class CalendarModel {
    private var goals: [Goal] = []
    private var goalMonthByDate: [String:[GoalMonth]] = [:]

    var minYear: Int = 2999
    var maxYear: Int = 0
    
    func setData() {
        goals = GoalRealmManager.shared.goals
            .sorted { $0.identifier < $1.identifier }
        
        goals.forEach(addGoalByMonth)
    }
    
    func addGoalByMonth(goal: Goal) {
        let title = goal.title
        let identifier = goal.identifier
        
        goal.daysByMonth
            .forEach { day in
                var tempArray = goalMonthByDate[day.key] ?? []
                
                tempArray.append(GoalMonth(title: title, days: day.value, identifier: identifier))
                goalMonthByDate[day.key] = tempArray
            }
        
        minYear = min(Int(goal.startDate)!/10000, minYear)
        maxYear = max(Int(goal.endDate)!/10000, maxYear)
    }
    
    func goalMonth(yyyyMM date: String) -> [GoalMonth] {
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
    
    func goalFixedReplace(with fixedData: [GoalMonth], date yyyyMM: String, goalAt: Int, dayAt: Int, newStatus: GoalStatus) {
        goalMonthByDate[yyyyMM] = fixedData
        
        if var goal = goals.filter({ $0.identifier == fixedData[goalAt].identifier }).first {
            if newStatus == .success {
                goal.successCount+=1
                goal.failCount-=1
            }
            if newStatus == .fail {
                goal.successCount-=1
                goal.failCount+=1
            }
            goal.daysByMonth[yyyyMM]?[dayAt].status = newStatus.rawValue
            
            GoalRealmManager.shared.update(goal)
        }
    }
}

struct GoalMonth {
    let title: String
    var days: [Day]
    let identifier: String
    
    init(title: String, days: [Day], identifier: String) {
        self.title = title
        self.days = days
        self.identifier = identifier
    }
}
