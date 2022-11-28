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

class CalendarViewModel {
    let goalsMonthlyRelay = BehaviorRelay<[GoalMonthlyViewModel]>(value: [])
    
    var goalMonthlyViewModels: [String : [GoalMonthlyViewModel]] = [:]
    
    var selectedMonth: String = Date().stringFormat(of: .MM)
    
    var selectedYear: String = Date().stringFormat(of: .yyyy)
    
    func displaySelected() {
        let key = (selectedYear+selectedMonth)
        let selectedMonthGoals = goalMonthlyViewModels[key] ?? []
        
        goalsMonthlyRelay.accept(selectedMonthGoals)
    }
    
    func setViewModelsData() {
        goalMonthlyViewModels.removeAll(keepingCapacity: true)
        
        
        
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
