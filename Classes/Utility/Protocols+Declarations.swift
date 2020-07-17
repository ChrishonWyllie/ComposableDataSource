//
//  Protocols+Declarations.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import Foundation

public protocol ReusableUIElement {
    static var reuseIdentifier: String { get }
}

public extension ReusableUIElement {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

public protocol ConfigurableReusableCell: ReusableUIElement {
    associatedtype T
    func configure(with item: T, at indexPath: IndexPath)
}

public protocol ConfigurableReusableSupplementaryView: ReusableUIElement {
    associatedtype T
    func configure(with item: T, at indexPath: IndexPath)
}

/// Provides conformance by which UICollectionView data source provider must conform to
public protocol CollectionDataProvider {
    
    associatedtype T // cell item
    associatedtype S // supplementary section item
    associatedtype U // individual header or footer item
    
    
    /**
     Initializes data provider with items to represent cells and supplementary views
     
    - Parameters:
        - cellItems: A double nested array of models to represent and configure each cell at a specific IndexPath
        - supplementarySectionItems: Array of models to represent and configure each supplementary view at a specific IndexPath section
     */
    init(cellItems: [[T]], supplementarySectionItems: [S])
    
    /**
     Determines if the data provider is completely empty
     
    - Usage:
     ```
     let dataSource = ....
     if dataSource.isEmpty {
        // ...
     }
     ```
    */
    var isEmpty: Bool { get }
    
    /**
     Returns double nested array of all items representing cells in each section
     
    - Usage:
     ```
     let dataSource = ....
     let allItems = dataSource.allItems()
     ```
    */
    func allCellItems() -> [[T]]
    
    /**
     Returns all items representing section supplementary views
     
    - Usage:
     ```
     let dataSource = ....
     let allSupplementaryItems = dataSource.allSupplementarySectionItems()
     ```
    */
    func allSupplementarySectionItems() -> [S]
    
    /**
     Returns the number of sections represented by the data provider, and therefore, the number sections in the UICollectionView
     
    - Usage:
     ```
     let dataSource = ....
     let numSections = dataSource.numberOfSections()
     ```
    */
    func numberOfSections() -> Int
    
    /**
     Returns the number of items in a specific section, and therefore, the number of items in a specific UICollectionView section
     
    - Usage:
     ```
     let dataSource = ....
     let sectionIndex: Int = 0
     let numItemsInSection = dataSource.numberOfItems(in: sectionIndex)
     ```
     
    - Parameters:
        - section: The section index within the data source
    */
    func numberOfItems(in section: Int) -> Int
    
    
    // Create
    
    /**
     Appends an array of cell items to the end of a certain section
     
    - Note:
     The section must already exist. If the desired section does not already exist, use the `appendNewSection(with:)` function which will create a completely new section. Otherwise, inserting into non-existent sections will throw an out of bounds error, as expected.
     
    - Usage:
     ```
     let dataSource = ....
     let itemsToAppend = [....]
     let sectionIndex: Int = 2
     dataSource.append(items: itemsToAppend, inNestedSection: sectionIndex)
     ```
     
    - Parameters:
        - cellItems: Array of items representing each cell to append
        - section: The section index by which the cell items will be appended to the end of
     
    */
    func append(cellItems: [T], inNestedSection section: Int)
    
    /**
     Creates a new section with a new array of cell items
     
    - Note:
     Be aware that adding new sections will require calling `collectionView.insertSections()` if using `collectionView.performBatchUpdates(...)`. Use the return value to call `collectionView.insertSections()`
        
    - Usage:
     ```
     let dataSource = ....
     let itemsToAppend = [....]
     let sectionIndex: Int = 2
     dataSource.appendNewSection(with: itemsToAppend)
     ```
     
    - Parameters:
        - cellItems: Array of items representing each cell to append
     
    - Returns:
        - An integer representing the index of the new section that was created. Use this to call `collectionView.insertSections()`
     
    */
    @discardableResult func appendNewSection(with cellItems: [T]) -> Int
    
    /**
     Appends a supplementary section item
     
    - Usage:
     ```
     let dataSource = ....
     let supplementarySectionItem = ....
     dataSource.append(supplementarySectionItem: supplementarySectionItem)
     ```
     
    - Parameters:
        - supplementarySectionItem: section item representing a supplementary header and/or footer in data source
     
    */
    func append(supplementarySectionItem: S)
    
