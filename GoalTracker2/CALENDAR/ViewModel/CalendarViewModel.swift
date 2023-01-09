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
  ⎿ yyyyMM : Goal[GoalMonthlyViewModel]
  
 */

class CalendarViewModel {
    let tableViewDatasourceRelay = BehaviorRelay<[GoalMonth]>(value: [])
    
    var calendarModel: CalendarModel!
    
    var selectedMonth: String = Date().stringFormat(of: .MM)
    var selectedYear: String = Date().stringFormat(of: .yyyy)
    
    func displaySelected() {
        let keyDate = (selectedYear+selectedMonth)
        let goalMonths = calendarModel.goalMonth(yyyyMM: keyDate)
        
        tableViewDatasourceRelay.accept(goalMonths)
    }
    
    var yearsRange: [String] {
        Array(calendarModel.minYear...calendarModel.maxYear)
            .map(String.init)
    }
    
    var isEmpty: Bool {
        tableViewDatasourceRelay.value.isEmpty
    }
}

extension CalendarViewModel {
    func goalTitle(at row: Int) -> String {
        return tableViewDatasourceRelay.value[row].title
    }
    
    func goalIdentifier(at row: Int) -> String {
        return tableViewDatasourceRelay.value[row].identifier
    }
    
    func deleteGoal(with identifier: String) {
        calendarModel.deleteGoal(with: identifier) { [weak self] in
            
            self?.displaySelected()
        }
    }
    
    func fixGoal(goalAt: Int, dayAt: Int, status: GoalStatus, goalMonth: GoalMonth) {
        // fix viewModel
        var temp = tableViewDatasourceRelay.value
        temp[goalAt].days[dayAt].status = status.rawValue
        tableViewDatasourceRelay.accept(temp)
        
        // fix model
        let yyyyMM = (selectedYear+selectedMonth)
        calendarModel.goalFixedReplace(with: temp, date: yyyyMM, goalAt: goalAt, dayAt: dayAt, newStatus: status)
    }
}


