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
    
    var tileStatusObservable: Observable<[String]> {
        let goalStatusString = goal.monthsArray
            .map { goal.daysByMonth[$0] ?? [] }
            .reduce([], +)
            .map(\.status)
        
        return Observable<[String]>.just(goalStatusString)
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
        let widthHundred = (daysCount/100)*Int(tileSize*10 + spacing)
        let widthLeftOvers = (daysCount%100)/10*Int(tileSize)
        
        let width = widthHundred + widthLeftOvers
        let height = Int(tileSize*10)
        
        return CGSize(width: width, height: height)
    }
    
    func itemSize(at index: Int) -> CGSize {
        switch index%100 {
        case 91...99, 0:
            return CGSize(width: tileSize+spacing, height: tileSize)
        default:
            return CGSize(width: tileSize, height: tileSize)
        }
    }
}
