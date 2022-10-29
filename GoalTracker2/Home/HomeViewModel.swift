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
 UI 자체가 GoalCircle 과 Analysis 파트로 나누어져 있기 때문에, ViewModel 또한 나누어서
 
 */

class HomeVieWModel: ReactiveCompatible {
    let goalViewModelsRelay = BehaviorRelay<[GoalViewModel]>.init(value: [])
    
    init() {
        acceptRefreshedGoals()
    }
    
    func acceptRefreshedGoals() {
        let goalViewModels = GoalManager.shared.goals
            .compactMap(GoalViewModel.init)
        
        goalViewModelsRelay.accept(goalViewModels)
    }
    
    
    
    var cellFactory: (UICollectionView, Int, GoalViewModel) -> UICollectionViewCell = { cv, row, viewModel in
        guard let cell = cv.dequeueReusableCell(withReuseIdentifier: "CircleGoalCell", for: IndexPath(row: row, section: 0)) as? HomeCircularGoalCell else {
            return UICollectionViewCell()
        }
        cell.setupCell(viewModel)
        
        return cell
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
    
    var goalAnalysisViewModel: GoalAnalysisViewModel!
    
    init(goal: Goal) {
        goalCircleViewModel = GoalCircleViewModel(goal: goal)
        goalAnalysisViewModel = GoalAnalysisViewModel(goal: goal)
    }
}

class GoalCircleViewModel {
    var goal: Goal
    
    init(goal: Goal) {
        self.goal = goal
    }
    
    var processPercentage: CGFloat {
        let daysCountToNow = goal.startDate.asDate.daysCountToNow
        var ratio = CGFloat(daysCountToNow)/CGFloat(goal.totalDays)
        ratio = min(1, ratio)
        return ratio*100
    }
}

class GoalAnalysisViewModel {
    var goal: Goal
    
    init(goal: Goal) {
        self.goal = goal
    }
}
