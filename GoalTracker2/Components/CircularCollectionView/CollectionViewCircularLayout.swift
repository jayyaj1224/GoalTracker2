//
//  CollectionViewCircularLayout.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/06/12.
//

import UIKit

class CircularLayout: UICollectionViewLayout {
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

class LayoutCircularAttributes: UICollectionViewLayoutAttributes {
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
