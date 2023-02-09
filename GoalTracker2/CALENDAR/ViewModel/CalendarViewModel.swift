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
    var goals: [Goal]
    
    var daysIndexRange: [String: ClosedRange<Int>] = [:]
    
    let tableViewDatasourceRelay = BehaviorRelay<[CalendarDatasource]>(value: [])
    
    let goalsEditedSubject = PublishSubject<[Goal]>()
    
    typealias CalendarDatasource = (goal: Goal, range: ClosedRange<Int>?)
    
    var selectedMonth: String = Date().stringFormat(of: .MM)
    var selectedYear: String = Date().stringFormat(of: .yyyy)
    
    init(goals: [Goal]) {
        self.goals = goals
        
        setDatasourceFromGoals()
    }
    
    func setDatasourceFromGoals() {
        daysIndexRange.removeAll()
        
        goals.forEach {
            daysIndexRange[$0.identifier] = calculateDaysIndexRangeFrom($0)
        }
        
        let datasource = goals
            .map {
                CalendarDatasource(goal: $0, range: daysIndexRange[$0.identifier])
            }
        tableViewDatasourceRelay.accept(datasource)
    }
    
    private func calculateDaysIndexRangeFrom(_ goal: Goal) -> ClosedRange<Int>? {
        let calendar = Calendar.current
        
        let goalStartDate = Date.inFormat(of: .yyyyMMdd, dateString: goal.startDate)
        let goalEndDate = Date.inFormat(of: .yyyyMMdd, dateString: goal.endDate)
        
        let firstDateSelected = Date.inFormat(of: .yyyyMMdd, dateString: selectedYear + selectedMonth + "01")
        
        let daysCount = calendar.range(of: .day, in: .month, for: firstDateSelected)!.count
        let lastDateSelected = calendar.date(byAdding: .day, value: daysCount-1, to: firstDateSelected)!
        
        guard firstDateSelected <= goalEndDate else { return nil }
        
        guard goalStartDate <= lastDateSelected else { return nil }
        
        let rangeStartDate = max(goalStartDate, firstDateSelected)
        let rangeEndDate = min(lastDateSelected, goalEndDate)
        
        let startIndex = calendar.dateComponents([.day], from: goalStartDate, to: rangeStartDate).day ?? 0
        let endIndex = calendar.dateComponents([.day], from: goalStartDate, to: rangeEndDate).day ?? 0
        
        return startIndex...endIndex
    }
    
//    func displaySelected() {
//        let keyDate = (selectedYear+selectedMonth)
//        let goalMonths = calendarModel.goalMonth(yyyyMM: keyDate)
//
//        tableViewDatasourceRelay.accept(goalMonths)
//    }
//
//
//    var isEmpty: Bool {
//        tableViewDatasourceRelay.value.isEmpty
//    }
}

//extension CalendarViewModel {
//    func goalTitle(at row: Int) -> String {
//        return tableViewDatasourceRelay.value[row].title
//    }
//
//    func goalIdentifier(at row: Int) -> String {
//        return tableViewDatasourceRelay.value[row].identifier
//    }
//
//    func deleteGoal(with identifier: String) {
//        calendarModel.deleteGoal(with: identifier) { [weak self] in
//
//            self?.displaySelected()
//        }
//    }
//
//    func fixGoal(goalAt: Int, dayAt: Int, status: GoalStatus, goalMonth: GoalMonth) {
//        // fix viewModel
//        var temp = tableViewDatasourceRelay.value
//        temp[goalAt].days[dayAt].status = status.rawValue
//        tableViewDatasourceRelay.accept(temp)
//
//        // fix model
//        let yyyyMM = (selectedYear+selectedMonth)
//        calendarModel.goalFixedReplace(with: temp, date: yyyyMM, goalAt: goalAt, dayAt: dayAt, newStatus: status)
//    }
//}
//

