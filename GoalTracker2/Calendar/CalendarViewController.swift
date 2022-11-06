//
//  CalendarViewController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 22/09/2022.
//

import UIKit

class CalendarViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: - ui setting
    private func configure() {
        view.backgroundColor = .crayon
        
        
    }
    
    private func setNavigationBar() {
        navigationController?.isNavigationBarHidden = false
        
        let backImage = UIImage(named: "back.neumorphism")?
            .withAlignmentRectInsets(UIEdgeInsets(top: -5, left: -7, bottom: 0, right: 0))
            .withRenderingMode(.alwaysOriginal)
        
        let navigationBar = navigationController?.navigationBar
        navigationBar?.backIndicatorImage = backImage
        navigationBar?.backIndicatorTransitionMaskImage = backImage
        navigationBar?.backItem?.title = ""
    }
}

