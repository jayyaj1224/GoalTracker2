//
//  TutorialViewController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 11/12/2022.
//

import UIKit
import RxSwift
import RxCocoa

class TutorialViewController: UIViewController {
    //MARK: - View Components
    private let tutorialScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        return stack
    }()
    
    private var contentImageViews: [UIImageView] = []
    
    private let pageControl = NeumorphicPageControl(
        pageSize: K.screenWidth,
        axis: .horizontal,
        backgroundColor: .crayon.withAlphaComponent(0.9)
    )
    
    private let swipeIndicatorLabel: UILabel = {
        let label = UILabel()
        label.text = "􀄫"
        label.font = .sfPro(size: 17, family: .Semibold)
        label.textColor = .lightGray
        return label
    }()
    
    fileprivate let closeButton: UIButton = {
        let button = UIButton()
        let attributedString = NSMutableAttributedString(
            string: "􀆄",
            attributes: [
                NSMutableAttributedString.Key.font: UIFont.sfPro(size: 25, family: .Semibold),
                NSMutableAttributedString.Key.foregroundColor: UIColor.crayon,
//                NSMutableAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
            ]
        )
        button.setAttributedTitle(attributedString, for: .normal)
        return button
    }()
    
//    private let bottomScreenView = UIView()
    
    //MARK: - Logic
    var dismissCompletion: (()->Void)?
    
    var isSwipeDismiss = false
                                            
    let disposeBag = DisposeBag()
    
    fileprivate var numberOfPages = 0
    
    convenience init(tutorialName: String, numberOfPages: Int, swipeDismiss: Bool=false) {
        self.init(nibName: nil, bundle: nil)
        
        var imageSize = ""
        if DeviceInfo.current.hasNotch {
            imageSize = DeviceInfo.current.isMaxSize ? "ipxm" : "ipx"
        } else {
            imageSize = "ip8"
        }
        
        contentImageViews = Array(1...numberOfPages)
            .map { "\(tutorialName)-\($0)-\(imageSize)"}
            .map(UIImageView.init)
        
        self.numberOfPages = numberOfPages
        
        isSwipeDismiss = swipeDismiss
        
        closeButton.isHidden = swipeDismiss
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        bindViewComponents()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        addGradient()
    }
    
    private func bindViewComponents() {
        let scrollContentOffsetShare = tutorialScrollView.rx.contentOffset
            .map { $0.x }
            .share()
        
        scrollContentOffsetShare
            .bind(to: pageControl.rx.currentOffset)
            .disposed(by: disposeBag)
        
        if isSwipeDismiss {
            scrollContentOffsetShare
                .subscribe(self.rx.swipeDismiss)
                .disposed(by: disposeBag)
        }
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: false, completion: dismissCompletion)
    }
    
//    private func addGradient() {
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [
//            UIColor.clear.cgColor,
//            UIColor.black.withAlphaComponent(0.6).cgColor
//        ]
//        gradientLayer.locations = [0.0, 1.0]
//        gradientLayer.frame = bottomScreenView.bounds
//        bottomScreenView.layer.addSublayer(gradientLayer)
//    }
}

extension Reactive where Base: TutorialViewController {
    var showCloseButton: Binder<CGFloat> {
        Binder(base) { base, x in
            let page = Int(x/K.screenWidth)
            base.closeButton.isHidden = (page != base.numberOfPages-1)
        }
    }
    var swipeDismiss: Binder<CGFloat> {
        Binder(base) { base, x in
            let page = x/K.screenWidth
            let end = Double(base.numberOfPages)
            
            switch page {
            case end-1..<end:
                base.view.alpha = end-page
            case end:
                base.dismiss(animated: false, completion: base.dismissCompletion)
            default:
                break
            }
        }
    }
}

extension TutorialViewController {
    //MARK: - View Setting
    private func configure() {
        view.backgroundColor = .white
        
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        pageControl.numberOfPages = numberOfPages
        
        layout()
    }
    
    private func layout() {
//        [tutorialScrollView, bottomScreenView, pageControl]
        [tutorialScrollView, pageControl]
            .forEach(self.view.addSubview)
        
        tutorialScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(40)
        }
        
        tutorialScrollView.addSubview(contentStackView)
        contentStackView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.centerY.height.equalToSuperview()
        }
        
        contentImageViews.forEach { imageView in
            contentStackView.addArrangedSubview(imageView)
            imageView.snp.makeConstraints { make in
                make.width.equalTo(K.screenWidth)
            }
        }
        
//        bottomScreenView.snp.makeConstraints { make in
//            make.leading.trailing.bottom.equalToSuperview()
//            make.height.equalTo(150)
//        }
        
        if isSwipeDismiss {
            let dummyView = UIView()
            contentStackView.addArrangedSubview(dummyView)
            dummyView.snp.makeConstraints { make in
                make.width.equalTo(K.screenWidth)
            }
            
            self.view.addSubview(swipeIndicatorLabel)
            swipeIndicatorLabel.snp.makeConstraints { make in
                make.leading.equalTo(pageControl.snp.trailing).offset(10)
                make.centerY.equalTo(pageControl)
            }
        } else {
            self.view.addSubview(closeButton)
            closeButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview()
                make.top.equalToSuperview().inset(50)
                make.size.equalTo(80)
            }
        }
    }
}

