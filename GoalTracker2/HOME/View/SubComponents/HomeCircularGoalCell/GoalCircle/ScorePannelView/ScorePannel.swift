//
//  ScorePannel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 29/11/2022.
//

protocol ScorePannel {
    func set(success: Int, fail: Int)
    var type: ScorePannelType { get }
}

enum ScorePannelType: Int {
    case Digital, Flap
}
