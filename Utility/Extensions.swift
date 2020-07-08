//
//  Extensions.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import Foundation

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
