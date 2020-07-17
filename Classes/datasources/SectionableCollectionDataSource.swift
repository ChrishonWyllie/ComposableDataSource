//
//  SectionableCollectionDataSource.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import UIKit

open class SectionableCollectionDataSource
    <T, Cell: UICollectionViewCell, S, U, View: UICollectionReusableView>:
    CollectionDataSource<DataSourceProvider<T, S, U>, Cell>
where Cell: ConfigurableReusableCell, Cell.T == T, View: ConfigurableReusableSupplementaryView, View.T == U
{
    
    // MARK: - Lifecycle
    
    public init(collectionView: UICollectionView, cellItems: [[T]], supplementarySectionItems: [S]) {
        let provider = DataSourceProvider<T, S, U>(cellItems: cellItems, supplementarySectionItems: supplementarySectionItems)
        super.init(collectionView: collectionView, provider: provider)
        register(cellItems: cellItems, supplementarySectionItems: supplementarySectionItems)
    }
    
    public init(collectionView: UICollectionView, dataProvider: DataSourceProvider<T, S, U>) {
        super.init(collectionView: collectionView, provider: dataProvider)
        registerItems(in: dataProvider)
    }
    
    // MARK: - Public Methods
    public func item(atIndexPath indexPath: IndexPath) -> T? {
        return super.provider.item(atIndexPath: indexPath)
    }
    
    public func supplementarySectionItem(atSection section: Int) -> S? {
        return super.provider.supplementarySectionItem(atSection: section)
    }
    
    public func numberOfSections() -> Int {
        return super.provider.numberOfSections()
    }
    
    public func reset(keepingStructure: Bool = true, reload: Bool? = nil) {
        provider.reset(keepingStructure: keepingStructure)
        
        if reload == true {
            super.collectionView.reloadData()
        }
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
    
    public func numberOfItems(in section: Int) -> Int {
        return super.provider.numberOfItems(in: section)
    }
    
    public func registerItems(in dataProvider: DataSourceProvider<T, S, U>) {
        register(cellItems: dataProvider.allCellItems(), supplementarySectionItems: dataProvider.allSupplementarySectionItems())
    }
    
    public func register(cellItems: [[T]], supplementarySectionItems: [S]) {
        register(cellItems: cellItems.flatten() as! [T], supplementarySectionItems: supplementarySectionItems)
    }
    
    public func register(cellItems: [T], supplementarySectionItems: [S]) {
        // TODO
        // This should replace the need to
        // manually register cells in dataSources
        // that begin with 0 items
        // However, you should check if this
        // is efficient
        if cellItems.count > 0 {
            cellItems.compactMap { (cellItem) -> GenericCellModel in
                return (cellItem as! GenericCellModel)
                }.forEach { (cellItem) in
                    super.collectionView.register((cellItem.cellClass).self,
                                                  forCellWithReuseIdentifier: String(describing: type(of: (cellItem.cellClass))))
            }
        }
        
        // TODO
        // Find a way to do this automatically
        // Or create a utility function so you don't have
        // to copy this code
        if supplementarySectionItems.count > 0 {
            supplementarySectionItems.forEach { (supplementarySectionItem) in
                guard let supplementarySectionItem = supplementarySectionItem as? GenericSupplementarySectionModel else { fatalError() }
                
                if let header = supplementarySectionItem.header {
                    super.collectionView.register((header.supplementaryViewClass).self,
                                                  forSupplementaryViewOfKind: header.viewKind,
                                                  withReuseIdentifier: String(describing: type(of: header.supplementaryViewClass.self)))
                }
                if let footer = supplementarySectionItem.footer {
                    super.collectionView.register((footer.supplementaryViewClass).self,
                                                  forSupplementaryViewOfKind: footer.viewKind,
                                                  withReuseIdentifier: String(describing: type(of: footer.supplementaryViewClass.self)))
                }
            }
        }
    }
    
    public func updateCellItems(atIndexPaths indexPaths: [IndexPath], newCellItems: [T], updateStyle: DataSourceUpdateStyle = .withBatchUpdates, completion: OptionalCompletionHandler) {
        
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
    
    public func updateSections(atItemSectionIndices itemSectionIndices: [Int],
                               newCellItems: [[T]],
                               supplementarySectionItems: [S]? = nil,
                               supplementarySectionIndices: [Int]? = nil,
                               updateStyle: DataSourceUpdateStyle = .withBatchUpdates,
                               completion: OptionalCompletionHandler) {
        
        register(cellItems: newCellItems, supplementarySectionItems: supplementarySectionItems ?? [])
        
        func updateWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                super.provider.updateSections(atItemSectionIndices: itemSectionIndices,
                                              newCellItems: newCellItems,
                                              supplementarySectionIndices: supplementarySectionIndices ?? [],
                                              newSupplementarySectionItems:  supplementarySectionItems ?? [])
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
    
    public func insert(cellItems: [T], atIndexPaths indexPaths: [IndexPath], updateStyle: DataSourceUpdateStyle = .withBatchUpdates, completion: OptionalCompletionHandler) {
        
        register(cellItems: cellItems, supplementarySectionItems: [])
        
        func insertWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                let indicesOfNewSectionsToInsert = super.provider.insert(cellItems: cellItems, atIndexPaths: indexPaths)
                super.collectionView.insertItems(at: indexPaths)
                if indicesOfNewSectionsToInsert.count > 0 {
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
    
    public func deleteCellItems(atIndexPaths indexPaths: [IndexPath], updateStyle: DataSourceUpdateStyle = .withBatchUpdates, completion: OptionalCompletionHandler) {
        // TODO
        // Consider the case where deleting items in a section
        // will render that section empty.
        // Should you also delete the entire section?
        func deleteWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                let indexSectionsToDelete = super.provider.deleteCellItems(atIndexPaths: indexPaths)
                super.collectionView.deleteItems(at: indexPaths)
                if indexSectionsToDelete.count > 0 {
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
    
    public func updateSupplementarySectionsItems(atSections sections: [Int],
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
    
    public func insert(supplementarySectionItems: [S],
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
    
    public func deleteSupplementarySectionItems(atSections sections: [Int],
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
    
    public func replaceDataSource(withCellItems cellItems: [[T]],
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
}
