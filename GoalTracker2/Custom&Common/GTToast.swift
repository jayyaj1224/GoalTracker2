//
//  GTToast.swift
//  GoalTracker2
//
//  Created by Jay Lee on 02/12/2022.
//

import UIKit

class GTToast: NeumorphicView {
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
    
    var time: CGFloat = 2.0
    
    static var toastShowing: [GTToast] = []

    static func make(titleText: String, subTitleText: String, imageName: String, position: Position, time: CGFloat) -> GTToast {
        let toast = GTToast()
        toast.setTitle(titleText)
        toast.setSubTitle(subTitleText)
        toast.setImage(name: imageName)
        toast.position = position
        toast.time = time
        
        GTToast.toastShowing.insert(toast, at: 0)
        
        return toast
    }
    
    static func hideAllToast() {
        GTToast.toastShowing.forEach { $0.removeFromSuperview() }
        GTToast.toastShowing.removeAll()
    }
        
    private init() {
        super.init(backgroundColor: .crayon, type: .medium)
        
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
extension GTToast {
    func show() {
        layoutToast()
        
        DispatchQueue.main.async {
            self.presentAnimation()
        }
    }
    
    private func layoutToast() {
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
        UIView.animate(withDuration: 0.3, delay: time, usingSpringWithDamping: 1, initialSpringVelocity: 1) {
            switch self.position {
            case .Top, .Bottom:
                self.transform = .identity
            case .MiddleTop:
                break
            }
            self.alpha = 0

        } completion: { _ in
            self.removeFromSuperview()
            
            if GTToast.toastShowing.isEmpty == false {
                GTToast.toastShowing.removeLast()
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
extension GTToast {
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
