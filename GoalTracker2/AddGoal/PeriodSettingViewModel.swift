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
    let model = PeriodSettingModel()
    
    let datasourceRelay = BehaviorRelay<([String],[String])>(value: ([],[]))
    
    var isYearlyTrack: Bool = false
    
    init() {
        let initialItems = model.pickerViewItems(isYearlyTrack: false, totalDays: 100)
        
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
                reuseView.componentLabel.text =  items.0[row]
            case 1:
                reuseView.componentLabel.text = items.1[row]
            default:
                break
            }
            return reuseView
        }
    )
}

extension Reactive where Base: PeriodSettingViewModel {
    var shouldUpdateModel: Binder<(totalDays: Int, isYearlyTrack: Bool)> {
        Binder(base) { base, selected in
            let items = base.model.pickerViewItems(
                isYearlyTrack: selected.isYearlyTrack,
                totalDays: selected.totalDays
            )
            
            base.datasourceRelay.accept(items)
        }
    }
}
