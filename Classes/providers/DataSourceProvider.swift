//
//  DataSourceProvider.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import Foundation

public class DataSourceProvider<T, S, U>: CollectionDataProvider {
    
    // MARK: - Internal Properties
    private var items: [[T]] = []
    private var supplementaryContainerItems: [S] = []
    
    // MARK: - Initializers
    init(array: [[T]], supplementaryItems: [S]) {
        items = array
        supplementaryContainerItems = supplementaryItems
    }
    
    public var isEmpty: Bool {
        if items.count > 0 {
            var dataSourceIsEmpty: Bool = true
            for section in items {
                dataSourceIsEmpty = section.count == 0
            }
            return dataSourceIsEmpty
        } else {
            return items.count == 0
        }
    }
    
    public func allItems() -> [[T]] {
        return self.items
    }
    
    public func allSupplementaryItems() -> [S] {
        return supplementaryContainerItems
    }
    
    public func numberOfSections() -> Int {
        return items.count
    }
    
    public func numberOfItems(in section: Int) -> Int {
        guard section >= 0 && section < items.count else {
            fatalError("Specified section: \(section) is out of bounds. Number of sections: \(items.count)")
        }
        return items[section].count
    }
    
    // MARK: - Create
    
    public func append(items: [T], inNestedSection section: Int, atIndex index: Int? = nil) {
        self.items[section].append(contentsOf: items)
    }
    
    public func append(contentsOf collection: [T]) {
        self.items.append(collection)
    }
    
    public func append(supplementaryItem: S) {
        self.supplementaryContainerItems.append(supplementaryItem)
    }
    
    // TODO
    // What if the indexPaths were not contiguous?
    // e.g. indexPath items: [1, 6, 13]
    // Would this not be inserted in the correct order
    // since the array would be shifted with each insertion
    // Follow the same format as insertingSupplementaryItems?
    // Probably not, think about the case of inserting older messages
    @discardableResult public func insertItems(at indexPaths: [IndexPath], values: [T]) -> [Int] {
        guard indexPaths.count == values.count else {
            fatalError("The number of items must match the number of index paths. indexPaths count: \(indexPaths.count). values: \(values.count)")
        }
        
        var indicesOfNewSectionsToInsert: [Int] = []
        
        for i in 0..<indexPaths.count {
            let indexPath = indexPaths[i]
            
            if indexPath.section > (items.count - 1) {
                // Attempting to insert at out-of-bounds
                // index section. Create a new section
                print("IndexPath section: \(indexPath.section)")
                print("items count: \(items)")
                let newSection = [values[i]]
                append(contentsOf: newSection)
                indicesOfNewSectionsToInsert.append(items.count - 1)
            } else {
//                print("items: \(items)")
//                print("inserting at section: \(indexPath.section), item: \(indexPath.item)")
//                print("valus: \(values.count)")
//                print("index: \(i)")
                let valueToInsert = values[i]
                let section = indexPath.section
                let item = indexPath.item
                print("items count: \(items.count)")
                print("items in section count: \(items[section].count)")
                
                insert(items: [valueToInsert], inNestedSection: section, atIndex: item)
            }
        }
        
        return indicesOfNewSectionsToInsert
    }
    
    public func insert(items: [T], inNestedSection section: Int, atIndex index: Int? = nil) {
        self.items[section].insert(contentsOf: items, at: index ?? 0)
    }
    
    public func insert(contentsOf collection: [T], atIndex index: Int) {
        self.items.insert(collection, at: index)
    }
    
    public func insert(supplementaryItem: S, atIndex index: Int) {
        self.supplementaryContainerItems.insert(supplementaryItem, at: index)
    }
    
    public func insertSupplementaryContainerItems(at sections: [Int], supplementaryContainerItems: [S]) {
        self.supplementaryContainerItems.insert(elements: supplementaryContainerItems, atIndices: sections)
    }
    
    
    
    // MARK: - Read
    
    public func item(at indexPath: IndexPath) -> T? {
        // Prevent index overflow
        guard indexPath.section >= 0 &&
            indexPath.section < items.count &&
            indexPath.row >= 0 &&
            indexPath.row < items[indexPath.section].count else
        {
            return nil
        }
        return items[indexPath.section][indexPath.row]
    }
    
    public func items(at indexPaths: [IndexPath]) -> [T]? {
        var itemsToReturn: [T]?
        
        guard items.isEmpty == false else {
            return nil
        }
        
        for indexPath in indexPaths {
            if let item = item(at: indexPath) {
                if itemsToReturn == nil {
                    itemsToReturn = []
                }
                itemsToReturn?.append(item)
            }
        }
        
        return itemsToReturn
    }
    
