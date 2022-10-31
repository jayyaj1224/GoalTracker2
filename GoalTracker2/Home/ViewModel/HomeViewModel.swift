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
    
    var collectionViewDidScrollSignal: Signal<Void>?
    
    init() {
        getGoals()
    }
    
    func getGoals() {
        var goalViewModels = GoalManager.shared.goals
            .compactMap(GoalViewModel.init)
        
        let viewmodels = Array(repeating: goalViewModels.first!, count: 30)
        
        goalViewModelsRelay.accept(viewmodels)
    }
    
    lazy var cellFactory: (UICollectionView, Int, GoalViewModel) -> UICollectionViewCell = { [weak self] cv, row, viewModel in
        guard let cell = cv.dequeueReusableCell(withReuseIdentifier: "GoalCircleCell", for: IndexPath(row: row, section: 0)) as? GoalCircleCell else {
            return UICollectionViewCell()
        }
        
        cell.setupCell(viewModel)
        
        self?.collectionViewDidScrollSignal?
            .emit(to: cell.rx.setContentOffsetZero)
            .disposed(by: cell.reuseBag)
        
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
    
    var tileViewModel: TileViewModel!
    
    var goalAnalysisViewModel: GoalAnalysisViewModel!
    
    init(goal: Goal) {
        goalCircleViewModel = GoalCircleViewModel(goal: goal)
        goalAnalysisViewModel = GoalAnalysisViewModel(goal: goal)
        tileViewModel = TileViewModel(goal: goal)
    }
}
