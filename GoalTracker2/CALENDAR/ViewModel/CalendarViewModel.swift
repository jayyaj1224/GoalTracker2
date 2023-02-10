//
//  CalendarViewModel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 26/11/2022.
//

import Foundation
import RxSwift
import RxCocoa

class CalendarViewModel {
    var goals: [Goal]
    var daysIndexRange: [String: ClosedRange<Int>] = [:]
    
    let tableViewDatasourceRelay = BehaviorRelay<[CalendarDatasource]>(value: [])
    
    typealias CalendarDatasource = (goal: Goal, range: ClosedRange<Int>?)
    
    var selectedMonth: String = Date().stringFormat(of: .MM)
    var selectedYear: String = Date().stringFormat(of: .yyyy)
    
    var hasEdited = false
    
    init(goals: [Goal]) {
        self.goals = goals
        
        setRange()
        reloadDatasource()
    }
    
    func monthSelected(_ month: Int) {
        selectedMonth = String(format: "%02d", month)
        
        setRange()
        reloadDatasource()
    }
    
    private func reloadDatasource() {
        let datasource = goals.map {
            CalendarDatasource(goal: $0, range: daysIndexRange[$0.identifier])
        }
        tableViewDatasourceRelay.accept(datasource)
    }
    
    private func setRange() {
        daysIndexRange.removeAll()
        
        goals.forEach {
            daysIndexRange[$0.identifier] = calculateDaysIndexRangeFrom($0)
        }
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
}

extension CalendarViewModel {
    func deleteGoal(with identifier: String) {
        goals.removeAll { $0.identifier == identifier }
        
        reloadDatasource()
    }
    
    func fixGoal(identifier: String, dayIndex: Int, status: GoalStatus) {
        hasEdited = true
        
        guard let goalEnumerated = goals
            .enumerated()
            .first(where: {$0.element.identifier == identifier}) else { return }
        
        var goal = goalEnumerated.element
        let offset = goalEnumerated.offset
        
        GoalManager.dayEdit(goal: &goal, dayIndex: dayIndex, status: status)
        
        goals[offset] = goal
        
        reloadDatasource()
        
        GoalManager.shared.update(goal)
    }
}

