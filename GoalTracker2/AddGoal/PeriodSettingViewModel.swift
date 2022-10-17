//
//  PeriodSettingViewModel.swift
//  GoalTracker2
//
//  Created by Jay Lee on 17/10/2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct PeriodSettingModel {
    let totalDaysModel = Array(1...1000).map { "\($0) days" }
    
    
}

class PeriodSettingViewModel {
    
    let datasourceRelay = BehaviorRelay<[String]>(value: [])
    
    var isYearlyTrack: Bool = false
    
    init() {
        
    }
    
    let totalDaysModel = Array(1...1000)
        .map { "\($0) days" }
    
    lazy var viewPickerAdapter = RxPickerViewViewAdapter<[String]>(
        components: [],
        numberOfComponents: { _,_,_  in
            return 2
        },
        numberOfRowsInComponent: { [weak self] datasource, pickerView, model, component -> Int in
            guard let self = self else { return 0 }
            
            switch component {
            case 0:
                return self.isYearlyTrack ? 1 : model.count
            case 1:
                return self.isYearlyTrack ? 365 : pickerView.selectedRow(inComponent: 0)+1
            default:
                return 0
            }
        },
        // datasource, pickerView, models, row, component, view
        viewForRow: { [weak self] _, _, model, row, component, view -> UIView in
            let reuseView = (view as? AddGoalDatePickerRowView) ?? AddGoalDatePickerRowView()
            
            guard let self = self else { return reuseView }
            
            switch component {
            case 0:
                if self.isYearlyTrack {
                    reuseView.componentLabel.text = "--"
                } else {
                    reuseView.componentLabel.text = model[row]
                }
            case 1:
                reuseView.componentLabel.text = model[row]
            default:
                break
            }
            return reuseView
        }
    )
}
