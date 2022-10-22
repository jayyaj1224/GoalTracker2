//
//  Rx_Extensions.swift
//  GoalTracker2
//
//  Created by Jay Lee on 17/10/2022.
//

import RxSwift
import RxCocoa
import RxDataSources

extension Reactive where Base: UIPickerView {
    var rowHeight: Binder<CGFloat> {
        Binder(base) { base, value in
            if let delegateProxy = base.delegate as? RxPickerViewDelegateProxy {
                delegateProxy.pickerViewRowHeight = value
            }
        }
    }
    
    var rowWidth: Binder<CGFloat> {
        Binder(base) { base, value in
            if let delegateProxy = base.delegate as? RxPickerViewDelegateProxy {
                delegateProxy.pickerViewRowWidth = value
            }
        }
    }
}