    /**
     Inserts cell items at specified indexPaths. Returns an array of Integers representing new sections that have been created
     
    - Note:
     If a new section needs to be inserted (i.e., the [indexPaths] argument contains sections greater than the current largest section)
     this will return an array of those new section indices that were created as a result of insertions. If using `collectionView.performBatchUpdates(...)` use this array to insert the new sections with `collectionView.insertSections()`
     
    - Usage:
     ```
     let dataSource = ....
     let itemsToInsert = [....]
     let indexPathsOfItems = [....]
     let newSections = dataSource.insert(cellItems: itemsToInsert, at: indexPathsOfItems)
     
     // insert new sections or call collectionView.reloadData()
     ```
     
    - Parameters:
        - cellItems: Array of items representing each cell to insert
        - indexPaths: Array of `IndexPath` representing each cell's final expected indexPath
     
    - Returns:
        - An array of `Int` representing each section that was created as a result of the insertions
    */
    @discardableResult func insert(cellItems: [T], atIndexPaths indexPaths: [IndexPath]) -> [Int]
    
    /**
     Inserts array of cell items into a specified section, at a particular index within that section, if specified
        
    - Usage:
     ```
     let dataSource = ....
     let itemsToInsert = [....]
     let sectionIndex: Int = 2
     let indexWithinSection: Int = 9
     dataSource.insert(cellItems: itemsToInsert, inNestedSection: sectionIndex, atIndex: indexWithinSection)
     ```
     
    - Parameters:
        - cellItems: Array of items representing each cell to insert
        - section: The section index by which the cell items will be inserted into
        - index: The index within the section by which the array will be inserted at. If nil, will insert at index 0 (beginning of the specified section).
     
    */
    func insert(cellItems: [T], inNestedSection section: Int, atIndex index: Int?)
    
    /**
     Inserts a new section with a new array of cell items at a specified section index. Essentially, moves down sections after this index and creates room for new section
     
    - Note:
     Be aware that adding new sections will require calling `collectionView.insertSections()` if using `collectionView.performBatchUpdates(...)`
        
    - Usage:
     ```
     let dataSource = ....
     let itemsToInsert = [....]
     let sectionIndex: Int = 3
     dataSource.insertNewSection(with: itemsToInsert, atSection: sectionIndex)
     ```
     
    - Parameters:
        - cellItems: Array of items representing each cell to append
        - section: The section index that will be created/inserted with the new cell items
     
    */
    func insertNewSection(with cellItems: [T], atSection section: Int)
    
    /**
     Inserts a supplementary section item at a specified section index
     
    - Usage:
     ```
     let dataSource = ....
     let supplementarySectionItem = ....
     let sectionIndex: Int = 3
     dataSource.insert(supplementarySectionItem: supplementarySectionItem, atSection: sectionIndex)
     ```
     
    - Parameters:
        - supplementarySectionItem: section item representing a supplementary header and/or footer in data source
        - section: The section index by which the supplementary item will be inserted into
    */
    func insert(supplementarySectionItem: S, atSection section: Int)
    
    /**
     Inserts supplementary section items at specified section indices
     
    - Usage:
     ```
     let dataSource = ....
     let supplementarySectionItems = [....]
     let sectionIndices: [Int] = [1, 3, 6]
     dataSource.insert(supplementarySectionItems: supplementarySectionItem, atSections: sectionIndices)
     ```
     
    - Parameters:
        - supplementarySectionItems: section items representing supplementary headers and/or footers in data source
        - sections: The section indices at which the supplementary section items will be inserted
    */
    func insert(supplementarySectionItems: [S], atSections sections: [Int])
    
    
    // Read
    
    /**
     Returns a cell item at the specified indexPath
     
    - Note:
     Returns nil if no such item exists at the specified indexPath, i.e. you are checking for an IndexPath that is out of bounds
        
    - Usage:
     ```
     let dataSource = ....
     let indexPath: IndexPath = ....
     let cellItem = dataSource.item(atIndexPath: indexPath)
     
     // Do something with item
     ```
     
    - Parameters:
        - indexPath: The indexPath of the desired item
     
    - Returns:
        - A cell item representing the cell at the desired indexPath
    */
    func item(atIndexPath indexPath: IndexPath) -> T?
    
    /**
     Returns an array of cell items at the specified indexPaths
     
    - Note:
     Returns nil if no such item exists at the specified indexPaths, i.e. you are checking for an IndexPath that is out of bounds
        
    - Usage:
     ```
     let dataSource = ....
     let indexPath: [IndexPath] = [....]
     let cellItems = dataSource.items(atIndexPaths: indexPaths)
     
     // Do something with item
     ```
     
    - Parameters:
        - indexPath: The indexPath of the desired item
     
    - Returns:
        - An array of cell items representing each cell at the desired indexPaths
    */
    func items(atIndexPaths indexPaths: [IndexPath]) -> [T]?
    
