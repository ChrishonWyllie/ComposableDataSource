//
//  DataSourceProvider.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import Foundation

/// Maintains data source items to represent each cell and supplementary view in a UICollectionView
public class DataSourceProvider<T, S, U>: CollectionDataProvider {
    
    // MARK: - Internal Properties
    private var cellItems: [[T]] = []
    private var supplementarySectionItems: [S] = []
    
    // MARK: - Initializers
    public required init(cellItems: [[T]], supplementarySectionItems: [S]) {
        self.cellItems = cellItems
        self.supplementarySectionItems = supplementarySectionItems
    }
    
    public var isEmpty: Bool {
        if cellItems.count > 1 {
            for section in cellItems {
                if section.count > 0 {
                    return false
                }
            }
            return true
        } else if cellItems.count == 1 {
            return cellItems[0].count == 0
        } else {
            return cellItems.count == 0
        }
    }
    
    public func allCellItems() -> [[T]] {
        return self.cellItems
    }
    
    public func allSupplementarySectionItems() -> [S] {
        return supplementarySectionItems
    }
    
    public func numberOfSections() -> Int {
        return cellItems.count
    }
    
    public func numberOfItems(in section: Int) -> Int {
        guard section >= 0 && section < cellItems.count else {
            fatalError("Specified section: \(section) is out of bounds. Number of sections: \(cellItems.count)")
        }
        return cellItems[section].count
    }
    
    // MARK: - Create
    
    public func append(cellItems: [T], inNestedSection section: Int) {
        self.cellItems[section].append(contentsOf: cellItems)
    }
    
    @discardableResult public func appendNewSection(with cellItems: [T]) -> Int {
        self.cellItems.append(cellItems)
        return self.cellItems.count - 1
    }
    
    public func append(supplementarySectionItem: S) {
        self.supplementarySectionItems.append(supplementarySectionItem)
    }
    
    @discardableResult public func insert(cellItems: [T], atIndexPaths indexPaths: [IndexPath]) -> [Int] {
        guard indexPaths.count == cellItems.count else {
            fatalError("The number of items must match the number of index paths. indexPaths count: \(indexPaths.count). values: \(cellItems.count)")
        }
        
        var indicesOfNewSectionsToInsert: [Int] = []
        
        for i in 0..<indexPaths.count {
            let indexPath = indexPaths[i]
            
            if indexPath.section > (self.cellItems.count - 1) {
                // Attempting to insert at out-of-bounds
                // index section. Create a new section
                DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - IndexPath section: \(indexPath.section)")
                DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - items count: \(self.cellItems)")
                let newSectionItems = [cellItems[i]]
                appendNewSection(with: newSectionItems)
                indicesOfNewSectionsToInsert.append(self.cellItems.count - 1)
            } else {
                
                let valueToInsert = cellItems[i]
                let section = indexPath.section
                let itemIndex = indexPath.item
                DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - items count: \(self.cellItems.count)")
                DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - items in section count: \(self.cellItems[section].count)")
                
                insert(cellItems: [valueToInsert], inNestedSection: section, atIndex: itemIndex)
            }
        }
        
        return indicesOfNewSectionsToInsert
    }
    
    public func insert(cellItems: [T], inNestedSection section: Int, atIndex index: Int? = nil) {
        self.cellItems[section].insert(contentsOf: cellItems, at: index ?? 0)
    }
    
    public func insertNewSection(with cellItems: [T], atSection section: Int) {
        self.cellItems.insert(cellItems, at: section)
    }
    
    public func insert(supplementarySectionItem: S, atSection section: Int) {
        self.supplementarySectionItems.insert(supplementarySectionItem, at: section)
    }
    
    public func insert(supplementarySectionItems: [S], atSections sections: [Int]) {
        self.supplementarySectionItems.insert(elements: supplementarySectionItems, atIndices: sections)
    }
    
    
    
    // MARK: - Read
    
    public func item(atIndexPath indexPath: IndexPath) -> T? {
        // Prevent index overflow
        guard indexPath.section >= 0 &&
            indexPath.section < cellItems.count &&
            indexPath.row >= 0 &&
            indexPath.row < cellItems[indexPath.section].count else
        {
            return nil
        }
        return cellItems[indexPath.section][indexPath.row]
    }
    
    public func items(atIndexPaths indexPaths: [IndexPath]) -> [T]? {
        var itemsToReturn: [T]?
        
        guard cellItems.isEmpty == false else {
            return nil
        }
        
        for indexPath in indexPaths {
            if let item = item(atIndexPath: indexPath) {
                if itemsToReturn == nil {
                    itemsToReturn = []
                }
                itemsToReturn?.append(item)
            }
        }
        
        return itemsToReturn
    }
    
    public func supplementarySectionItem(atSection section: Int) -> S? {
        guard
            section >= 0 &&
            section < supplementarySectionItems.count,
            supplementarySectionItems.count > 0 else {
                return nil
        }
        
        return supplementarySectionItems[section]
    }
    
    
    
    // MARK: - Update
    
