//
//  DialDatePicker.swift
//  GoalTracker2
//
//  Created by Jay Lee on 25/09/2022.
//

import UIKit
import RxSwift
import RxCocoa


class DialDatePickerView: UIView {
    private let upperArchImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dialpicker.arch.neumorphic.upperarch")
        return imageView
    }()
    
    private let underArchImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "dialpicker.arch.neumorphic.underarch")
        return imageView
    }()
    
    private let totalDaysPickerCollectionView: UICollectionView = {
        let layout =  DialDatePickerLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(DialDatePickerCell.self, forCellWithReuseIdentifier: "DialDatePickerCell")
        return collectionView
    }()
    
    private let failAllowancePickerCollectionView: UICollectionView = {
        let layout =  DialDatePickerLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(DialDatePickerCell.self, forCellWithReuseIdentifier: "DialDatePickerCell")
        return collectionView
    }()
    
    init() {
        super.init(frame: .zero)
        
        layoutComponents()
        
        bindCollectionView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindCollectionView() {
        
    }
    
    private func layoutComponents() {
        [upperArchImageView, underArchImageView, totalDaysPickerCollectionView, failAllowancePickerCollectionView]
            .forEach { addSubview($0) }
        
        self.snp.makeConstraints { make in
            make.size.equalTo(300*K.ratioFactor)
        }
        
        upperArchImageView.snp.makeConstraints { make in
            make.width.equalTo(260*K.ratioFactor)
            make.height.equalTo(122*K.ratioFactor)
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        underArchImageView.snp.makeConstraints { make in
            make.width.equalTo(260*K.ratioFactor)
            make.height.equalTo(122*K.ratioFactor)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        totalDaysPickerCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(upperArchImageView)
        }
        
        failAllowancePickerCollectionView.snp.makeConstraints { make in
            make.edges.equalTo(underArchImageView)
        }
    }
}


class DialDatePickerLayout: UICollectionViewLayout {
    var attributeList = [LayoutCircularAttributes]()
    
    var angleAtExtreme: CGFloat {
        let itemsCount = collectionView!.numberOfItems(inSection: 0)
        if itemsCount > 0 {
            return -CGFloat(collectionView!.numberOfItems(inSection: 0) - 1) * anglePerItem
        } else {
            return 0
        }
    }
    
    var angle: CGFloat {
        let height = (collectionViewContentSize.height - collectionView!.bounds.height)
        guard height != 0 else { return 0 }
        return angleAtExtreme * collectionView!.contentOffset.y / height
    }
    
    var radius: CGFloat = -820 {
        didSet {
            invalidateLayout()
        }
    }
    
    var anglePerItem: CGFloat {
        return -atan(size.height / radius)
    }
    
    private let size = CGSize(width: K.screenWidth-8, height: K.singleRowHeight)
    
    override var collectionViewContentSize: CGSize {
        return CGSize(
            width: collectionView!.bounds.width,
            height:CGFloat(collectionView!.numberOfItems(inSection: 0)) * size.height
        )
    }
    
    override class var layoutAttributesClass: AnyClass {
        return LayoutCircularAttributes.self
    }
    
    override func prepare() {
        super.prepare()
        guard let cv = collectionView else { return }
        
        let circleIndex = cv.contentOffset.y/K.singleRowHeight
        let visibleCirclesIndex = max(0, circleIndex-2.0)...circleIndex+1.0
        
        let centerY = cv.contentOffset.y + (cv.bounds.height / 2.0)
        
        let anchorPointX = ((size.width / 2.0) + radius) / size.width
        let hiddenAnchPointX = ((size.width / 2.0) + 1000000) / size.width
        
        let itemsCount = collectionView!.numberOfItems(inSection: 0)
        
        attributeList = (0..<itemsCount)
            .map { i -> LayoutCircularAttributes in
                let attributes = LayoutCircularAttributes(forCellWith: IndexPath(row: i, section: 0))
                attributes.size = self.size
                attributes.center = CGPoint(x: cv.bounds.midX+4, y: centerY)
                
                var attAngle: CGFloat = 0
                var attAnchorPoint: CGPoint = .zero
                
                if visibleCirclesIndex.contains(CGFloat(i)) {
                    attAngle = self.angle + (self.anglePerItem * CGFloat(i))
                    attAnchorPoint = CGPoint(x: anchorPointX, y: 0.5)
                } else {
                    attAngle = self.angle + ((-atan(size.height / 1000000)) * CGFloat(i))
                    attAnchorPoint = CGPoint(x: hiddenAnchPointX, y: 0.5)
                    attributes.isHidden = true
                }
                
                attributes.angle = attAngle
                attributes.anchorPoint = attAnchorPoint
                
                return attributes
            }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attributeList
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}

class DialDatePickerAttributes: UICollectionViewLayoutAttributes {
    var anchorPoint = CGPoint(x: 0.5, y: 0.5)
    
    var angle: CGFloat = 0 {
        didSet {
            zIndex = Int(angle * 1000000)
            transform = CGAffineTransform(rotationAngle: angle)
        }
    }
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let attributes = super.copy(with: zone) as! LayoutCircularAttributes
        let copiedAttributes: LayoutCircularAttributes = attributes
        
        copiedAttributes.anchorPoint = self.anchorPoint
        copiedAttributes.angle = self.angle
        return copiedAttributes
    }
}
