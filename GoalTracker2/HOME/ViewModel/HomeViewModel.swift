//
//  HomeViewModel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 12/09/2022.
//

import UIKit
import RxSwift
import RxCocoa

/*
 HomeViewModel - goalViewModelsRelay: BehaviorRelay<[GoalViewModel]>

 GoalViewModel
      ⎿ GoalCircleViewModel
      ⎿ TileBoardViewModel
      ⎿ StatisticsViewModel

 */

class HomeViewModel {
    let goalViewModelsRelay = BehaviorRelay<[GoalViewModel]>.init(value: [])
    
    private let disposeBag = DisposeBag()
    
    init() {
        let goalVmArray = GoalManager.shared.goals
            .compactMap(GoalViewModel.init)

        goalViewModelsRelay.accept(goalVmArray)
    }
    
    func goalIdentifier(at row: Int) -> String {
        let viewModels = goalViewModelsRelay.value
        
        guard viewModels.isEmpty == false else { return "" }
        
        return viewModels[row].goal.identifier
    }
    
    func acceptNewGoal(_ new: Goal) {
        var goalsArray = goalViewModelsRelay.value
        goalsArray.append(GoalViewModel(goal: new))
        
        goalViewModelsRelay.accept(goalsArray)
    }
}

extension HomeViewModel {
    func dayCheck(at row: Int) {
        let viewModels = goalViewModelsRelay.value
        viewModels[row].todayCheck(true)
        
        DispatchQueue.main.async {
            self.goalViewModelsRelay.accept(viewModels)
        }
    }
    
    func dayUncheck(at row: Int) {
        let viewModels = goalViewModelsRelay.value
        viewModels[row].todayCheck(false)
        DispatchQueue.main.async {
            self.goalViewModelsRelay.accept(viewModels)
        }
    }
}

class GoalViewModel {
    var goal: Goal

    var goalCircleViewModel: GoalCircleViewModel!
    
    var tileBoardViewModel: TileBoardViewModel!
    
    var goalStatsViewModel: GoalStatsViewModel!
    
    var todayChecked = false
    
    func todayCheck(_ success: Bool) {
        todayChecked = success
        
        let today_yyyyMMdd = Date().stringFormat(of: .yyyyMMdd)
        let today_yyyyMM = Date().stringFormat(of: .yyyyMM)
        var thisMonthDays = goal.daysByMonth[today_yyyyMM] ?? []
        
        for i in thisMonthDays.indices {
            if today_yyyyMMdd == thisMonthDays[i].date {
                let status: GoalStatus = success ? .success : .fail
                thisMonthDays[i].status = status.rawValue
                break
            }
        }
        
        if success {
            goal.successCount+=1
        } else {
            goal.successCount-=1
        }
        goal.daysByMonth[today_yyyyMM] = thisMonthDays
        
        setViewModel(with: goal)
        
        GoalManager.shared.update(goal)
    }
    
    init(goal: Goal) {
        self.goal = goal
        
        setViewModel(with: goal)
        
        setTodayChecked()
    }
    
    private func setViewModel(with goal: Goal) {
        goalCircleViewModel = GoalCircleViewModel(goal: goal)
        tileBoardViewModel = TileBoardViewModel(goal: goal)
        goalStatsViewModel = GoalStatsViewModel(goal: goal)
    }
    
    private func setTodayChecked() {
        let today_yyyyMMdd = Date().stringFormat(of: .yyyyMMdd)
        let today_yyyyMM = Date().stringFormat(of: .yyyyMM)
        let thisMonthDays = goal.daysByMonth[today_yyyyMM] ?? []
        
        for day in thisMonthDays {
            if today_yyyyMMdd == day.date {
                if day.status == GoalStatus.success.rawValue {
                    todayChecked = true
                } else {
                    todayChecked = false
                }
                break
            }
        }
    }
}
