//
//  CollectionViewCircularLayout.swift
//  GoalTracker
//
//  Created by Jay Lee on 2022/06/12.
//

import UIKit

class CircularLayout: UICollectionViewLayout {
    var attributeList = [UICollectionViewLayoutAttributes]()
    
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
        guard let circularCv = collectionView as? CircularCollectionView else { return }
        
        let currentPage = circularCv.currentPage
        
        let rangeForPrepare = max(0, currentPage-2)...(currentPage + 3)

        attributeList = (0..<circularCv.numberOfItems(inSection: 0))
            .map { i -> UICollectionViewLayoutAttributes in
                switch i {
                case rangeForPrepare:
                    let centerY = circularCv.contentOffset.y + (circularCv.bounds.height / 2.0)
                    let anchorPointX = ((size.width / 2.0) + radius) / size.width
                    
                    let circularAttributes = LayoutCircularAttributes(forCellWith: IndexPath(row: i, section: 0))
                    circularAttributes.size = self.size
                    circularAttributes.center = CGPoint(x: circularCv.bounds.midX+4, y: centerY)
                    circularAttributes.angle = self.angle + (self.anglePerItem * CGFloat(i))
                    circularAttributes.anchorPoint = CGPoint(x: anchorPointX, y: 0.5)
                    return circularAttributes
                    
                default:
                    let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(row: i, section: 0))
                    attributes.size = self.size
                    attributes.center = CGPoint(x: circularCv.bounds.minX, y: CGFloat(i)*K.singleRowHeight)
                    return attributes
                }
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
