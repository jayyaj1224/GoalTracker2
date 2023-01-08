//
//  ScrollImageViewController.swift
//  GoalTracker2
//
//  Created by Jay Lee on 11/12/2022.
//

import UIKit
import RxSwift

class TutorialScrollViewController: UIViewController {
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
    
    private let pageControl = NeumorphicPageControl(pageSize: K.screenWidth, axis: .horizontal)
    
    //MARK: - Logic
    private let disposeBag = DisposeBag()
    
    convenience init(tutorialType: String, numberOfImages: Int) {
        self.init(nibName: nil, bundle: nil)
        
        var imageSize = ""
        if DeviceInfo.current.hasNotch {
            imageSize = DeviceInfo.current.isMaxSize ? "ipxm" : "ipx"
        } else {
            imageSize = "ip8"
        }
        
        self.contentImageViews = Array(1...numberOfImages)
            .map { "\(tutorialType)-\($0)-\(imageSize)"}
            .map(UIImageView.init)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
        
        bindViewComponents()
    }
    
    private func bindViewComponents() {
        let scrollContentOffsetShare = tutorialScrollView.rx.contentOffset.share()
        
        scrollContentOffsetShare
            .map { $0.x }
            .bind(to: pageControl.rx.currentOffset)
            .disposed(by: disposeBag)
        
        scrollContentOffsetShare
            .subscribe(onNext: { offset in
                let x = offset.x/K.screenWidth
                switch x {
                case 4..<4.9:
                    let speed = 1.5
                    self.view.alpha = 1-(x-4)*speed
                case 4.9...:
                    Timer.scheduledTimer(withTimeInterval: 0.4, repeats: false) { _ in
                        self.dismiss(animated: false)
                    }
                default:
                    break
                }
            })
            .disposed(by: disposeBag)
    }
}

extension TutorialScrollViewController {
    //MARK: - View Setting
    private func configure() {
        view.backgroundColor = .white
        
        pageControl.numberOfPages = contentImageViews.count+1
        
        layout()
    }
    
    private func layout() {
        [tutorialScrollView, pageControl]
            .forEach(view.addSubview)
        
        tutorialScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(30)
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
        
        let closeView = UIView()
        contentStackView.addArrangedSubview(closeView)
        closeView.snp.makeConstraints { make in
            make.width.equalTo(K.screenWidth)
        }
    }
}

