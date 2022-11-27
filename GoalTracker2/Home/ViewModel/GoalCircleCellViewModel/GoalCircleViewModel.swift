//
//  GoalCircleViewModel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 30/10/2022.
//

import UIKit

class GoalCircleViewModel {
    var goal: Goal
    
    init(goal: Goal) {
        self.goal = goal
    }
    
    var processPercentage: CGFloat {
        let startDate = Date.inAnyFormat(dateString: goal.startDate)
        let daysCountToNow = startDate.daysCountToNow
        var ratio = CGFloat(daysCountToNow)/CGFloat(goal.totalDays)
        ratio = min(1, ratio)
        return ratio*100
    }
}
