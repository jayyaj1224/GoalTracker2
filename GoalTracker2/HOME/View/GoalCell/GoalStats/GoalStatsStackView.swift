//
//  GoalStatsStackView.swift
//  GoalTracker2
//
//  Created by Jay Lee on 05/12/2022.
//

import UIKit

/*
 ExecutionRate ▲     DaysLeft        SuccessCount
 MaxStreak           DateRange       FailCount
 */

class GoalStatsStackView: UIView {
    class StatsView: UIView {
        private let titleLabel: UILabel = {
            let label = UILabel()
            label.font = .outFit(size: 14, family: .Semibold)
            label.textColor = .grayC
            return label
        }()
        
        private let statsLabel: UILabel = {
            let label = UILabel()
            label.font = .outFit(size: 14, family: .Regular)
            label.textColor = .grayC
            return label
        }()

        convenience init(title: String) {
            self.init(frame: .zero)
            titleLabel.text = title
            
            layout()
        }
        
        func setStat(text: String) {
            statsLabel.text = text
        }
        
        private func layout() {
            [titleLabel, statsLabel].forEach(addSubview)
            
            titleLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.top.equalToSuperview()
            }
            
            statsLabel.snp.makeConstraints { make in
                make.leading.equalToSuperview()
                make.top.equalTo(titleLabel.snp.bottom).offset(-2)
                make.bottom.equalToSuperview()
            }
        }
    }
    
    private let executionRate = StatsView(title: "Execution rate")
    
    private let maxStreak = StatsView(title: "Max Streak")

    private let daysLeft = StatsView(title: "Days left")

    private let dateRange = StatsView(title: "Date range")

    private let successCount = StatsView(title: "Success count")

    private let failCount = StatsView(title: "Fail count/cap")

    init() {
        super.init(frame: .zero)
        
        layout()
    }
    
    func setStat(with viewModel: GoalViewModel) {
        executionRate.setStat(text: viewModel.executionRateStat)
        maxStreak.setStat(text: viewModel.maxStreak)
        daysLeft.setStat(text: viewModel.daysLeft)
        dateRange.setStat(text: viewModel.dateRange)
        successCount.setStat(text: viewModel.successCount)
        failCount.setStat(text: viewModel.failCount)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GoalStatsStackView {
    private func layout() {
        /*
         ExecutionRate      SuccessCount        DaysLeft
         MaxStreak          FailCount           DateRange
         */
        let statsView = [executionRate, maxStreak, successCount, failCount, daysLeft, dateRange]
        
        statsView.enumerated().forEach { (i, view) in
            addSubview(view)
            
            switch i%2 {
            case 0:
                let leadingInset = i/2*140
                view.snp.makeConstraints { make in
                    make.top.equalToSuperview()
                    make.leading.equalToSuperview().inset(leadingInset)
                }
                
            case 1:
                let leadingInset = i/2*140
                view.snp.makeConstraints { make in
                    make.bottom.equalToSuperview()
                    make.leading.equalToSuperview().inset(leadingInset)
                }
                
            default:
                break
            }
        }
        
        self.snp.makeConstraints { make in
            make.width.equalTo(500)
            make.height.equalTo(80)
        }
    }
}
