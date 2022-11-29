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
        setGoalsRelay()
    }
    
    private func setGoalsRelay() {
        let goalVmArray = GoalRealmManager.shared.goals
            .compactMap(GoalViewModel.init)

        goalViewModelsRelay.accept(goalVmArray)
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

struct GoalViewModel {
    let goal: Goal

    var goalCircleViewModel: GoalCircleViewModel!
    
    var tileViewModel: TileViewModel!
    
    var goalAnalysisViewModel: GoalAnalysisViewModel!
    
    init(goal: Goal) {
        self.goal = goal
        
        goalCircleViewModel = GoalCircleViewModel(goal: goal)
        goalAnalysisViewModel = GoalAnalysisViewModel(goal: goal)
        tileViewModel = TileViewModel(goal: goal)
    }
}
