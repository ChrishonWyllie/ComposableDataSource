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

public protocol CollectionDataProvider {
    
    associatedtype T // cell model
    associatedtype S // supplementary container
    associatedtype U // individual header/footer model
    
//    var items: [[T]] { get }
//    var supplementaryContainerItems: [S] { get }
    
    var isEmpty: Bool { get }
    
    func allItems() -> [[T]]
    func allSupplementaryItems() -> [S]
    func numberOfSections() -> Int
    func numberOfItems(in section: Int) -> Int
    
    // Create
    
    func append(items: [T], inNestedSection section: Int, atIndex index: Int?)
    func append(contentsOf collection: [T])
    func append(supplementaryItem: S)
    /// If a new section needs to be inserted (i.e., the [indexPaths] argument contains sections greater than items.count)
    /// this will return an array of those new section indices
    @discardableResult func insertItems(at indexPaths: [IndexPath], values: [T]) -> [Int]
    func insert(items: [T], inNestedSection section: Int, atIndex index: Int?)
    func insert(contentsOf collection: [T], atIndex index: Int)
    func insert(supplementaryItem: S, atIndex index: Int)
    func insertSupplementaryContainerItems(at sections: [Int], supplementaryContainerItems: [S])
    
    
    // Read
    
    func item(at indexPath: IndexPath) -> T?
    func items(at indexPaths: [IndexPath]) -> [T]?
    func supplementaryContainerItem(at designatedSection: Int) -> S?
    
    // Update
    
    func updateItem(at indexPath: IndexPath, withNewItem item: T)
    func updateItems(atSections sections: [Int], withNewItems items: [[T]])
    func updateItems(at indexPaths: [IndexPath], values: [T])
    func updateSupplementaryItems(atSections sections: [Int], withNewSupplementaryItems supplementaryItems: [S])
    func updateSections(atItemSectionIndices itemSections: [Int], items: [[T]], supplementaryItems: [S], supplementarySectionIndices: [Int])
    
    // Delete
    
    /// If an entire section needs to be removed (i.e., the section is empty after subsequent item deletions)
    /// this will return an array of those section indices
    @discardableResult func deleteItems(at indexPaths: [IndexPath]) -> [Int]
    func deleteSupplementaryContainerItems(at designatedSections: [Int])
    
    
    
    
    func reset(keepingStructure: Bool)
    func replaceAllItems(with models: [[T]], supplementaryContainerItems: [S])
}















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