    /**
     Returns a supplementary seection item at the specified section index
     
    - Note:
     Returns nil if no such supplementary section item exists at the specified section index, i.e. you are checking for a section index that is out of bounds
        
    - Usage:
     ```
     let dataSource = ....
     let sectionIndex: Int = ....
     let supplementarySectionItem = dataSource.supplementarySectionItem(atSection: sectionIndex)
     
     // Do something with item
     ```
     
    - Parameters:
        - section: The section index of the desired supplementary section item
     
    - Returns:
        - A supplementary section item representing the supplementary header and/or footer view at the desired section index
    */
    func supplementarySectionItem(atSection section: Int) -> S?
    
    // Update
    
    /**
     Updates an existing cell item at the specified indexPath with a new cell item
     
    - Usage:
     ```
     let dataSource = ....
     let newCellItem = ....
     let indexPath: IndexPath = ....
     dataSource.updateCellItem(atIndexPath: indexPath, withNewCellItem: newCellItem)
     ```
     
    - Parameters:
        - indexPath: The indexPath of the desired item to be updated
        - newCellItem: The new cell item to replace with
    */
    func updateCellItem(atIndexPath indexPath: IndexPath, withNewCellItem newCellItem: T)
    
    /**
     Updates an array of current cell items at the specified indexPaths with new cell items
     
    - Usage:
     ```
     let dataSource = ....
     let newCellItems = [....]
     let indexPaths: [IndexPath] = [....]
     dataSource.updateCellItems(atIndexPaths: indexPaths, withNewCellItems: newCellItems)
     ```
     
    - Note:
        - Since each indexPath corresponds to a new cell item to update with, `indexPaths.count` must equal `newCellItems.count`
     
    - Parameters:
        - indexPaths: The indexPaths of the desired items to be updated
        - newCellItems: The new cell items to replace with
    */
    func updateCellItems(atIndexPaths indexPaths: [IndexPath], newCellItems: [T])
    
    /**
     Updates existing supplementary section items
     
    - Usage:
     ```
     let dataSource = ....
     let newSupplementarySectionItems = [....]
     let sectionIndices: [Int] = [....]
     dataSource.updateSupplementarySectionItems(atSections: sectionIndices, withNewSupplementarySectionItems: newSupplementarySectionItems)
     ```
     
    - Note:
        - Since each section index corresponds to a new supplementary section item to update with, `sections.count` must equal `supplementarySectionItems.count`
     
    - Parameters:
        - sections: The section indices at which the supplementary section items will be updated
        - supplementarySectionItems: The new supplementary section items to replace with
    */
    func updateSupplementarySectionItems(atSections sections: [Int], withNewSupplementarySectionItems supplementarySectionItems: [S])
    
    /**
     Replaces entire sections with new cell items
          
    - Usage:
     ```
     let dataSource = ....
     let sectionIndices: [Int] = [....]
     let newCellItems = [[....]] // Nested array
     dataSource.updateSections(sectionIndices, withNewCellItems: newCellItems)
     ```
     
    - Note:
        - Since each section index corresponds to a nested array of cell items, `sectionIndices.count` must equal `newCellItems.count`
     
    - Parameters:
        - sections: The section indices at which the cell items will be updated
        - newCellItems: The double nested array of new cell items to replace with
    */
    func updateSections(_ sections: [Int], withNewCellItems newCellItems: [[T]])
    
    /**
     Replaces entire sections with new cell items and supplementary section items
          
    - Usage:
     ```
     let dataSource = ....
     let itemSectionIndices: [Int] = [0, 1, 5, 8]
     let supplementarySectionIndices: [Int] = [1, 3, 4]
     let newCellItems = [[....]] // Nested array
     let newSupplementarySectionItems: [Int] = [....]
     dataSource.updateSections(atItemSectionIndices: iteSectionIndices, newCellItems: newCellItems, supplementarySectionIndices: supplementarySectionIndices, newSupplementarySectionItems: newSupplementarySectionItems)
     ```
     
    - Note:
        - Since each section index corresponds to a nested array of cell items or supplementary section items, `sections.count` must equal `newCellItems.count` and `supplementarySectionIndices.count` must equal `newSupplementarySectionItems.count`
        - Also, it is possble to update cell items in some sections and supplementary section items in other sections. Provide the designated sections for both separately if necessary.
     
    - Parameters:
        - sections: The section indices at which the cell items will be updated
        - newCellItems: The double nested array of new cell items to replace with
        - supplementarySectionIndices: The indices of each section to be updated with new supplementary section items
        - newSupplementarySectionItems: The array of new supplementary section items to replace with
    */
    func updateSections(atItemSectionIndices sections: [Int], newCellItems: [[T]], supplementarySectionIndices: [Int], newSupplementarySectionItems: [S])
    
