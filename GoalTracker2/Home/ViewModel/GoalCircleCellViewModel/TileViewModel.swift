//
//  TileViewModel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 30/10/2022.
//

import UIKit
import RxSwift

class TileViewModel {
    var goal: Goal
    
    init(goal: Goal) {
        self.goal = goal
    }
    
    let tileSize: CGFloat = 16
    
    var spacing: CGFloat = 8
    
    var tileStatusObservable: Observable<[String]> {
        let goalStatusRaw = goal.daysArray.map { $0.status }
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
            let widthHundred = (daysCount/100)*Int(tileSize*10 + spacing)
            let widthLeftOvers = (daysCount%100)/10*Int(tileSize)
            return CGSize(
                width: widthHundred + widthLeftOvers,
                height: Int(tileSize*10)
            )
//        }
    }
    
    func itemSize(at index: Int) -> CGSize {
//        switch self.goal.totalDays {
//        case ...200:
            switch index%100 {
            case 91...99, 0:
                return CGSize(width: tileSize+spacing, height: tileSize)
            default:
                return CGSize(width: tileSize, height: tileSize)
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
