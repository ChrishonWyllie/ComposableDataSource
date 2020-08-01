//
//  Protocols+Declarations.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import UIKit

// MARK: - Configurable Views

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



/// Convenient combination of ConfigurableReusableCell and UICollectionViewCell
public typealias ConfigurableReusableCellProtocol = ConfigurableReusableCell & UICollectionViewCell

/// Convenient combination of ConfigurableReusableSupplementaryView and UICollectionReusableView
public typealias ConfigurableReusableViewProtocol = ConfigurableReusableSupplementaryView & UICollectionReusableView














public enum DataSourceUpdateStyle {
    case withBatchUpdates
    case immediately
}

public typealias OptionalCompletionHandler = ((Bool) -> ())?

























// MARK: - Action Handlers

public typealias ComposableItemSelectionHandler<T> = (IndexPath, T) -> Void
public typealias ComposableItemDeselectionHandler<T> = (IndexPath, T) -> Void
public typealias ComposableItemSizeHandler<T> = (IndexPath, T) -> CGSize
public typealias ComposableSupplementaryHeaderSizeHandler<U> = (Int, U) -> CGSize
public typealias ComposableSupplementaryFooterSizeHandler<U> = (Int, U) -> CGSize
public typealias ComposableBeginPrefetchingHandler<T> = ([IndexPath], [T]) -> Void
public typealias ComposableCancelPrefetchingHandler<T> = ([IndexPath], [T]) -> Void

