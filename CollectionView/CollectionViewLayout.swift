//
//  CollectionViewLayout.swift
//  CollectionView
//
//  Created by Mac on 2021/8/23.
//

import UIKit

protocol CollectionViewLayoutDelegate: NSObject {
    func itemHeight(layout: CollectionViewLayout, indexPath: IndexPath, itemWith: CGFloat) -> CGFloat
    func itemColumnCount(layout: CollectionViewLayout) -> Int
    func itemColumnSpcing(layout: CollectionViewLayout) -> CGFloat
    func itemRowSpcing(layout: CollectionViewLayout) -> CGFloat
    func itemEdgeInsetd(layout: CollectionViewLayout) -> UIEdgeInsets
    
    // todo .. 当然也可以自定义更多的代理，看你自己的需求需要哈
}

class CollectionViewLayout: UICollectionViewLayout {
    
    weak var delegate: CollectionViewLayoutDelegate?
    
    var itemColumnCount: Int {
        delegate?.itemColumnCount(layout: self) ?? 2
    }
    
    var itemColumnSpcing: CGFloat {
        delegate?.itemColumnSpcing(layout: self) ?? 0
    }
    
    var itemRowSpcing: CGFloat {
        delegate?.itemRowSpcing(layout: self) ?? 0
    }
    
    var itemHeight: CGFloat = 0
    var itemWidth: CGFloat = 0
    lazy var colsHeight: [CGFloat] = Array(repeating: 0.0, count: itemColumnCount)
    
    var edgeInset: UIEdgeInsets = .zero
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    var contentHeight: CGFloat = 0.0
    
    override func prepare() {
        super.prepare()
        
        contentHeight = 0
        itemWidth  = ((self.collectionView?.frame.width ?? 0) - CGFloat(itemColumnCount + 1) * itemColumnSpcing) / CGFloat(itemColumnCount)
        
        colsHeight = Array(repeating: 0.0, count: itemColumnCount)
        
        var array = [UICollectionViewLayoutAttributes]()
        let items = collectionView?.numberOfItems(inSection: 0) ?? 0
        for index in 0..<items {
            if  let attr = layoutAttributesForItem(at: IndexPath(item: index, section: 0)){
                array.append(attr)
            }
        }
        layoutAttributes = array
    }
    
    override var collectionViewContentSize: CGSize {
//        var longest = colsHeight.first ?? 0
//        for temp in colsHeight {
//            if longest < temp {
//                longest = temp
//            }
//        }
//        return CGSize(width: collectionView?.frame.size.width ?? 0, height: longest)
        CGSize(width: 0, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        layoutAttributes
    }
    
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print(indexPath.item)
        let arrt = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        
        var shorHeight = colsHeight.first ?? 0
        var shortCol = 0
        
        for (index, temp) in colsHeight.enumerated() {
            if shorHeight > temp {
                shorHeight = temp
                shortCol = index
            }
        }
        
        let x = CGFloat(shortCol + 1) * itemColumnSpcing + CGFloat(shortCol) * itemWidth
        let y = shorHeight + itemColumnSpcing
        
        let height = delegate?.itemHeight(layout: self, indexPath: indexPath, itemWith: itemWidth) ?? 0
        
        arrt.frame = .init(x: x, y: y, width: itemWidth, height: height)
        
//        colsHeight[shortCol] = height + itemColumnSpcing
        
        colsHeight[shortCol] = arrt.frame.maxY
        
        let maxColHeight = colsHeight[shortCol]
        if contentHeight < maxColHeight {
            contentHeight = maxColHeight
        }
        
        return arrt
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        true
    }
    
}
