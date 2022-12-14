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

class PeriodSettingViewModel: ReactiveCompatible {
    let periodModel = PeriodSettingModel()
    
    let datasourceRelay = BehaviorRelay<([String],[String])>(value: ([],[]))
    
    var isYearlyTrack: Bool = false
    
    init() {
        let initialItems = periodModel.makePickerViewItems(isYearlyTrack: false, totalDays: 100)
        
        datasourceRelay.accept(initialItems)
    }
    
    lazy var viewPickerAdapter = RxPickerViewViewAdapter<([String],[String])>(
        components: ([],[]),
        numberOfComponents: { _,_,_  in
            return 2
        },
        numberOfRowsInComponent: { [weak self] datasource, pickerView, items, component -> Int in
            guard let self = self else { return 0 }
            
            switch component {
            case 0:
                return items.0.count
            case 1:
                return items.1.count
            default:
                return 0
            }
        },
        viewForRow: { [weak self] datasource, pickerView, items, row, component, view -> UIView in
            let reuseView = (view as? AddGoalDatePickerRowView) ?? AddGoalDatePickerRowView()
            
            guard let self = self else { return reuseView }
            
            switch component {
            case 0:
                var totalDaysText = items.0[row]
                
                if pickerView.selectedRow(inComponent: 0) == row {
                    totalDaysText += " total"
                }
                reuseView.componentLabel.text =  totalDaysText
            case 1:
                var maxFailLabelText = items.1[row]
                
                if pickerView.selectedRow(inComponent: 1) == row {
                    maxFailLabelText += " max fail"
                }
                reuseView.componentLabel.text = maxFailLabelText
            default:
                break
            }
            return reuseView
        }
    )
}

extension Reactive where Base: PeriodSettingViewModel {
    var shouldChangeMaxFailRange: Binder<Int> {
        Binder(base) { base, totalPeriod in
            let model = base.periodModel
            let items = model.makePickerViewItems(isYearlyTrack: false, totalDays: totalPeriod)
            
            base.datasourceRelay.accept(items)
        }
    }
}
