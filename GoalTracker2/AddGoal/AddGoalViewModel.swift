//
//  AddGoalViewModel.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/06/26.
//

import RxSwift
import RxCocoa

class AddGoalViewModel: ReactiveCompatible {
    typealias PickerLabelView = AddGoalViewController.PickerSelectView
    
    let totalDaysPickerViewValue = PublishSubject<(row: Int, component: Int)>()
    
    init() {
      bind()
    }
    
    let disposeBag = DisposeBag()
    
    private func bind() {
        totalDaysPickerViewValue
            .map { Array(0...max($0.row*10-1, 10)) }
            .bind(to: maxFailDatasource)
            .disposed(by: disposeBag)
    }
    
    //MARK: - Track Type Picker Datasource
    let goalTrackTypePickerDatasource = Observable<[String]>.just(["Period Tracking", "Yearly Continuius Tracking"])
    
    func trackTypePickerFactory(_ row: Int, _ title: String, _ view: UIView?) -> UIView {
        var pickerLabelView = (view as? PickerLabelView)
        
        if pickerLabelView == nil {
            pickerLabelView = PickerLabelView()
        }
        pickerLabelView!.label.text = "\(title)"
        
        return pickerLabelView!
    }
    
    //MARK: - Days Picker Datasource
    let totalDaysDatasource =  Observable<[Int]>.just(Array(0...100).map { 10*$0 })
       
    let maxFailDatasource = BehaviorRelay<[Int]>.init(value: Array(0...10))

    func daysSelectPickerFactory(_ row: Int, _ num: Int, _ view: UIView?) -> UIView {
        var pickerLabelView = (view as? PickerLabelView)
        
        if pickerLabelView == nil {
            pickerLabelView = PickerLabelView()
        }
        pickerLabelView!.label.text = "\(num) days"
        pickerLabelView!.tag = num
        return pickerLabelView!
    }
}
