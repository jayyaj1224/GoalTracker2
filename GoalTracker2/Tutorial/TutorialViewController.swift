//
//  TutorialViewController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 11/12/2022.
//

import UIKit

class TutorialViewController: UIViewController {
    //MARK: - UI Components
    
    
    //MARK: - Logic
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
}


extension TutorialViewController {
    //MARK: - View Setting
    private func configure() {
        view.backgroundColor = .black
    }
}

