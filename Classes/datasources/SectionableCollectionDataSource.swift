//
//  SectionableCollectionDataSource.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import UIKit

/**
Subclass of `CollectionDataSource` to provide CRUD functions for cell and supplementary section items

*/
open class SectionableCollectionDataSource
    <T, S, U, Cell: ConfigurableReusableCellProtocol, View: ConfigurableReusableViewProtocol>:
    CollectionDataSourceInheritableProtocol<T, S, U, Cell, View>,
    SectionableDataSourceProtocol
    where Cell.T == T, View.T == U
{
    
    // MARK: - Initializers
    
    internal init(collectionView: UICollectionView, cellItems: [[T]], supplementarySectionItems: [S]) {
        let provider = DataSourceProvider<T, S, U>(cellItems: cellItems,
                                                   supplementarySectionItems: supplementarySectionItems)
        super.init(collectionView: collectionView, provider: provider)
        register(cellItems: cellItems, supplementarySectionItems: supplementarySectionItems)
    }
    
    internal init(collectionView: UICollectionView, dataProvider: DataSourceProvider<T, S, U>) {
        super.init(collectionView: collectionView, provider: dataProvider)
        registerItems(in: dataProvider)
    }
    
    
    
    

    /**
     Registers the cells and supplementaryViews included within the `DataSourceProvider` argument, to be dequeued later by the UICollectionView.cellForItem function
     */
    public func registerItems(in dataProvider: DataSourceProvider<T, S, U>) {
        register(cellItems: dataProvider.allCellItems(), supplementarySectionItems: dataProvider.allSupplementarySectionItems())
    }
    
    /**
     Registers a nested array of cells and supplementaryViews to be dequeued later by the UICollectionView.cellForItem function
     */
    public func register(cellItems: [[T]], supplementarySectionItems: [S]?) {
        register(cellItems: cellItems.flatten() as! [T], supplementarySectionItems: supplementarySectionItems)
    }
    
    /**
     Registers the cells and supplementaryViews to be dequeued later by the UICollectionView.cellForItem function
     */
    public func register(cellItems: [T], supplementarySectionItems: [S]?) {
        
        if cellItems.isEmpty == false {
            cellItems.compactMap { (cellItem) -> BaseCollectionCellModel in
                return (cellItem as! BaseCollectionCellModel)
            }.forEach { (cellItem) in
                super.collectionView.register((cellItem.getCellClass()),
                                                forCellWithReuseIdentifier: String(describing: cellItem.getCellClass()))
            }
        }
        
        if let unwrappedSupplementarySectionItems = supplementarySectionItems {
            unwrappedSupplementarySectionItems.forEach { (supplementarySectionItem) in
                guard let supplementarySectionItem = supplementarySectionItem as? BaseSupplementarySectionModel else { fatalError() }
                
                if let header = supplementarySectionItem.header {
                    super.collectionView.register((header.getReusableViewClass()),
                                                  forSupplementaryViewOfKind: header.viewKind,
                                                  withReuseIdentifier: String(describing: header.getReusableViewClass()))
                }
                if let footer = supplementarySectionItem.footer {
                    super.collectionView.register((footer.getReusableViewClass()),
                                                  forSupplementaryViewOfKind: footer.viewKind,
                                                  withReuseIdentifier: String(describing: footer.getReusableViewClass()))
                }
            }
        }
    }
    
    
    
    
    
    // MARK: - Public Functions
    
    open func numberOfSections() -> Int {
        return super.provider.numberOfSections()
    }
    
    public func indexPathOfLastItem(in section: Int) -> IndexPath {
        var indexPathItem: Int = 0
        switch numberOfItems(in: section) {
        case 0, 1: indexPathItem = 0
        default: indexPathItem = numberOfItems(in: section) - 1
        }
        return IndexPath(item: indexPathItem, section: section)
    }
    
    public func indexPathOfLastItem() -> IndexPath {
        guard numberOfSections() > 0 else {
            fatalError("There are no sections. This is an empty data source")
        }
        let lastSection = (numberOfSections() > 1) ? numberOfSections() - 1 : 0
        return self.indexPathOfLastItem(in: lastSection)
    }
    
    open func numberOfItems(in section: Int) -> Int {
        return super.provider.numberOfItems(in: section)
    }
    
    public func allCellItems() -> [[T]] {
        return provider.allCellItems()
    }
    
    public func cellModels(inSection section: Int) -> [T] {
        return allCellItems()[section]
    }
    
    public func allSupplementarySectionItems() -> [S] {
        return provider.allSupplementarySectionItems()
    }
    
    
    
    
    
    
    
    
    // MARK: - Overriden Functions
    
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return self.numberOfSections()
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.numberOfItems(in: section)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = item(atIndexPath: indexPath) else {
            return
        }
        super.composableItemSelectionHandler?(indexPath, item)
    }
    
    open override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let item = item(atIndexPath: indexPath) else {
            return
        }
        super.composableItemDeselectionHandler?(indexPath, item)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Create
    
    open func insert(cellItems: [T],
                     atIndexPaths indexPaths: [IndexPath],
                     updateStyle: DataSourceUpdateStyle = .withBatchUpdates,
                     completion: OptionalCompletionHandler) {
    
        register(cellItems: cellItems, supplementarySectionItems: [])
        
        func insertWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                let indicesOfNewSectionsToInsert = super.provider.insert(cellItems: cellItems, atIndexPaths: indexPaths)
                super.collectionView.insertItems(at: indexPaths)
                if indicesOfNewSectionsToInsert.isEmpty == false {
                    let indexSet = IndexSet(integersIn: indicesOfNewSectionsToInsert.min()!...indicesOfNewSectionsToInsert.max()!)
                    super.collectionView.insertSections(indexSet)
                }
            }, completion: completion)
        }
        
        func insertImmediately() {
            super.provider.insert(cellItems: cellItems, atIndexPaths: indexPaths)
            super.collectionView.reloadData()
            super.collectionView.performBatchUpdates(nil, completion: completion)
        }
        
        
        if updateStyle == .withBatchUpdates {
            insertWithBatchUpdates()
        } else {
            insertImmediately()
        }
    }
    
    open func insert(supplementarySectionItems: [S],
                     atSections sections: [Int],
                     updateStyle: DataSourceUpdateStyle = .withBatchUpdates,
                     completion: OptionalCompletionHandler) {
        
        register(cellItems: [[]], supplementarySectionItems: supplementarySectionItems)
        
        func insertWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                super.provider.insert(supplementarySectionItems: supplementarySectionItems, atSections: sections)
                super.collectionView.reloadSections(IndexSet(sections))
            }, completion: completion)
        }
        
        func insertImmediately() {
            super.provider.insert(supplementarySectionItems: supplementarySectionItems, atSections: sections)
            super.collectionView.reloadData()
            super.collectionView.performBatchUpdates(nil, completion: completion)
        }
        
        if updateStyle == .withBatchUpdates {
            insertWithBatchUpdates()
        } else {
            insertImmediately()
        }
    }
    
    open func insertNewSection(withCellItems cellItems: [T],
                               supplementarySectionItem: S? = nil,
                               atSection section: Int,
                               updateStyle: DataSourceUpdateStyle = .withBatchUpdates,
                               completion: OptionalCompletionHandler) {
        
        var supplementarySectionItems: [S] = []
        if let unwrappedSupplementarySectionItem = supplementarySectionItem {
            supplementarySectionItems.append(unwrappedSupplementarySectionItem)
        }
        register(cellItems: cellItems, supplementarySectionItems: supplementarySectionItems)
        
        func insertWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                super.provider.insertNewSection(withCellItems: cellItems,
                                                supplementarySectionItem: supplementarySectionItem,
                                                atSection: section)
                super.collectionView.insertSections(IndexSet(integer: section))
            }, completion: completion)
        }
        
        func insertImmediately() {
            super.provider.insertNewSection(withCellItems: cellItems, supplementarySectionItem: supplementarySectionItem, atSection: section)
            super.collectionView.reloadData()
            super.collectionView.performBatchUpdates(nil, completion: completion)
        }
        
        if updateStyle == .withBatchUpdates {
            insertWithBatchUpdates()
        } else {
            insertImmediately()
        }
    }
    
    // MARK: - Read
    
    open func item(atIndexPath indexPath: IndexPath) -> T? {
        return super.provider.item(atIndexPath: indexPath)
    }
    
    open func supplementarySectionItem(atSection section: Int) -> S? {
        return super.provider.supplementarySectionItem(atSection: section)
    }
    
    // MARK: - Update
    
    open func updateCellItems(atIndexPaths indexPaths: [IndexPath],
                              newCellItems: [T],
                              updateStyle: DataSourceUpdateStyle = .withBatchUpdates,
                              completion: OptionalCompletionHandler) {
        
        register(cellItems: newCellItems, supplementarySectionItems: [])
        
        func updateWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                super.provider.updateCellItems(atIndexPaths: indexPaths, newCellItems: newCellItems)
                super.collectionView.reloadItems(at: indexPaths)
            }, completion: completion)
        }
        
        func updateImmediately() {
            super.provider.updateCellItems(atIndexPaths: indexPaths, newCellItems: newCellItems)
            super.collectionView.reloadData()
            super.collectionView.performBatchUpdates(nil, completion: completion)
        }
        
        if updateStyle == .withBatchUpdates {
            updateWithBatchUpdates()
        } else {
            updateImmediately()
        }
    }
    
    open func updateSupplementarySectionItems(atSections sections: [Int],
                                              withNewSupplementarySectionItems supplementarySectionItems: [S],
                                              updateStyle: DataSourceUpdateStyle = .withBatchUpdates,
                                              completion: OptionalCompletionHandler) {
        
        register(cellItems: [[]], supplementarySectionItems: supplementarySectionItems)
        
        func updateWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                super.provider.updateSupplementarySectionItems(atSections: sections, withNewSupplementarySectionItems: supplementarySectionItems)
                let indexSet = IndexSet(sections)
                super.collectionView.reloadSections(indexSet)
            }, completion: completion)
        }
        
        func updateImmediately() {
            super.provider.updateSupplementarySectionItems(atSections: sections, withNewSupplementarySectionItems: supplementarySectionItems)
            super.collectionView.reloadData()
            super.collectionView.performBatchUpdates(nil, completion: completion)
        }
        
        if updateStyle == .withBatchUpdates {
            updateWithBatchUpdates()
        } else {
            updateImmediately()
        }
    }
    
    open func updateSections(atItemSectionIndices itemSectionIndices: [Int],
                             newCellItems: [[T]],
                             supplementarySectionIndices: [Int]? = nil,
                             supplementarySectionItems: [S]? = nil,
                             updateStyle: DataSourceUpdateStyle = .withBatchUpdates,
                             completion: OptionalCompletionHandler) {
        
        register(cellItems: newCellItems, supplementarySectionItems: supplementarySectionItems)
        
        func updateWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                super.provider.updateSections(atItemSectionIndices: itemSectionIndices,
                                              newCellItems: newCellItems,
                                              supplementarySectionIndices: supplementarySectionIndices,
                                              newSupplementarySectionItems:  supplementarySectionItems)
                let indexSet = IndexSet(itemSectionIndices)
                super.collectionView.reloadSections(indexSet)
            }, completion: completion)
        }
        
        func updateImmediately() {
            super.provider.updateSections(atItemSectionIndices: itemSectionIndices,
                                          newCellItems: newCellItems,
                                          supplementarySectionIndices: supplementarySectionIndices ?? [],
                                          newSupplementarySectionItems:  supplementarySectionItems ?? [])
            super.collectionView.reloadData()
            super.collectionView.collectionViewLayout.invalidateLayout()
            completion?(true)
            
            // TODO
            // performing batch updates with nil block results in some weird UI glitches
            // check for other uses of this
//            super.collectionView.performBatchUpdates(nil, completion: completion)
        }
        
        if updateStyle == .withBatchUpdates {
            updateWithBatchUpdates()
        } else {
            updateImmediately()
        }
    }
    
    // MARK: - Delete
    
    open func deleteCellItems(atIndexPaths indexPaths: [IndexPath],
                              updateStyle: DataSourceUpdateStyle = .withBatchUpdates,
                              completion: OptionalCompletionHandler) {
        // TODO
        // Consider the case where deleting items in a section
        // will render that section empty.
        // Should you also delete the entire section?
        func deleteWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                let indexSectionsToDelete = super.provider.deleteCellItems(atIndexPaths: indexPaths)
                super.collectionView.deleteItems(at: indexPaths)
                if indexSectionsToDelete.isEmpty == false {
                    super.provider.deleteSupplementarySectionItems(atSections: indexSectionsToDelete)
                    let sectionsToDeleteAt = IndexSet(indexSectionsToDelete)
                    super.collectionView.deleteSections(sectionsToDeleteAt)
                }
            }, completion: completion)
        }
        
        func deleteImmediately() {
            super.provider.deleteCellItems(atIndexPaths: indexPaths)
            super.collectionView.reloadData()
            super.collectionView.performBatchUpdates(nil, completion: completion)
        }
        
        if updateStyle == .withBatchUpdates {
            deleteWithBatchUpdates()
        } else {
            deleteImmediately()
        }
    }
    
    open func deleteSupplementarySectionItems(atSections sections: [Int],
                                              updateStyle: DataSourceUpdateStyle = .withBatchUpdates,
                                              completion: OptionalCompletionHandler) {
        
        func deleteWithBatchUpdates() {
             super.collectionView.performBatchUpdates({
                super.provider.deleteSupplementarySectionItems(atSections: sections)
                super.collectionView.reloadSections(IndexSet(sections))
             }, completion: completion)
        }
        
        func deleteImmediately() {
            super.provider.deleteSupplementarySectionItems(atSections: sections)
            super.collectionView.reloadData()
            super.collectionView.performBatchUpdates(nil, completion: completion)
        }
        
        if updateStyle == .withBatchUpdates {
            deleteWithBatchUpdates()
        } else {
            deleteImmediately()
        }
    }
    
    open func deleteSections(atSectionIndices sections: [Int],
                             updateStyle: DataSourceUpdateStyle = .withBatchUpdates,
                             completion: OptionalCompletionHandler) {
        
        func deleteWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                super.provider.deleteSections(atSections: sections)
                super.collectionView.deleteSections(IndexSet(sections))
            }, completion: completion)
        }
        
        func deleteImmediately() {
            super.provider.deleteSections(atSections: sections)
            super.collectionView.reloadData()
            super.collectionView.performBatchUpdates(nil, completion: completion)
        }
        
        if updateStyle == .withBatchUpdates {
            deleteWithBatchUpdates()
        } else {
            deleteImmediately()
        }
    }
    
    open func replaceDataSource(withCellItems cellItems: [[T]],
                                supplementarySectionItems: [S],
                                updateStyle: DataSourceUpdateStyle = .withBatchUpdates,
                                completion: OptionalCompletionHandler) {
        
        register(cellItems: cellItems, supplementarySectionItems: supplementarySectionItems)
        
        func replaceWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                super.provider.replaceDataSource(withCellItems: cellItems, supplementarySectionItems: supplementarySectionItems)
                let sectionsToReload = Array(0..<cellItems.count)
                super.collectionView.reloadSections(IndexSet(sectionsToReload))
            }, completion: completion)
        }
        
        func replaceImmediately() {
            super.provider.replaceDataSource(withCellItems: cellItems, supplementarySectionItems: supplementarySectionItems)
            super.collectionView.reloadData()
            super.collectionView.performBatchUpdates(nil, completion: completion)
        }
        
        if updateStyle == .withBatchUpdates {
            replaceWithBatchUpdates()
        } else {
            replaceImmediately()
        }
    }
    
    open func reset(keepingStructure: Bool = true, shouldReloadCollectionView: Bool = true) {
        super.provider.reset(keepingStructure: keepingStructure)
        if shouldReloadCollectionView {
            super.collectionView.reloadData()
        }
    }
}