    public func supplementaryContainerItem(at designatedSection: Int) -> S? {
        guard
            designatedSection >= 0 &&
            designatedSection < supplementaryContainerItems.count,
            supplementaryContainerItems.count > 0 else {
                return nil
        }
        
        return supplementaryContainerItems[designatedSection]
    }
    
    
    
    // MARK: - Update
    
    public func updateItem(at indexPath: IndexPath, withNewItem item: T) {
        guard self.item(at: indexPath) != nil else {
            fatalError("Attempting to update non existent item at index path: \(indexPath)")
        }
        self.items[indexPath.section][indexPath.item] = item
    }
    
    public func updateItems(atSections sections: [Int], withNewItems items: [[T]]) {
        
        guard sections.count > 0 else {
            return
        }
        
        guard items.count == sections.count else {
            fatalError("Attempting to update \(items.count) items with mismatching number of sections: \(sections.count)")
        }
        
        zip(sections, items).forEach { (designatedSectionIndex, itemsToUpdate) in
            if self.items.count == designatedSectionIndex {
                self.append(contentsOf: itemsToUpdate)
            } else {
                self.items[designatedSectionIndex] = itemsToUpdate
            }
        }
    }
    
    public func updateItems(at indexPaths: [IndexPath], values: [T]) {
        guard indexPaths.count == values.count else {
            fatalError("The number of items must match the number of index paths. indexPaths count: \(indexPaths.count). values: \(values.count)")
        }
        
        for i in 0..<indexPaths.count {
            let indexPath = indexPaths[i]
            let value = values[i]
            updateItem(at: indexPath, withNewItem: value)
        }
    }
    
    public func updateSupplementaryItems(atSections sections: [Int], withNewSupplementaryItems supplementaryItems: [S]) {
        
        guard sections.count > 0 else {
            return
        }
        
        guard supplementaryItems.count == sections.count else {
            fatalError("Attempting to update \(supplementaryItems.count) supplementary items with mismatching number of sections: \(sections.count)")
        }
        
        zip(sections, supplementaryItems).forEach { (designatedSectionIndex, supplementaryItem) in
            if self.supplementaryContainerItems.count == designatedSectionIndex {
                self.append(supplementaryItem: supplementaryItem)
            } else {
                self.supplementaryContainerItems[designatedSectionIndex] = supplementaryItem
            }
        }
    }
    
    public func updateSections(atItemSectionIndices itemSections: [Int],
                               items: [[T]],
                               supplementaryItems: [S],
                               supplementarySectionIndices: [Int]) {
        
        guard
            itemSections.count == items.count,
            supplementarySectionIndices.count == supplementaryItems.count
        else {
            fatalError("The number of sections must match the number of items. index count: \(itemSections.count). values: \(items.count). supplementary section indices count: \(supplementarySectionIndices.count). items: \(supplementaryItems.count)")
        }
        
        updateItems(atSections: itemSections, withNewItems: items)
        updateSupplementaryItems(atSections: supplementarySectionIndices, withNewSupplementaryItems: supplementaryItems)
        
    }
    
    
    
    // MARK: - Delete
    
    @discardableResult public func deleteItems(at indexPaths: [IndexPath]) -> [Int] {
        
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
            if items[sectionIndex].count == itemsToDeleteInSection.count {
                // delete the entire section
                indicesOfSectionsToDelete.append(sectionIndex)
                items.remove(at: sectionIndex)
            } else {
                items[sectionIndex].remove(atIndices: itemsToDeleteInSection)
            }
        }
        
        return indicesOfSectionsToDelete
    }
    
    public func deleteSupplementaryContainerItems(at designatedSections: [Int]) {
        supplementaryContainerItems.remove(atIndices: designatedSections)
    }
    
    
    
    
    
    
    
    
    
    public func reset(keepingStructure: Bool = true) {
        if keepingStructure == true {
            for i in 0..<items.count {
                items[i].removeAll()
            }
            for index in 0..<supplementaryContainerItems.count {
                supplementaryContainerItems[index] =  GenericSupplementaryHeaderFooterModel(header: nil,
                                                                                           footer: nil) as! S
            }
        } else {
            items.removeAll()
            supplementaryContainerItems.removeAll()
        }
    }
    
    public func replaceAllItems(with models: [[T]], supplementaryContainerItems: [S]) {
        self.reset()
        self.items = models
        self.supplementaryContainerItems = supplementaryContainerItems
    }
}