public typealias ComposableContentOffsetHandler = (CGPoint) -> Void
public typealias ComposableScrollViewWillBeginDraggingHandler = (UIScrollView) -> Void
public typealias ComposableScrollViewDidEndScrollAnimationHandler = (UIScrollView) -> Void
public typealias ComposableScrollViewDidEndDeceleratingHandler = (UIScrollView) -> Void
public typealias ComposableScrollViewWillEndDraggingHandler = (UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void
public typealias ComposableScrollViewDidEndDraggingHandler = (UIScrollView, Bool) -> Void













/**

Typealias for conforming to CollectionDataSource superclass
 
    - Parameters:
        - T: The expected cell model used to configure the Configurable Resuable UICollectionViewCell
        - S: The expected supplementary section model used to contain a header and/or footer supplementary item
        - U: The expected supplementary item used to configure the Configurable Reusable Supplementary UICollectionReusableView
        - Cell: The Configurable Reusable UICollectionViewCell
        - View: The Configurable Reusable Supplementary UICollectionReusableView
*/
public typealias CollectionDataSourceInheritableProtocol<T, S, U, Cell, View> = CollectionDataSource<DataSourceProvider<T, S, U>, Cell, View>
    where Cell: ConfigurableReusableCellProtocol, Cell.T == T, View: ConfigurableReusableViewProtocol, View.T == U

/// Typealias for conforming to SectionableDataSource superclass
public typealias SectionableDataSourceInheriableProtocol = SectionableCollectionDataSource
<BaseCollectionCellModel,
BaseSupplementarySectionModel,
BaseCollectionSupplementaryViewModel,
BaseComposableCollectionViewCell,
BaseComposableCollectionReusableView>






































public protocol ComposableDataSourceActionHandlerProtocol {
    
    /**
     Provides completion block for handling UICollectionView selection events.
     Treat completion block as you would when implementing `collectionView(_:didSelectItemAt:)`
     
    - Usage:
    ```
    let dataSource = ...
    dataSource.didSelectItem { (indexPath: IndexPath, cellItem: BaseCollectionCellModel) in
        // ... Handle cell selection
    }
    ```
     
    - Parameters:
        - completion: Completion handler block in which you will handle selection events using the selected cell item at the selected IndexPath
    */
    @discardableResult func didSelectItem(_ completion: @escaping ComposableItemSelectionHandler<BaseCollectionCellModel>) -> ComposableCollectionDataSource
       
    /**
     Provides completion block for handling UICollectionView deselection events.
     Treat completion block as you would when implementing `collectionView(_:didDeselectItemAt:)`
     
    - Usage:
    ```
    let dataSource = ...
    dataSource.didDeselectItem { (indexPath: IndexPath, cellItem: BaseCollectionCellModel) in
        // ... Handle cell deselection
    }
    ```
     
    - Parameters:
        - completion: Completion handler block in which you will handle deselection events using the deselected cell item at the deselected IndexPath
    */
    @discardableResult func didDeselectItem(_ completion: @escaping ComposableItemDeselectionHandler<BaseCollectionCellModel>) -> ComposableCollectionDataSource
    
    /**
     Provides completion block for returning UICollectionViewCell sizes at specific indexPaths
     Treat completion block as you would when implementing `collectionView(_:layout:sizeForItemAt:)`
     
    - Usage:
    ```
    let dataSource = ...
    dataSource.sizeForItem { (indexPath: IndexPath, cellItem: BaseCollectionCellModel) in
        // ... Handle cell size
    }
    ```
     
    - Parameters:
        - completion: Completion handler block in which you will provide custom cell sizing using the deselected cell item at the deselected IndexPath
    */
    @discardableResult func sizeForItem(_ completion: @escaping ComposableItemSizeHandler<BaseCollectionCellModel>) -> ComposableCollectionDataSource
    
    /**
     Provides completion block for returning UICollectionReusableView header sizes at specific indexPaths
     Treat completion block as you would when implementing `collectionView(_:layout:referenceSizeForHeaderInSection:)`
     
    - Usage:
    ```
    let dataSource = ...
    dataSource.referenceSizeForHeader { (section: Int, supplementaryItem: BaseCollectionSupplementaryViewModel) in
        // ... Handle header supplementary view size
    }
    ```
     
    - Parameters:
        - completion: Completion handler block in which you will provide custom supplementary view sizing using the supplementary view item at the section index
    */
    @discardableResult func referenceSizeForHeader(_ completion: @escaping ComposableSupplementaryHeaderSizeHandler<BaseCollectionSupplementaryViewModel>) -> ComposableCollectionDataSource
    
    /**
     Provides completion block for returning UICollectionReusableView footer sizes at specific indexPaths
     Treat completion block as you would when implementing `collectionView(_:layout:referenceSizeForFooterInSection:)`
     
    - Usage:
    ```
    let dataSource = ...
    dataSource.referenceSizeForFooter { (section: Int, supplementaryItem: BaseCollectionSupplementaryViewModel) in
        // ... Handle footer supplementary view size
    }
    ```
     
    - Parameters:
        - completion: Completion handler block in which you will provide custom supplementary view sizing using the supplementary view item at the section index
    */
    @discardableResult func referenceSizeForFooter(_ completion: @escaping ComposableSupplementaryFooterSizeHandler<BaseCollectionSupplementaryViewModel>) -> ComposableCollectionDataSource
    
    /**
     Provides completion block for handling UICollectionView prefetching events.
     Treat completion block as you would when implementing `collectionView(_:prefetchItemsAt:)`
     
    - Usage:
    ```
    let dataSource = ...
    dataSource.prefetchItems { (indexPaths: [IndexPath], cellItems: [BaseCollectionCellModel]) in
        // ... Handle prefetching with the requested cell items
    }
    ```
     
    - Parameters:
        - completion: Completion handler block in which you will perform some "pre-heat" action on the requested cell items that are about to be displayed
    */
    @discardableResult func prefetchItems(_ completion: @escaping ComposableBeginPrefetchingHandler<BaseCollectionCellModel>) -> ComposableCollectionDataSource
    
    /**
     Provides completion block for handling UICollectionView cancelled prefetching events.
     Treat completion block as you would when implementing `collectionView(_:cancelPrefetchingForItemsAt:)`
     
    - Usage:
    ```
    let dataSource = ...
    dataSource.cancelPrefetchingForItems { (indexPaths: [IndexPath], cellItems: [BaseCollectionCellModel]) in
        // ... Handle cancellations on the previously requested/prefetched cell items
    }
    ```
     
    - Parameters:
        - completion: Completion handler block in which you will cancel some "pre-heat" action on the requested cell items
    */
    @discardableResult func cancelPrefetchingForItems(_ completion: @escaping ComposableCancelPrefetchingHandler<BaseCollectionCellModel>) -> ComposableCollectionDataSource
}

















































// MARK: - SectionableDataSource

/**
Protocol for data sources that allow for multiple sections
Provides basic CRUD functions for handling data displayed in UICollectionView
*/
public protocol SectionableDataSourceProtocol {
    
    associatedtype T
    
    associatedtype S
    
    func indexPathOfLastItem(in section: Int) -> IndexPath
    
    func indexPathOfLastItem() -> IndexPath
    
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
    
    /**
     Inserts cell items at specified indexPaths.
     
     
    - Usage:
     ```
     let dataSource = ....
     let itemsToInsert = [....]
     let indexPathsOfItems = [....]
     let newSections = dataSource.insert(cellItems: itemsToInsert, at: indexPathsOfItems, updateStyle: .withBatchUpdates, completion: nil)
     ```
     
    - Parameters:
        - cellItems: Array of items representing each cell to insert
        - indexPaths: Array of `IndexPath` representing each cell's final expected indexPath
        - updateStyle: Enum dictating how the updates will happen, either by calling `performBatchUpdates(...)` or with `reloadData()`
        - completion: Completion handler called at the end of function
     
    */
    func insert(cellItems: [T],
                atIndexPaths indexPaths: [IndexPath],
                updateStyle: DataSourceUpdateStyle,
                completion: OptionalCompletionHandler)
    
    /**
     Inserts supplementary section items at specified section indices
     
    - Usage:
     ```
     let dataSource = ....
     let supplementarySectionItems = [....]
     let sectionIndices: [Int] = [1, 3, 6]
     dataSource.insert(supplementarySectionItems: supplementarySectionItem, atSections: sectionIndices, updateStyle: .withBatchUpdates, completion: nil)
     ```
     
    - Parameters:
        - supplementarySectionItems: section items representing supplementary headers and/or footers in data source
        - sections: The section indices at which the supplementary section items will be inserted
        - updateStyle: Enum dictating how the updates will happen, either by calling `performBatchUpdates(...)` or with `reloadData()`
        - completion: Completion handler called at the end of function
    */
    func insert(supplementarySectionItems: [S],
                atSections sections: [Int],
                updateStyle: DataSourceUpdateStyle,
                completion: OptionalCompletionHandler)
    
    /**
     Inserts a new section with a new array of cell items and supplementary section items at a specified section index. Essentially, moves down sections after this index and creates room for new section
     
    - Usage:
     ```
     let dataSource = ....
     let itemsToInsert = [....]
     let supplementarySectionItem = ....
     let sectionIndex: Int = 3
     dataSource.insertNewSection(withCellItems: itemsToInsert, supplementarySectionItem: supplementarySectionItem, atSection: sectionIndex, updateStyle: .withBatchUpdates, completion: nil)
     ```
     
    - Parameters:
        - cellItems: The new cell items to insert
        - supplementarySectionItem: The new supplementary section item to insert
        - section: The section index that will be created/inserted with the new cell items
        - updateStyle: Enum dictating how the updates will happen, either by calling `performBatchUpdates(...)` or with `reloadData()`
        - completion: Completion handler called at the end of function
    */
    func insertNewSection(withCellItems cellItems: [T],
                          supplementarySectionItem: S?,
                          atSection section: Int,
                          updateStyle: DataSourceUpdateStyle,
                          completion: OptionalCompletionHandler)
    
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
    
    /**
     Updates an array of current cell items at the specified indexPaths with new cell items
     
    - Usage:
     ```
     let dataSource = ....
     let newCellItems = [....]
     let indexPaths: [IndexPath] = [....]
     dataSource.updateCellItems(atIndexPaths: indexPaths, withNewCellItems: newCellItems, updateStyle: .withBatchUpdates, completion: nil)
     ```
     
    - Note:
        - Since each indexPath corresponds to a new cell item to update with, `indexPaths.count` must equal `newCellItems.count`
     
    - Parameters:
        - indexPaths: The indexPaths of the desired items to be updated
        - newCellItems: The new cell items to replace with
        - updateStyle: Enum dictating how the updates will happen, either by calling `performBatchUpdates(...)` or with `reloadData()`
        - completion: Completion handler called at the end of function
     
    */
    func updateCellItems(atIndexPaths indexPaths: [IndexPath],
                         newCellItems: [T],
                         updateStyle: DataSourceUpdateStyle,
                         completion: OptionalCompletionHandler)
    
    /**
     Updates existing supplementary section items
     
    - Usage:
     ```
     let dataSource = ....
     let newSupplementarySectionItems = [....]
     let sectionIndices: [Int] = [....]
     dataSource.updateSupplementarySectionItems(atSections: sectionIndices, withNewSupplementarySectionItems: newSupplementarySectionItems, updateStyle: .withBatchUpdates, completion: nil)
     ```
     
    - Note:
        - Since each section index corresponds to a new supplementary section item to update with, `sections.count` must equal `supplementarySectionItems.count`
     
    - Parameters:
        - sections: The section indices at which the supplementary section items will be updated
        - supplementarySectionItems: The new supplementary section items to replace with
        - updateStyle: Enum dictating how the updates will happen, either by calling `performBatchUpdates(...)` or with `reloadData()`
        - completion: Completion handler called at the end of function
    */
    func updateSupplementarySectionsItems(atSections sections: [Int],
                                          withNewSupplementarySectionItems supplementarySectionItems: [S],
                                          updateStyle: DataSourceUpdateStyle,
                                          completion: OptionalCompletionHandler)
    
    /**
     Replaces entire sections with new cell items and supplementary section items
          
    - Usage:
     ```
     let dataSource = ....
     let itemSectionIndices: [Int] = [0, 1, 5, 8]
     let supplementarySectionIndices: [Int] = [1, 3, 4]
     let newCellItems = [[....]] // Nested array
     let newSupplementarySectionItems: [Int] = [....]
     dataSource.updateSections(atItemSectionIndices: iteSectionIndices, newCellItems: newCellItems, supplementarySectionIndices: supplementarySectionIndices, newSupplementarySectionItems: newSupplementarySectionItems, updateStyle: .withBatchUpdates, completion: nil)
     ```
     
    - Note:
        - Since each section index corresponds to a nested array of cell items or supplementary section items, `sections.count` must equal `newCellItems.count` and `supplementarySectionIndices.count` must equal `newSupplementarySectionItems.count`
        - Also, it is possble to update cell items in some sections and supplementary section items in other sections. Provide the designated sections for both separately if necessary.
     
    - Parameters:
        - sections: The section indices at which the cell items will be updated
        - newCellItems: The double nested array of new cell items to replace with
        - supplementarySectionIndices: The indices of each section to be updated with new supplementary section items
        - newSupplementarySectionItems: The array of new supplementary section items to replace with
        - updateStyle: Enum dictating how the updates will happen, either by calling `performBatchUpdates(...)` or with `reloadData()`
        - completion: Completion handler called at the end of function
    */
    func updateSections(atItemSectionIndices itemSectionIndices: [Int],
                        newCellItems: [[T]],
                        supplementarySectionIndices: [Int]?,
                        supplementarySectionItems: [S]?,
                        updateStyle: DataSourceUpdateStyle,
                        completion: OptionalCompletionHandler)
    
    /**
     Deletes cell items at specified indexPaths
     
    - Usage:
     ```
     let dataSource = ....
     let indexPathsOfItems = [....]
     let sectionsToDelete = dataSource.deleteCellItems(atIndexPaths: indexPathsOfItems, updateStyle: .withBatchUpdates, completion: nil)
     ```
     
    - Parameters:
        - indexPaths: Array of `IndexPath` representing each cell's indexPath to remove
        - updateStyle: Enum dictating how the updates will happen, either by calling `performBatchUpdates(...)` or with `reloadData()`
        - completion: Completion handler called at the end of function
    */
    func deleteCellItems(atIndexPaths indexPaths: [IndexPath],
                         updateStyle: DataSourceUpdateStyle,
                         completion: OptionalCompletionHandler)
    
    /**
     Deletes supplementary section items at specified section indices
     
    - Usage:
     ```
     let dataSource = ....
     let sectionIndices: [Int] = [....]
     let sectionsToDelete = dataSource.deleteSupplementarySectionItems(atSections: sectionIndices, updateStyle: .withBatchUpdates, completion: nil)
     ```
     
    - Parameters:
        - sections: The section indices at which the supplementary section items will be deleted
        - updateStyle: Enum dictating how the updates will happen, either by calling `performBatchUpdates(...)` or with `reloadData()`
        - completion: Completion handler called at the end of function
     
    */
    func deleteSupplementarySectionItems(atSections sections: [Int],
                                         updateStyle: DataSourceUpdateStyle,
                                         completion: OptionalCompletionHandler)
    
    /**
     Deletes cell items and supplementary section items at the specifed section indices
          
    - Usage:
     ```
     let dataSource = ....
     let sectionIndices: [Int] = [0, 1, 5, 8]
     dataSource.deleteSections(atSections: sectionIndices, updateStyle: .withBatchUpdates, completion: nil)
     ```
        
    - Parameters:
        - sections: The section indices which will be deleted
        - updateStyle: Enum dictating how the updates will happen, either by calling `performBatchUpdates(...)` or with `reloadData()`
        - completion: Completion handler called at the end of function
    */
    func deleteSections(atSectionIndices sections: [Int],
                        updateStyle: DataSourceUpdateStyle,
                        completion: OptionalCompletionHandler)
    
    /**
     Completely replaces entire data source with new cell items and supplementary section items, regardless of existing items and/or section structure
          
    - Usage:
     ```
     let dataSource = ....
     let newCellItems = [[....]] // Nested array
     let newSupplementarySectionItems = [....]
     dataSource.replaceDataSource(withCellItems: newCellItems, supplementarySectionItems: supplementarySectionItems, updateStyle: .withBatchUpdates, completion: nil)
     ```
     
    - Parameters:
        - cellItems: The double nested array of new cell items to replace with
        - supplementarySectionItems: The new supplementary section items to replace with
        - updateStyle: Enum dictating how the updates will happen, either by calling `performBatchUpdates(...)` or with `reloadData()`
        - completion: Completion handler called at the end of function
    */
    func replaceDataSource(withCellItems cellItems: [[T]],
                           supplementarySectionItems: [S],
                           updateStyle: DataSourceUpdateStyle,
                           completion: OptionalCompletionHandler)
    
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
    
}

















// MARK: - CollectionDataProvider

/**
 Protocol for cell and supplementary section items provider
 Provides basic CRUD functions for handling data displayed in UICollectionView
 */
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
     let provider = ....
     if provider.isEmpty {
        // ...
     }
     ```
    */
    var isEmpty: Bool { get }
    
    /**
     Returns double nested array of all items representing cells in each section
     
    - Usage:
     ```
     let provider = ....
     let allItems = provider.allItems()
     ```
    */
    func allCellItems() -> [[T]]
    
    /**
     Returns all items representing section supplementary views
     
    - Usage:
     ```
     let provider = ....
     let allSupplementaryItems = provider.allSupplementarySectionItems()
     ```
    */
    func allSupplementarySectionItems() -> [S]
    
    /**
     Returns the number of sections represented by the data provider, and therefore, the number sections in the UICollectionView
     
    - Usage:
     ```
     let provider = ....
     let numSections = provider.numberOfSections()
     ```
    */
    func numberOfSections() -> Int
    
    /**
     Returns the number of items in a specific section, and therefore, the number of items in a specific UICollectionView section
     
    - Usage:
     ```
     let provider = ....
     let sectionIndex: Int = 0
     let numItemsInSection = provider.numberOfItems(in: sectionIndex)
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
     let provider = ....
     let itemsToAppend = [....]
     let sectionIndex: Int = 2
     provider.append(items: itemsToAppend, inNestedSection: sectionIndex)
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
     let provider = ....
     let itemsToAppend = [....]
     let sectionIndex: Int = 2
     provider.appendNewSection(with: itemsToAppend)
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
     let provider = ....
     let supplementarySectionItem = ....
     provider.append(supplementarySectionItem: supplementarySectionItem)
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
     let provider = ....
     let itemsToInsert = [....]
     let indexPathsOfItems = [....]
     let newSections = provider.insert(cellItems: itemsToInsert, at: indexPathsOfItems)
     
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
     let provider = ....
     let itemsToInsert = [....]
     let sectionIndex: Int = 2
     let indexWithinSection: Int = 9
     provider.insert(cellItems: itemsToInsert, inNestedSection: sectionIndex, atIndex: indexWithinSection)
     ```
     
    - Parameters:
        - cellItems: Array of items representing each cell to insert
        - section: The section index by which the cell items will be inserted into
        - index: The index within the section by which the array will be inserted at. If nil, will insert at index 0 (beginning of the specified section).
     
    */
    func insert(cellItems: [T], inNestedSection section: Int, atIndex index: Int?)
    
    /**
     Inserts a new section with a new array of cell items and supplementary section items at a specified section index. Essentially, moves down sections after this index and creates room for new section
     
    - Note:
     Be aware that adding new sections will require calling `collectionView.insertSections()` if using `collectionView.performBatchUpdates(...)`
        
    - Usage:
     ```
     let provider = ....
     let itemsToInsert = [....]
     let supplementarySectionItem = ....
     let sectionIndex: Int = 3
     provider.insertNewSection(withCellItems: itemsToInsert, supplementarySectionItem: supplementarySectionItem, atSection: sectionIndex)
     ```
     
    - Parameters:
        - cellItems: The new cell items to insert
        - supplementarySectionItem: The new supplementary section item to insert
        - section: The section index that will be created/inserted with the new cell items
     
    */
    func insertNewSection(withCellItems cellItems: [T], supplementarySectionItem: S?, atSection section: Int)
    
    /**
     Inserts a supplementary section item at a specified section index
     
    - Usage:
     ```
     let provider = ....
     let supplementarySectionItem = ....
     let sectionIndex: Int = 3
     provider.insert(supplementarySectionItem: supplementarySectionItem, atSection: sectionIndex)
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
     let provider = ....
     let supplementarySectionItems = [....]
     let sectionIndices: [Int] = [1, 3, 6]
     provider.insert(supplementarySectionItems: supplementarySectionItem, atSections: sectionIndices)
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
     let provider = ....
     let indexPath: IndexPath = ....
     let cellItem = provider.item(atIndexPath: indexPath)
     
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
     let provider = ....
     let indexPath: [IndexPath] = [....]
     let cellItems = provider.items(atIndexPaths: indexPaths)
     
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
     let provider = ....
     let sectionIndex: Int = ....
     let supplementarySectionItem = provider.supplementarySectionItem(atSection: sectionIndex)
     
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
     let provider = ....
     let newCellItem = ....
     let indexPath: IndexPath = ....
     provider.updateCellItem(atIndexPath: indexPath, withNewCellItem: newCellItem)
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
     let provider = ....
     let newCellItems = [....]
     let indexPaths: [IndexPath] = [....]
     provider.updateCellItems(atIndexPaths: indexPaths, withNewCellItems: newCellItems)
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
     let provider = ....
     let newSupplementarySectionItems = [....]
     let sectionIndices: [Int] = [....]
     provider.updateSupplementarySectionItems(atSections: sectionIndices, withNewSupplementarySectionItems: newSupplementarySectionItems)
     ```
     
    - Note:
        - Since each section index corresponds to a new supplementary section item to update with, `sections.count` must equal `supplementarySectionItems.count`
     
    - Parameters:
        - sections: The section indices at which the supplementary section items will be updated
        - supplementarySectionItems: The new supplementary section items to replace with
    */
    func updateSupplementarySectionItems(atSections sections: [Int], withNewSupplementarySectionItems supplementarySectionItems: [S])
    
    /**
     Replaces entire sections with new cell items and supplementary section items
          
    - Usage:
     ```
     let provider = ....
     let itemSectionIndices: [Int] = [0, 1, 5, 8]
     let supplementarySectionIndices: [Int] = [1, 3, 4]
     let newCellItems = [[....]] // Nested array
     let newSupplementarySectionItems: [Int] = [....]
     provider.updateSections(atItemSectionIndices: iteSectionIndices, newCellItems: newCellItems, supplementarySectionIndices: supplementarySectionIndices, newSupplementarySectionItems: newSupplementarySectionItems)
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
    func updateSections(atItemSectionIndices sections: [Int],
                        newCellItems: [[T]],
                        supplementarySectionIndices: [Int]?,
                        newSupplementarySectionItems: [S]?)
    
    // Delete
    
    /**
     Deletes cell items at specified indexPaths. Returns an array of Integers representing sections that have been deleted
     
    - Note:
     If an existing section needs to be deleted (i.e., the section is empty after deletions)
     this will return an array of those section indices that were emptied as a result of deletions. If using `collectionView.performBatchUpdates(...)` use this array to delete the sections with `collectionView.deleteSections()`
     
    - Usage:
     ```
     let provider = ....
     let indexPathsOfItems = [....]
     let sectionsToDelete = provider.deleteCellItems(atIndexPaths: indexPathsOfItems)
     
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
     let provider = ....
     let sectionIndices: [Int] = [....]
     let sectionsToDelete = provider.deleteSupplementarySectionItems(atSections: sectionIndices)
     ```
     
    - Parameters:
        - sections: The section indices at which the supplementary section items will be deleted
     
    */
    func deleteSupplementarySectionItems(atSections sections: [Int])
    
    
    /**
     Deletes cell items and supplementary section items at the specifed section indices
          
    - Usage:
     ```
     let provider = ....
     let sectionIndices: [Int] = [0, 1, 5, 8]
     provider.deleteSections(atSections: sectionIndices)
     ```
        
    - Parameters:
        - sections: The section indices which will be deleted
    */
    func deleteSections(atSections sections: [Int])
    
    /**
     Completely replaces entire data source with new cell items and supplementary section items, regardless of existing items and/or section structure
          
    - Usage:
     ```
     let provider = ....
     let newCellItems = [[....]] // Nested array
     let newSupplementarySectionItems = [....]
     provider.replaceDataSource(withCellItems: newCellItems, supplementarySectionItems: supplementarySectionItems)
     ```
     
    - Parameters:
        - newCellItems: The double nested array of new cell items to replace with
        - supplementarySectionItems: The new supplementary section items to replace with
    */
    func replaceDataSource(withCellItems cellItems: [[T]], supplementarySectionItems: [S])
    
    /**
     Resets the data provider to its initial empty state
     
    - Usage:
     ```
     let provider = ....
     provider.reset(keepingStructure: true)
     ```
     
    - Parameters:
        - keepingStructure: Determines if only the cell items and supplementary section items in each section will be removed, but the stucture of sections is maintained, i.e., empty sections will be left over. Otherwise, everything is purged, leaving a completely empty data source with 0 sections
     
    */
    func reset(keepingStructure: Bool)
    
}
