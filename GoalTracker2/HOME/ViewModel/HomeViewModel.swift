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
 HomeViewModel
    ⎿ GoalViewModel
        ⎿ GoalCircleViewModel
        ⎿ TileBoardViewModel
        ⎿ StatisticsViewModel
    ⎿ GoalViewModel
          ...
 */

class HomeViewModel {
    let goalViewModelsRelay = BehaviorRelay<[GoalViewModel]>.init(value: [])
    
    private let disposeBag = DisposeBag()
    
    init() {
        let goalViewModels = GoalManager.shared
            .getGoals()
            .compactMap(GoalViewModel.init)

        goalViewModelsRelay.accept(goalViewModels)
    }
    
    func goalIdentifier(at row: Int) -> String {
        let viewModels = goalViewModelsRelay.value
        
        return viewModels.isEmpty ? "" : viewModels[row].goal.identifier
    }
    
    func acceptNewGoal(_ goal: Goal) {
        var goalViewModels = goalViewModelsRelay.value
        goalViewModels.append(GoalViewModel(goal: goal))
        
        goalViewModelsRelay.accept(goalViewModels)
    }

    func dayCheck(at row: Int, status: GoalStatus) {
        let viewModels = goalViewModelsRelay.value
        viewModels[row].todayCheck(status)
        
        goalViewModelsRelay.accept(viewModels)
    }
}

class GoalViewModel {
    var goal: Goal
    
    let tileSize: CGFloat = 16
    let tileSpacing: CGFloat = 8
    var tileNumberOfRows: Int = 10
    
    init(goal: Goal) {
        self.goal = goal
    }
    
    var daysObservable: Observable<[Day]> {
        Observable.just(goal.days)
    }
    
    var executionRate: CGFloat {
        let startDate = Date.inAnyFormat(dateString: goal.startDate)
        let daysCountToNow = startDate.daysCountToNow+1
        let ratio = CGFloat(goal.successCount)/CGFloat(daysCountToNow)
        
        return min(1, ratio) * 100
    }
    
    var executionRateStat: String {
        let daysCountToNow = Date.inAnyFormat(dateString: goal.startDate).daysCountToNow+1
        let rate = CGFloat(goal.successCount)/CGFloat(daysCountToNow)*100
        let rateString = String(format: "%.2f", rate)
        return "\(rateString) %"
    }
    
    var maxStreak: String {
        let maxStreak = calculateMaxStreak()
        return (maxStreak == 1) ? "\(maxStreak) day" : "\(maxStreak) days"
    }
    
    var daysLeft: String {
        let daysLeft = Date.inAnyFormat(dateString: goal.endDate).futureCount
        return "\(daysLeft) days left"
    }
    
    var dateRange: String {
        let dateRangeString = [goal.startDate, goal.endDate]
            .map {
                Date.inAnyFormat(dateString: $0)
                    .stringFormat(of: .ddMMMyyyy)
            }
        return "\(dateRangeString[0]) - \(dateRangeString[1])"
    }
    
    var successCount: String {
        return "\(goal.successCount)"
    }
    
    var failCount: String {
        return "\(goal.failCount)/\(goal.failCap)"
    }
    
    var failCountLabelColor: UIColor {
        return  (goal.failCount > goal.failCap) ? .red : .black
    }
    
    func needDateLabelVisible(at index: Int) -> Bool {
        if (index+1)%(10*tileNumberOfRows) == 0 {
            return true
            
        } else if (index+1) == goal.totalDays {
            return true
            
        } else {
            return false
        }
    }
    
    func getBoardSize(numberOfRows: Int=10) -> CGSize {
        self.tileNumberOfRows = numberOfRows
        
        let daysCount = CGFloat(goal.totalDays)
        
        var width: CGFloat = 0
        let numberOfColumns = ceil(daysCount/CGFloat(numberOfRows))
        
        width += tileSize*numberOfColumns
        width += tileSpacing*(numberOfColumns/10)
        
        if width > K.screenWidth || numberOfRows == 1 {
            return CGSize(width: ceil(width), height: tileSize*CGFloat(numberOfRows))
        } else {
            return getBoardSize(numberOfRows: numberOfRows-1)
        }
    }
    
    func getItemSizes() -> [CGSize] {
        return Array(1...goal.days.count)
            .map { index in
                var isLastColumnOfBlock = false
                
                let maxTilesPerBlock = tileNumberOfRows*10
                let indexInBlock = index % maxTilesPerBlock
                
                if (indexInBlock > maxTilesPerBlock-tileNumberOfRows) || (indexInBlock == 0) {
                    isLastColumnOfBlock = true
                }
                
                if isLastColumnOfBlock {
                    return CGSize(width: tileSize+tileSpacing, height: tileSize)
                } else {
                    return CGSize(width: tileSize, height: tileSize)
                }
            }
    }
    
    func getGoalCopyStrings() -> String {
        return """
                    < \(goal.title) >
                    • Execution rate: \(executionRate) %
                    • Max streak: \(maxStreak)
                    • Success count: \(successCount)
                    • Fail count/cap: \(failCount)
                    • Days left: \(daysLeft)
                    • Date: \(dateRange)
                    
                    **copied @(\(Date().stringFormat(of: .ddMMMEEEE_Comma_Space)))
            """
    }
    
    private func calculateMaxStreak() -> Int {
        var maxStreak = 0
        var streak = 0
        let today = Date().stringFormat(of: .yyyyMMdd)
        
        for day in goal.days where day.date<=today {
            if day.status == GoalStatus.success.rawValue {
                streak+=1
            } else {
                streak = 0
            }
            maxStreak = max(maxStreak, streak)
        }
        return maxStreak
    }
    
    func todayCheck(_ status: GoalStatus) {
        let daysCountFromStart = Date
            .inFormat(of: .yyyyMMdd, dateString: goal.startDate)
            .daysCountToNow
        
        goal.days[daysCountFromStart].status = status.rawValue
        
        if status == .success {
            goal.successCount+=1
            
            if goal.status != .none {
                goal.failCount-=1
            }
        } else {
            goal.successCount-=1
            goal.failCount+=1
        }

        GoalManager.shared.update(goal)
    }
}
