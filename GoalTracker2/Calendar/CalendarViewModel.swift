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
//        goalMonthlyViewModels.removeAll(keepingCapacity: true)
//        
//        GoalManager.shared.getGoals { [weak self] goals in
//            guard let self = self else { return }
//            
//            goals.forEach { goal in
//                var daysTemp: [String: [Day]] = [:]
//                
//                goal.daysArray
//                    .forEach { day in
//                        let date = Date.inAnyFormat(dateString: day.date)
//                        let yyyyMM = date.stringFormat(of: .yyyyMM)
//                        
//                        var days = daysTemp[yyyyMM] ?? []
//                        days.append(day)
//                        daysTemp[yyyyMM] = days
//                    }
//                
//                for key in daysTemp.keys {
//                    var vmsTemp = self.goalMonthlyViewModels[key] ?? []
//                    vmsTemp.append(GoalMonthlyViewModel.init(title: goal.title, days: daysTemp[key]!, identifier: goal.identifier))
//                    
//                    self.goalMonthlyViewModels[key] = vmsTemp
//                }
//            }
//            
//        }
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
