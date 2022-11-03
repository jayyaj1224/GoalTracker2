//
//  HomeViewModel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 12/09/2022.
//

import UIKit
import RxSwift
import RxCocoa

class HomeVieWModel: ReactiveCompatible {
    let goalViewModelsRelay = BehaviorRelay<[GoalViewModel]>.init(value: [])

    init() {
        getGoals()
    }
    
    func getGoals() {
        let goalViewModels = GoalManager.shared.goals
            .compactMap(GoalViewModel.init)
        
        let first = goalViewModels.first!
        let arrr = Array(repeating: first, count: 30)
        
        goalViewModelsRelay.accept(arrr)
    }
}

extension Reactive where Base: HomeVieWModel {
    var relayAcceptNewGoal: Binder<Goal> {
        Binder(base) {base, goal in
            var goalsArray = base.goalViewModelsRelay.value
            goalsArray.append(GoalViewModel(goal: goal))
            
            base.goalViewModelsRelay.accept(goalsArray)
        }
    }
}

struct GoalViewModel {
    var goalCircleViewModel: GoalCircleViewModel!
    
    var tileViewModel: TileViewModel!
    
    var goalAnalysisViewModel: GoalAnalysisViewModel!
    
    init(goal: Goal) {
        goalCircleViewModel = GoalCircleViewModel(goal: goal)
        goalAnalysisViewModel = GoalAnalysisViewModel(goal: goal)
        tileViewModel = TileViewModel(goal: goal)
    }
}
