//
//  CalendarViewModel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 26/11/2022.
//

import Foundation
import RxSwift
import RxCocoa

/*
 CalendarViewModel
  ⎿ yyyyMM : [GoalMonthlyViewModel]
  
 */
var i: Double = 0.0

class CalendarViewModel {
    let goalsMonthlyRelay = BehaviorRelay<[GoalMonthlyViewModel]>(value: [])
    
    var goalMonthlyViewModels: [String : [GoalMonthlyViewModel]] = [:]
    
    var selectedMonth: String = ""
    
    var selectedYear: String = ""
    
    init() {
        setViewModels()
        
        selectedYear = Date().stringFormat(of: .yyyy)
        selectedMonth = Date().stringFormat(of: .MM)
        
        setGoalCalendar()
    }
    
    private func setViewModels() {
        GoalManager.shared.goals
            .forEach { goal in
                
                var daysTemp: [String: [Day]] = [:]
                
                goal.dayArray
                    .forEach { day in
                        let date = Date.inAnyFormat(dateString: day.date)
                        let yyyyMM = date.stringFormat(of: .yyyyMM)
                        
                        var days = daysTemp[yyyyMM] ?? []
                        days.append(day)
                        daysTemp[yyyyMM] = days
                    }
                
                for key in daysTemp.keys {
                    var vmsTemp = goalMonthlyViewModels[key] ?? []
                    vmsTemp.append(GoalMonthlyViewModel.init(title: goal.title, days: daysTemp[key]!, identifier: goal.identifier))
                    goalMonthlyViewModels[key] = vmsTemp
                }
            }
    }
    
    func setGoalCalendar() {
        let key = (selectedYear+selectedMonth)
        let selectedMonthGoals = goalMonthlyViewModels[key] ?? []
        
        goalsMonthlyRelay.accept(selectedMonthGoals)
    }
}

struct GoalMonthlyViewModel {
    let title: String
    let days: [Day]
    let identifier: String
    
    init(title: String, days: [Day], identifier: String) {
        self.title = title
        self.days = days
        self.identifier = identifier
    }
}
