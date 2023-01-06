//
//  PeriodSettingModel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 17/10/2022.
//

struct PeriodSettingModel {
    let totalDaysModel = Array(1...999).map { "\($0) days" }
    
    func makePickerViewItems(isYearlyTrack: Bool, totalDays: Int) -> ([String],[String]) {
        var totalDaysTextsArray: [String] = []
        var failureTextsArray: [String] = []
        
        if isYearlyTrack {
            totalDaysTextsArray = ["--"]
            failureTextsArray = Array(0...365).map { "\($0) days" }
        } else {
            totalDaysTextsArray = totalDaysModel
            failureTextsArray = Array(0..<totalDays).map { "\($0) days" }
        }
        
        return (totalDaysTextsArray, failureTextsArray)
    }
}