    // Delete
    
    /**
     Deletes cell items at specified indexPaths. Returns an array of Integers representing sections that have been deleted
     
    - Note:
     If an existing section needs to be deleted (i.e., the section is empty after deletions)
     this will return an array of those section indices that were emptied as a result of deletions. If using `collectionView.performBatchUpdates(...)` use this array to delete the sections with `collectionView.deleteSections()`
     
    - Usage:
     ```
     let dataSource = ....
     let indexPathsOfItems = [....]
     let sectionsToDelete = dataSource.deleteCellItems(atIndexPaths: indexPathsOfItems)
     
     // delete sections or call collectionView.reloadData()
     ```
     
    - Parameters:
        - indexPaths: Array of `IndexPath` representing each cell's indexPath to remove
     
    - Returns:
        - An array of `Int` representing each section that was removed as a result of the deletions
     
    */
    @discardableResult func deleteCellItems(atIndexPaths indexPaths: [IndexPath]) -> [Int]
    
    /**
     Deletes supplementary section items at specified section indices
     
    - Usage:
     ```
     let dataSource = ....
     let sectionIndices: [Int] = [....]
     let sectionsToDelete = dataSource.deleteSupplementarySectionItems(atSections: sectionIndices)
     ```
     
    - Parameters:
        - sections: The section indices at which the supplementary section items will be deleted
     
    */
    func deleteSupplementarySectionItems(atSections sections: [Int])
    
    
    /**
     Resets the data provider to its initial empty state
     
    - Usage:
     ```
     let dataSource = ....
     dataSource.reset(keepingStructure: true)
     ```
     
    - Parameters:
        - keepingStructure: Determines if only the cell items and supplementary section items in each section will be removed, but the stucture of sections is maintained, i.e., empty sections will be left over. Otherwise, everything is purged, leaving a completely empty data source with 0 sections
     
    */
    func reset(keepingStructure: Bool)
    
    /**
     Completely replaces entire data source with new cell items and supplementary section items, regardless of existing items and/or section structure
          
    - Usage:
     ```
     let dataSource = ....
     let newCellItems = [[....]] // Nested array
     let newSupplementarySectionItems = [....]
     dataSource.replaceDataSource(withCellItems: newCellItems, supplementarySectionItems: supplementarySectionItems)
     ```
     
    - Parameters:
        - newCellItems: The double nested array of new cell items to replace with
        - supplementarySectionItems: The new supplementary section items to replace with
    */
    func replaceDataSource(withCellItems cellItems: [[T]], supplementarySectionItems: [S])
}











public enum DataSourceUpdateStyle {
    case withBatchUpdates
    case immediately
}

public typealias OptionalCompletionHandler = ((Bool) -> ())?














public typealias CollectionItemSelectionHandler<T> = (IndexPath, T) -> Void
public typealias CollectionItemDeselectionHandler<T> = (IndexPath, T) -> Void
public typealias CollectionItemSizeHandler<T> = (IndexPath, T) -> CGSize
public typealias CollectionSupplementaryHeaderSizeHandler<U> = (Int, U) -> CGSize
public typealias CollectionSupplementaryFooterSizeHandler<U> = (Int, U) -> CGSize
public typealias CollectionBeginPrefetchingHandler<T> = ([IndexPath], [T]) -> Void
public typealias CollectionCancelPrefetchingHandler<T> = ([IndexPath], [T]) -> Void

public typealias CollectionContentOffset = (CGPoint) -> Void
public typealias CollectionScrollViewWillBeginDragging = (UIScrollView) -> Void
public typealias CollectionScrollViewDidEndScrollAnimation = (UIScrollView) -> Void
public typealias CollectionScrollViewDidEndDecelerating = (UIScrollView) -> Void
public typealias CollectionScrollViewWillEndDragging = (UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void
public typealias CollectionScrollViewDidEndDragging = (UIScrollView, Bool) -> Void
