//
//  NeumorphicToast.swift
//  GoalTracker2
//
//  Created by Jay Lee on 02/12/2022.
//

import UIKit

var iii = 0

class GoalTrackerToast: NeumorphicView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.attributedText = NSMutableAttributedString(
            string: "Success +1",
            attributes: [
                .kern: -0.75,
                .font: UIFont.sfPro(size: 15, family: .Semibold)
            ]
        )
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.attributedText = NSMutableAttributedString(
            string: "Success +1",
            attributes: [
                .kern: -0.75,
                .font: UIFont.sfPro(size: 15, family: .Semibold)
            ]
        )
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    enum Position { case Bottom, Top, MiddleTop}
    
    var position: Position = .Bottom
    
    static var toastShowing: [GoalTrackerToast] = []

    static public func make(titleText: String, subTitleText: String, imageName: String, position: Position) -> GoalTrackerToast {
        let toast = GoalTrackerToast()
        toast.setTitle(titleText)
        toast.setSubTitle(subTitleText)
        toast.setImage(name: imageName)
        toast.position = position
        
        GoalTrackerToast.toastShowing.insert(toast, at: 0)
        
        return toast
    }
    
    static public func hideAllToast() {
        GoalTrackerToast.toastShowing.forEach { $0.removeFromSuperview() }
        GoalTrackerToast.toastShowing.removeAll()
    }
        
    private init() {
        super.init(backgroundColor: .white, shadowSize: .medium)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.removeFromSuperview()
    }
}

//MARK: View & Animation
extension GoalTrackerToast {
    public func show() {
        layoutSelf()
        
        DispatchQueue.main.async {
            self.presentAnimation()
        }
    }
    
    private func layoutSelf() {
        guard let topView = topController()?.view else { return }
        
        topView.addSubview(self)
        
        self.snp.makeConstraints { $0.centerX.equalToSuperview() }
        
        switch position {
        case .Top:
            self.snp.makeConstraints { $0.bottom.equalTo(topView.snp.top) }
        case .Bottom:
            self.snp.makeConstraints { $0.top.equalTo(topView.snp.bottom) }
        case .MiddleTop:
            self.snp.makeConstraints { $0.centerY.equalToSuperview() }
        }
    
        topView.layoutSubviews()
    }
    
    private func presentAnimation() {
        var translationYAmount: CGFloat = 0
        
        switch position {
        case .Top:
            translationYAmount = 260
        case .Bottom:
            translationYAmount = -220
        case .MiddleTop:
            translationYAmount = -230
        }
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1) {
            self.transform = CGAffineTransform(translationX: 0, y: translationYAmount)
        }
        UIView.animate(withDuration: 0.3, delay: 2, usingSpringWithDamping: 1, initialSpringVelocity: 1) {
            switch self.position {
            case .Top:
                self.transform = .identity
            case .Bottom, .MiddleTop:
                break
            }
            self.alpha = 0

        } completion: { _ in
            self.removeFromSuperview()
            
            if GoalTrackerToast.toastShowing.isEmpty == false {
                GoalTrackerToast.toastShowing.removeLast()
            }
        }
    }
    
    private func topController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter {$0.isKeyWindow}.first
        
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        }
        return nil
    }
}

//MARK: UI Settings
extension GoalTrackerToast {
    private func setTitle(_ title: String) {
        let attributtedString = NSMutableAttributedString(
            string: title,
            attributes: [
                .kern: -0.75,
                .font: UIFont.sfPro(size: 15, family: .Semibold),
                .foregroundColor: UIColor.black
            ]
        )
        titleLabel.attributedText = attributtedString
    }
    
    private func setSubTitle(_ title: String) {
        let attributtedString = NSMutableAttributedString(
            string: title,
            attributes: [
                .kern: -0.75,
                .font: UIFont.sfPro(size: 12, family: .Semibold),
                .foregroundColor: UIColor.grayB
            ]
        )
        titleLabel.attributedText = attributtedString
    }
    
    private func setImage(name: String) {
        if let image = UIImage(named: name) {
            iconImageView.image = image
        }
        if let systemImage = UIImage(systemName: name) {
            iconImageView.image = systemImage
        }
    }
    
    private func layout() {
        self.layer.cornerRadius = 23
        
        self.snp.makeConstraints { make in
            make.width.equalTo(170)
            make.height.equalTo(46)
        }
        
        [titleLabel, subTitleLabel, iconImageView]
            .forEach(addSubview(_:))
        
        titleLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(17)
            make.top.equalToSuperview().inset(6)
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.centerX.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
        }
        
        iconImageView.snp.makeConstraints { make in
            make.size.equalTo(28)
            make.leading.equalToSuperview().inset(23)
            make.centerY.equalToSuperview()
        }
    }
}
