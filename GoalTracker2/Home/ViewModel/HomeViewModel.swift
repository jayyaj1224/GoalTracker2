//
//  HomeViewModel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 12/09/2022.
//

import UIKit
import RxSwift
import RxCocoa

class HomeViewModel: ReactiveCompatible {
    let goalViewModelsRelay = BehaviorRelay<[GoalViewModel]>.init(value: [])
    
    private let disposeBag = DisposeBag()
    
    init() {
        let goalVmArray = GoalRealmManager.shared.goals
            .compactMap(GoalViewModel.init)

        goalViewModelsRelay.accept(goalVmArray)
    }
    
    func goalIdentifier(at row: Int) -> String {
        let viewModels = goalViewModelsRelay.value
        
        guard viewModels.isEmpty == false else { return "" }
        
        return viewModels[row].goal.identifier
    }
}

extension HomeViewModel {
    func dayCheck(at row: Int) {
        let viewModels = goalViewModelsRelay.value
        viewModels[row].todayCheck(true)
        
        goalViewModelsRelay.accept(viewModels)
    }
    
    func dayUncheck(at row: Int) {
        let viewModels = goalViewModelsRelay.value
        viewModels[row].todayCheck(false)
        
        goalViewModelsRelay.accept(viewModels)
    }
}

extension Reactive where Base: HomeViewModel {
    var relayAcceptNewGoal: Binder<Goal> {
        Binder(base) {base, goal in
            var goalsArray = base.goalViewModelsRelay.value
            goalsArray.append(GoalViewModel(goal: goal))
            
            base.goalViewModelsRelay.accept(goalsArray)
        }
    }
}

class GoalViewModel {
    var goal: Goal

    var goalCircleViewModel: GoalCircleViewModel!
    
    var tileViewModel: TileViewModel!
    
    var goalAnalysisViewModel: GoalAnalysisViewModel!
    
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
        
        GoalRealmManager.shared.update(goal)
    }
    
    init(goal: Goal) {
        self.goal = goal
        
        setViewModel(with: goal)
        
        setTodayChecked()
    }
    
    private func setViewModel(with goal: Goal) {
        goalCircleViewModel = GoalCircleViewModel(goal: goal)
        goalAnalysisViewModel = GoalAnalysisViewModel(goal: goal)
        tileViewModel = TileViewModel(goal: goal)
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