    public func updateCellItem(atIndexPath indexPath: IndexPath, withNewCellItem newCellItem: T) {
        guard self.item(atIndexPath: indexPath) != nil else {
            fatalError("Attempting to update non existent item at index path: \(indexPath)")
        }
        self.cellItems[indexPath.section][indexPath.item] = newCellItem
    }
        
    public func updateCellItems(atIndexPaths indexPaths: [IndexPath], newCellItems: [T]) {
        guard indexPaths.count == newCellItems.count else {
            fatalError("The number of items must match the number of index paths. indexPaths count: \(indexPaths.count). values: \(newCellItems.count)")
        }
        
        for i in 0..<indexPaths.count {
            let indexPath = indexPaths[i]
            let newCellItem = newCellItems[i]
            updateCellItem(atIndexPath: indexPath, withNewCellItem: newCellItem)
        }
    }
    
    public func updateSections(_ sections: [Int], withNewCellItems newCellItems: [[T]]) {
        
        guard sections.count > 0 else {
            return
        }
        
        guard cellItems.count == sections.count else {
            fatalError("Attempting to update \(cellItems.count) items with mismatching number of sections: \(sections.count)")
        }
        
        zip(sections, cellItems).forEach { (designatedSectionIndex, newSectionItemsToUpdate) in
            if self.cellItems.count == designatedSectionIndex {
                self.appendNewSection(with: newSectionItemsToUpdate)
            } else {
                self.cellItems[designatedSectionIndex] = newSectionItemsToUpdate
            }
        }
    }
    
    
    public func updateSupplementarySectionItems(atSections sections: [Int], withNewSupplementarySectionItems supplementarySectionItems: [S]) {
        
        guard sections.count > 0 else {
            return
        }
        
        guard supplementarySectionItems.count == sections.count else {
            fatalError("Attempting to update \(supplementarySectionItems.count) supplementary items with mismatching number of sections: \(sections.count)")
        }
        
        zip(sections, supplementarySectionItems).forEach { (designatedSectionIndex, supplementarySectionItem) in
            if self.supplementarySectionItems.count == designatedSectionIndex {
                self.append(supplementarySectionItem: supplementarySectionItem)
            } else {
                self.supplementarySectionItems[designatedSectionIndex] = supplementarySectionItem
            }
        }
    }
    
    public func updateSections(atItemSectionIndices sections: [Int],
                               newCellItems: [[T]],
                               supplementarySectionIndices: [Int],
                               newSupplementarySectionItems: [S]) {
        
        guard
            sections.count == newCellItems.count,
            supplementarySectionIndices.count == newSupplementarySectionItems.count
        else {
            fatalError("The number of sections must match the number of items. index count: \(sections.count). values: \(newCellItems.count). supplementary section indices count: \(supplementarySectionIndices.count). items: \(newSupplementarySectionItems.count)")
        }
        
        updateSections(sections, withNewCellItems: newCellItems)
        updateSupplementarySectionItems(atSections: supplementarySectionIndices, withNewSupplementarySectionItems: supplementarySectionItems)
        
    }
    
    
    
    // MARK: - Delete
    
    @discardableResult public func deleteCellItems(atIndexPaths indexPaths: [IndexPath]) -> [Int] {
        
        // TODO
        // Find a way to do this in a cleaner way
        
        // The dictionary allows us to identify which IndexPaths
        // have the same section
        // The key is the section
        // The value represents an array of the items that
        // have the same section
        var dictionary: [Int: [Int]] = [:]
        
        for indexPath in indexPaths {
            if let _ = dictionary[indexPath.section] {
                dictionary[indexPath.section]?.append(indexPath.item)
            } else {
                dictionary[indexPath.section] = [indexPath.item]
            }
        }
        
        let sortedSectionIndices = dictionary.keys.sorted()
        var indicesOfSectionsToDelete: [Int] = []
        for sectionIndex in sortedSectionIndices.reversed() {
            guard let itemsToDeleteInSection = dictionary[sectionIndex] else {
                continue
            }
            if cellItems[sectionIndex].count == itemsToDeleteInSection.count {
                // delete the entire section
                indicesOfSectionsToDelete.append(sectionIndex)
                cellItems.remove(at: sectionIndex)
            } else {
                cellItems[sectionIndex].remove(atIndices: itemsToDeleteInSection)
            }
        }
        
        return indicesOfSectionsToDelete
    }
    
    public func deleteSupplementarySectionItems(atSections sections: [Int]) {
        supplementarySectionItems.remove(atIndices: sections)
    }
    
    
    
    
    
    
    
    
    
    // MARK: - Overwrite
    
    public func replaceDataSource(withCellItems cellItems: [[T]], supplementarySectionItems: [S]) {
        self.reset()
        self.cellItems = cellItems
        self.supplementarySectionItems = supplementarySectionItems
    }
    
    public func reset(keepingStructure: Bool = true) {
        if keepingStructure == true {
            for i in 0..<cellItems.count {
                cellItems[i].removeAll()
            }
            for index in 0..<supplementarySectionItems.count {
                supplementarySectionItems[index] =  GenericSupplementarySectionModel(header: nil,
                                                                                     footer: nil) as! S
            }
        } else {
            cellItems.removeAll()
            supplementarySectionItems.removeAll()
        }
    }
}
