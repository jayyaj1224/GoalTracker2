//
//  PresentationController.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/06/19.
//

import UIKit

class PresentationController: UIPresentationController {
    
    var blurView: UIVisualEffectView!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    var contentHeight: CGFloat = 0
    
    convenience init(contentHeight height: CGFloat, presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        self.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        
        contentHeight = height
        
        let blur = UIBlurEffect(style: .dark)
        blurView = UIVisualEffectView(effect: blur)
        
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.isUserInteractionEnabled = true
        blurView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override private init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        CGRect(
            origin: CGPoint(x: 0, y: self.containerView!.frame.height - contentHeight),
            size: CGSize(width: self.containerView!.frame.width, height: K.screenHeight)
        )
    }
    
    override func presentationTransitionWillBegin() {
        blurView.alpha = 0
        self.containerView?.addSubview(blurView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.blurView.alpha = 0.2
        })
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { _ in
            self.blurView.alpha = 0
        }, completion: { _ in
            self.blurView.removeFromSuperview()
        })
    }
    
    override func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        presentedView!.roundCorners([.topLeft, .topRight], radius: 18)
    }
    
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        presentedView?.frame = frameOfPresentedViewInContainerView
        blurView.frame = containerView!.bounds
    }
    
    @objc func dismissController(){
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}
