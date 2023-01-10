//
//  TileViewModel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 30/10/2022.
//

import UIKit
import RxSwift

class TileBoardViewModel {
    var goal: Goal
    
    init(goal: Goal) {
        self.goal = goal
    }
    
    let tileSize: CGFloat = 16
    
    var spacing: CGFloat = 8
    
    var numberOfRows: Int = 10
    
    var daysObservable: Observable<[Day]> {
        let days = goal.monthsArray
            .map { goal.daysByMonth[$0] ?? [] }
            .reduce([], +)
        
        return Observable<[Day]>.just(days)
    }
    
    func needDateLabelVisible(at index: Int) -> Bool {
        if (index+1)%(10*numberOfRows) == 0 {
            return true
            
        } else if (index+1) == goal.totalDays {
            return true
            
        } else {
            return false
        }
    }
    
    func getBoardSize(numberOfRows: Int=10) -> CGSize {
        self.numberOfRows = numberOfRows
        
        let daysCount = CGFloat(goal.totalDays)
        
        var width: CGFloat = 0
        let numberOfColumns = ceil(daysCount/CGFloat(numberOfRows))
        
        width += tileSize*numberOfColumns
        width += spacing*(numberOfColumns/10)
        
        if width > K.screenWidth || numberOfRows == 1 {
            return CGSize(width: ceil(width), height: tileSize*CGFloat(numberOfRows))
        } else {
            return getBoardSize(numberOfRows: numberOfRows-1)
        }
    }
    
    func itemSize(at index: Int) -> CGSize {
        var isLastColumnOfBlock = false
        
        let maxTilesPerBlock = numberOfRows*10
        let indexInBlock = index % maxTilesPerBlock
        
        if (indexInBlock > maxTilesPerBlock-numberOfRows) || (indexInBlock == 0) {
            isLastColumnOfBlock = true
        }
        
        if isLastColumnOfBlock {
            return CGSize(width: tileSize+spacing, height: tileSize)
        } else {
            return CGSize(width: tileSize, height: tileSize)
        }
    }
}
