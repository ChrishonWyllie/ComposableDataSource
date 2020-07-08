//
//  Extensions.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import UIKit

// MARK: - Array

extension Array {
    
    mutating func insert(elements: [Element], atIndices indices: [Int]) {
        guard elements.count == indices.count else {
            fatalError("Attempting to insert \(elements.count) at mismatching number of indices: \(indices.count)")
        }
        
        var localIndexOfElement: Int = elements.count - 1
        
        var lastIndex: Int? = nil
        for reversedIndex in indices.sorted(by: >) {
            guard lastIndex != reversedIndex else {
                continue
            }
            
            let elementToInsert = elements[localIndexOfElement]
            insert(elementToInsert, at: reversedIndex)
            
            localIndexOfElement -= 1
            lastIndex = reversedIndex
        }
    }
    
    mutating func remove(atIndices indices: [Int]) {
        var lastIndex: Int? = nil
        for index in indices.sorted(by: >) {
            guard lastIndex != index else {
                continue
            }
            remove(at: index)
            lastIndex = index
        }
    }

    
    
    
    
    
    // This does NOT include the current Index
    // [0, 1, 2, 3, 4]
    // index == 2
    // returns [3, 4]
    func subrange(beginningAfter index: Int) -> Array {
        guard index < self.count - 1 else {
            let arrayWithOnlyLastItem = Array(self[(self.count - 1)...(self.count - 1)])
            return arrayWithOnlyLastItem
        }
        let array = Array(self[(index + 1)...(self.count - 1)])
        return array
    }
    
    // This includes the current Index
    // [0, 1, 2, 3, 4]
    // index == 2
    // returns [2, 3, 4]
    func subrange(startingAt index: Int) -> Array {
        guard index < self.count - 1 else {
            let arrayWithOnlyLastItem = Array(self[(self.count - 1)...(self.count - 1)])
            return arrayWithOnlyLastItem
        }
        let array = Array(self[(index)...(self.count - 1)])
        return array
    }
    
    public func flatten() -> [Any] {
//        print("array before flatten: \(self.count)")
        let flattenedArray = self.flatMap{ element -> [Any] in
            if let elementAsArray = element as? [Any] {
                return elementAsArray.flatten()
                
            } else {
                return [element]
            }
        }
//        print("flattened array: \(flattenedArray.count)")
        return flattenedArray
    }

}




extension Array where Element: Comparable {
    func containsSameElements(as other: [Element]) -> Bool {
        return self.count == other.count && self.sorted() == other.sorted()
    }
}

extension Array where Element: Hashable {
    func containsAllElements(in other: [Element]) -> Bool {
        let setOfCurrentItems = Set<Element>(self)
        let setOfOtherItems = Set<Element>(other)
        
        return setOfOtherItems.isSubset(of: setOfCurrentItems)
    }
}













// MARK: - UICollectionViewCell
// This rounds corners for UICollectionViewCells depending on its indexPath
// For example, the top cell has its .topLeft and .topRight corners rounded
// The bottom cell has its .bottomLeft and .bottomRight corners rounded

extension UICollectionViewCell {
    
    func roundCellCorners(with padding: UIEdgeInsets,
                          corners: UIRectCorner,
                          cornerRadius: CGFloat,
                          forItemAt indexPath: IndexPath,
                          in collectionView: UICollectionView) {
        
        let bounds = self.bounds
        // TODO
        // NOTE
        // Not using padding.left / 2 will cause a weird effect.
        let formattedRect = CGRect(x: padding.left / 2,
                                   y: padding.top,
                                   width: bounds.size.width - (padding.left + padding.right),
                                   height: bounds.size.height - (padding.top + padding.bottom))
        
        
        let maskCornerRadii: CGSize = CGSize(width: cornerRadius, height: cornerRadius)
        
        let roundingCorners: UIRectCorner = collectionView.numberOfItems(inSection: indexPath.section) == 1
            ? [.allCorners]
            : corners
        
        // Create a mask for the first cell
        let roundedMask = UIBezierPath(roundedRect: formattedRect,
                                       byRoundingCorners: roundingCorners,
                                       cornerRadii: maskCornerRadii)
        let roundedShapeLayer = CAShapeLayer()
        roundedShapeLayer.frame = formattedRect
        roundedShapeLayer.path = roundedMask.cgPath
        
        
        
        
        // For middle cell
        let maskPathMiddle = UIBezierPath(rect: formattedRect)
        let shapeLayerMiddle  = CAShapeLayer()
        shapeLayerMiddle.frame = formattedRect
        shapeLayerMiddle.path = maskPathMiddle.cgPath
        
        
        
        
        
        
        // Round only the first and last cells if there is only one column (itemSize = deviceScreenWidth)
        switch indexPath.item {
        case 0, (collectionView.numberOfItems(inSection: indexPath.section) - 1):
            self.layer.mask = roundedShapeLayer
        default:
            // middleCell
            self.layer.mask = shapeLayerMiddle
            break
        }
    }
}











// MARK: - UICollectionReusableView

extension UICollectionReusableView {
    
    func roundCorners(with padding: UIEdgeInsets, corners: UIRectCorner, cornerRadius: CGFloat) {
        
        let bounds = self.bounds
        // TODO
        // NOTE
        // Not using padding.left / 2 will cause a weird effect.
        let formattedRect = CGRect(x: padding.left / 2,
                                   y: padding.top,
                                   width: bounds.size.width - (padding.left + padding.right),
                                   height: bounds.size.height - (padding.top + padding.bottom))
        
        
        let maskCornerRadii: CGSize = CGSize(width: cornerRadius, height: cornerRadius)
        
        // Create a mask for the first cell
        let roundedMask = UIBezierPath(roundedRect: formattedRect,
                                       byRoundingCorners: corners,
                                       cornerRadii: maskCornerRadii)
        let roundedShapeLayer = CAShapeLayer()
        roundedShapeLayer.frame = formattedRect
        roundedShapeLayer.path = roundedMask.cgPath
        
        
        self.layer.mask = roundedShapeLayer
    }
    
}
