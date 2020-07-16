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
    
    public init(collectionView: UICollectionView, array: [[T]], supplementaryItems: [S]) {
        let provider = DataSourceProvider<T, S, U>(array: array, supplementaryItems: supplementaryItems)
        super.init(collectionView: collectionView, provider: provider)
        register(sectionModels: array, supplementaryContainerItems: supplementaryItems)
    }
    
    public init(collectionView: UICollectionView, dataProvider: DataSourceProvider<T, S, U>) {
        super.init(collectionView: collectionView, provider: dataProvider)
        registerItems(in: dataProvider)
    }
    
    // MARK: - Public Methods
    public func item(at indexPath: IndexPath) -> T? {
        return super.provider.item(at: indexPath)
    }
    
    public func supplementaryContainerItem(at section: Int) -> S? {
        return super.provider.supplementaryContainerItem(at: section)
    }
    
    public func numberOfSections() -> Int {
        return super.provider.numberOfSections()
    }
    
    public func clearAllItems(keepingStructure: Bool = true, reload: Bool? = nil) {
        // Clears each of the items in each section, but
        // maintains the empty items
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
        register(sectionModels: dataProvider.allItems(), supplementaryContainerItems: dataProvider.allSupplementaryItems())
    }
    
    public func register(sectionModels: [[T]], supplementaryContainerItems: [S]) {
        register(models: sectionModels.flatten() as! [T], supplementaryContainerItems: supplementaryContainerItems)
    }
    
    public func register(models: [T], supplementaryContainerItems: [S]) {
        // TODO
        // This should replace the need to
        // manually register cells in dataSources
        // that begin with 0 items
        // However, you should check if this
        // is efficient
        if models.count > 0 {
            models.compactMap { (model) -> GenericCellModel in
                return (model as! GenericCellModel)
                }.forEach { (model) in
                    super.collectionView.register((model.cellClass).self, forCellWithReuseIdentifier: String(describing: type(of: (model.cellClass))))
            }
        }
        
        // TODO
        // Find a way to do this automatically
        // Or create a utility function so you don't have
        // to copy this code
        if supplementaryContainerItems.count > 0 {
            supplementaryContainerItems.forEach { (item) in
                guard let supplementaryContainerModel = item as? GenericSupplementaryContainerModel else { fatalError() }
                
                if let header = supplementaryContainerModel.header {
                    super.collectionView.register((header.supplementaryViewClass).self, forSupplementaryViewOfKind: header.viewKind, withReuseIdentifier: String(describing: type(of: header.supplementaryViewClass.self)))
                }
                if let footer = supplementaryContainerModel.footer {
                    super.collectionView.register((footer.supplementaryViewClass).self, forSupplementaryViewOfKind: footer.viewKind, withReuseIdentifier: String(describing: type(of: footer.supplementaryViewClass.self)))
                }
            }
        }
    }
    
    public func updateItems(at indexPaths: [IndexPath], values: [T], updateStyle: DataSourceUpdateStyle = .withBatchUpdates, completion: OptionalCompletionHandler) {
        
        register(models: values, supplementaryContainerItems: [])
        
        func updateWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                super.provider.updateItems(at: indexPaths, values: values)
                super.collectionView.reloadItems(at: indexPaths)
            }, completion: completion)
        }
        
        func updateImmediately() {
            super.provider.updateItems(at: indexPaths, values: values)
            super.collectionView.reloadData()
            super.collectionView.performBatchUpdates(nil, completion: completion)
        }
        
        if updateStyle == .withBatchUpdates {
            updateWithBatchUpdates()
        } else {
            updateImmediately()
        }
    }
    
    public func updateSections(atItemSectionIndices itemIndices: [Int],
                               items: [[T]],
                               supplementaryItems: [S]? = nil,
                               supplementarySectionIndices: [Int]? = nil,
                               updateStyle: DataSourceUpdateStyle = .withBatchUpdates,
                               completion: OptionalCompletionHandler) {
        
        register(sectionModels: items, supplementaryContainerItems: supplementaryItems ?? [])
        
        func updateWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                super.provider.updateSections(atItemSectionIndices: itemIndices,
                                              items: items,
                                              supplementaryItems: supplementaryItems ?? [],
                                              supplementarySectionIndices: supplementarySectionIndices ?? [])
                let indexSet = IndexSet(itemIndices)
                super.collectionView.reloadSections(indexSet)
            }, completion: completion)
        }
        
        func updateImmediately() {
            super.provider.updateSections(atItemSectionIndices: itemIndices,
                                          items: items,
                                          supplementaryItems: supplementaryItems ?? [],
                                          supplementarySectionIndices: supplementarySectionIndices ?? [])
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
    
    public func insertItems(at indexPaths: [IndexPath], values: [T], updateStyle: DataSourceUpdateStyle = .withBatchUpdates, completion: OptionalCompletionHandler) {
        
        register(models: values, supplementaryContainerItems: [])
        
        func insertWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                let indicesOfNewSectionsToInsert = super.provider.insertItems(at: indexPaths, values: values)
                super.collectionView.insertItems(at: indexPaths)
                if indicesOfNewSectionsToInsert.count > 0 {
                    let indexSet = IndexSet(integersIn: indicesOfNewSectionsToInsert.min()!...indicesOfNewSectionsToInsert.max()!)
                    super.collectionView.insertSections(indexSet)
                }
            }, completion: completion)
        }
        
        func insertImmediately() {
            super.provider.insertItems(at: indexPaths, values: values)
            super.collectionView.reloadData()
            super.collectionView.performBatchUpdates(nil, completion: completion)
        }
        
        
        if updateStyle == .withBatchUpdates {
            insertWithBatchUpdates()
        } else {
            insertImmediately()
        }
    }
    
    public func deleteItems(at indexPaths: [IndexPath], updateStyle: DataSourceUpdateStyle = .withBatchUpdates, completion: OptionalCompletionHandler) {
        // TODO
        // Consider the case where deleting items in a section
        // will render that section empty.
        // Should you also delete the entire section?
        func deleteWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                let indexSectionsToDelete = super.provider.deleteItems(at: indexPaths)
                super.collectionView.deleteItems(at: indexPaths)
                if indexSectionsToDelete.count > 0 {
                    super.provider.deleteSupplementaryContainerItems(at: indexSectionsToDelete)
                    let sectionsToDeleteAt = IndexSet(indexSectionsToDelete)
                    super.collectionView.deleteSections(sectionsToDeleteAt)
                }
            }, completion: completion)
        }
        
        func deleteImmediately() {
            let _ = super.provider.deleteItems(at: indexPaths)
            super.collectionView.reloadData()
            super.collectionView.performBatchUpdates(nil, completion: completion)
        }
        
        
        
        if updateStyle == .withBatchUpdates {
            deleteWithBatchUpdates()
        } else {
            deleteImmediately()
        }
    }
    
    public func updateSupplementaryContainerItems(at sections: [Int], supplementaryContainerItems: [S], updateStyle: DataSourceUpdateStyle = .withBatchUpdates, completion: OptionalCompletionHandler) {
        
        register(models: [], supplementaryContainerItems: supplementaryContainerItems)
        
        func updateWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                super.provider.updateSupplementaryItems(atSections: sections, withNewSupplementaryItems: supplementaryContainerItems)
                let indexSet = IndexSet(sections)
                super.collectionView.reloadSections(indexSet)
            }, completion: completion)
        }
        
        func updateImmediately() {
            super.provider.updateSupplementaryItems(atSections: sections, withNewSupplementaryItems: supplementaryContainerItems)
            super.collectionView.reloadData()
            super.collectionView.performBatchUpdates(nil, completion: completion)
        }
        
        if updateStyle == .withBatchUpdates {
            updateWithBatchUpdates()
        } else {
            updateImmediately()
        }
    }
    
    public func insertSupplementaryContainerItems(at sections: [Int], supplementaryContainerItems: [S], updateStyle: DataSourceUpdateStyle = .withBatchUpdates, completion: OptionalCompletionHandler) {
        
        register(models: [], supplementaryContainerItems: supplementaryContainerItems)
        
        func insertWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                super.provider.insertSupplementaryContainerItems(at: sections, supplementaryContainerItems: supplementaryContainerItems)
                super.collectionView.reloadSections(IndexSet(sections))
            }, completion: completion)
        }
        
        func insertImmediately() {
            super.provider.insertSupplementaryContainerItems(at: sections, supplementaryContainerItems: supplementaryContainerItems)
            super.collectionView.reloadData()
            super.collectionView.performBatchUpdates(nil, completion: completion)
        }
        
        if updateStyle == .withBatchUpdates {
            insertWithBatchUpdates()
        } else {
            insertImmediately()
        }
    }
    
    public func deleteSupplementaryContainerItems(at sections: [Int], updateStyle: DataSourceUpdateStyle = .withBatchUpdates, completion: OptionalCompletionHandler) {
        
        func deleteWithBatchUpdates() {
             super.collectionView.performBatchUpdates({
                super.provider.deleteSupplementaryContainerItems(at: sections)
                super.collectionView.reloadSections(IndexSet(sections))
             }, completion: completion)
        }
        
        func deleteImmediately() {
            super.provider.deleteSupplementaryContainerItems(at: sections)
            super.collectionView.reloadData()
            super.collectionView.performBatchUpdates(nil, completion: completion)
        }
        
        if updateStyle == .withBatchUpdates {
            deleteWithBatchUpdates()
        } else {
            deleteImmediately()
        }
    }
    
    public func replaceAllItems(with models: [[T]], supplementaryContainerItems: [S], updateStyle: DataSourceUpdateStyle = .withBatchUpdates, completion: OptionalCompletionHandler) {
        
        register(sectionModels: models, supplementaryContainerItems: supplementaryContainerItems)
        
        func replaceWithBatchUpdates() {
            super.collectionView.performBatchUpdates({
                super.provider.replaceAllItems(with: models, supplementaryContainerItems: supplementaryContainerItems)
                let sectionsToReload = Array(0..<models.count)
                super.collectionView.reloadSections(IndexSet(sectionsToReload))
            }, completion: completion)
        }
        
        func replaceImmediately() {
            super.provider.replaceAllItems(with: models, supplementaryContainerItems: supplementaryContainerItems)
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
