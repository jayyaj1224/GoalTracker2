//
//  MainViewModel.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/06/26.
//

import UIKit
import RxSwift
import RxCocoa

class MainViewModel: ReactiveCompatible {
    let profileViewModel = ProfileViewModel()
    
    let viewModelsRelay = BehaviorRelay<[GoalViewModel3]>.init(value: [])
    
    var goals = [Goal]()
    
    let mainViewDidScroll = PublishSubject<CGPoint>()
//    let mainViewDidEndDecelerate = PublishSubject<CGPoint>()
    
    let currentGoalScrollObserver = PublishSubject<CGFloat>()
    let tileViewIsHiddenSubject = PublishSubject<Void>()
    
    /// currentPage: CGFloat, tileButton.isSelected: Bool
    let tileButtonTapSubject = PublishSubject<(CGFloat, Bool)>()
    
    init() {
        getData()
    }
    
    func getData() {
        let results = GoalManager.shared.goals
        
        let goalViewModels = results
            .sorted { $0.identifier > $1.identifier }
            .compactMap(GoalViewModel3.init)
        
        viewModelsRelay.accept(goalViewModels)
        
        goals = Array(results)
        
//        let vm = goalViewModels + goalViewModels + goalViewModels
//        viewModelsRelay.accept(vm)
    }
    
    func deleteGoalAt(_ index: Int) {
        var viewModels = viewModelsRelay.value
        viewModels.remove(at: index)
        viewModelsRelay.accept(viewModels)
    }
    
    func cellFactory(_ cv: UICollectionView, _ row: Int, _ vm: GoalViewModel3) -> UICollectionViewCell {
        guard let cell = cv.dequeueReusableCell(withReuseIdentifier: "CircleGoalCell", for: IndexPath(row: row, section: 0)) as? GoalCircleCell else {
            return UICollectionViewCell()
        }
        
//        cell.goalCircle.configure(with: vm.circleVm)
//
//        cell.tileBoard.configure(with: vm.tileVm)
        
        
        
//        mainViewDidScroll
//            .subscribe(cell.mainViewDidScrollSubject)
//            .disposed(by: cell.reuseBag)
  
        // did end decelerate
//        mainViewDidEndDecelerate
//            .subscribe(cell.mainViewDidEndDecelerateSubject)
//            .disposed(by: cell.reuseBag)
        
//        cell.currentGoalDidScrollHorizontally
//            .emit(to: currentGoalScrollObserver)
//            .disposed(by: cell.disposeBag)
//        
//        cell.tilesDisappearedSignal
//            .emit(to: tileViewIsHiddenSubject)
//            .disposed(by: cell.disposeBag)
//        
//        tileButtonTapSubject
//            .filter{ CGFloat(row) == $0.0 }
//            .map { $0.1 }
//            .subscribe(cell.shouldPresentTilesSubject)
//            .disposed(by: cell.disposeBag)
        
        return cell
    }
}

extension Reactive where Base: MainViewModel {
    var shouldAddNewGoalOnTheList: Binder<Goal> {
        Binder(base) { base, goal in
            let newGoalViewModel = GoalViewModel3(goal)
            
            var goalViewModels = base.viewModelsRelay.value
            goalViewModels.append(newGoalViewModel)
            
            base.viewModelsRelay.accept(goalViewModels)
        }
    }
    
    var shouldDeleteGoal: Binder<Goal> {
        Binder(base) { base, goal in
            
        }
    }
}

struct GoalViewModel3 {
    let circleVm: CircleViewModel
    let tileVm: TileViewModel2
    
    init(_ goal: Goal) {
        circleVm = CircleViewModel.init(with: goal)
        tileVm = TileViewModel2.init(with: goal)
    }
}

class CircleViewModel {
    var goal: Goal
    
    init(with goal: Goal) {
        self.goal = goal
    }
    
    var processPercentage: CGFloat {
        let daysCountToNow = Date
            .inAnyFormat(dateString: goal.startDate)
            .daysCountToNow
        
        var ratio = CGFloat(daysCountToNow)/CGFloat(goal.totalDays)
        ratio = min(1, ratio)
        return ratio*100
    }
}

class TileViewModel2 {
    var goal: Goal
    
    init(with goal: Goal) {
        self.goal = goal
    }
    
    var tileWidth: CGFloat = 16
    
    var spacing: CGFloat = 8
    
    var tileStatusObservable: Observable<[String]> {
        let goalStatusRaw = goal.dayArray.map { $0.status }
        return Observable<[String]>.just(goalStatusRaw)
    }
    
    func needDateLabelVisible(at index: Int) -> Bool {
        if (index+1)%100 == 0 {
            return true
            
        } else if (index+1) == goal.totalDays {
            return true
            
        } else {
            return false
        }
    }
    
    var boardSize: CGSize {
        let daysCount = goal.totalDays
//
//        if daysCount > 200 {
//            let widthHundred = (daysCount/200)*Int(tileWidth*10 + spacing)
//            let widthLeftOvers = (daysCount%100)/10*Int(tileWidth)
//            return CGSize(
//                width: widthHundred + widthLeftOvers,
//                height: Int(tileWidth*20 + spacing)
//            )
//
//        } else {
            let widthHundred = (daysCount/100)*Int(tileWidth*10 + spacing)
            let widthLeftOvers = (daysCount%100)/10*Int(tileWidth)
            return CGSize(
                width: widthHundred + widthLeftOvers,
                height: Int(tileWidth*10)
            )
//        }
    }
    
    func itemSize(at index: Int) -> CGSize {
//        switch self.goal.totalDays {
//        case ...200:
            switch index%100 {
            case 91...99, 0:
                return CGSize(width: tileWidth+spacing, height: tileWidth)
            default:
                return CGSize(width: tileWidth, height: tileWidth)
            }
            
//        case 201...:
//            switch index%200 {
//            case 181...189:
//                return CGSize(width: tileWidth+spacing, height: tileWidth)
//            case 190:
//                return CGSize(width: tileWidth+spacing, height: tileWidth+spacing)
//            case 191...199, 0:
//                return CGSize(width: tileWidth+spacing, height: tileWidth)
//            default:
//                if index%20 == 10{
//                    return CGSize(width: tileWidth, height: tileWidth+spacing)
//                } else {
//                    return CGSize(width: tileWidth, height: tileWidth)
//                }
//            }
//
//        default:
//            return .zero
//        }
    }
}


class ProfileViewModel {
    var profile: Profile!
    
    init() {
        
    }
    
    func refresh() {
        
    }
    
}
