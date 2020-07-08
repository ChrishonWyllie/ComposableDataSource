//
//  CollectionDataSource.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import UIKit

public typealias CollectionItemSelectionHandlerType<T> = (IndexPath, T?) -> Void
public typealias CollectionItemDeselectionHandlerType<T> = (IndexPath, T?) -> Void
public typealias CollectionContentOffset = (CGPoint) -> Void
public typealias CollectionScrollViewWillBeginDragging = (UIScrollView) -> Void
public typealias CollectionScrollViewDidEndScrollAnimation = (UIScrollView) -> Void
public typealias CollectionScrollViewDidEndDecelerating = (UIScrollView) -> Void
public typealias CollectionScrollViewWillEndDragging = (UIScrollView, CGPoint, UnsafeMutablePointer<CGPoint>) -> Void
public typealias CollectionScrollViewDidEndDragging = (UIScrollView, Bool) -> Void

open class CollectionDataSource
    <Provider: CollectionDataProvider,
    Cell: UICollectionViewCell,
    Supplementary: SupplementaryContainer>:
    NSObject,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout
where Cell: ConfigurableReusableCell,
Supplementary.H: GenericSupplementaryModel,
Supplementary.F: GenericSupplementaryModel,
Provider.T == Cell.T,
Provider.S == Supplementary {
    
    // MARK: - Variables
    
    // TODO
    // Make provider private. collectionView private(set)
    let provider: Provider
    public private(set) var collectionView: UICollectionView
    var emptyDataSourceView: UIView?
    public var collectionItemSelectionHandler: CollectionItemSelectionHandlerType<Provider.T>?
    public var collectionItemDeselectionHandler: CollectionItemDeselectionHandlerType<Provider.T>?
    public var collectionContentOffsetHandler: CollectionContentOffset?
    public var scrollViewWillBeginDraggingHandler: CollectionScrollViewWillBeginDragging?
    public var scrollViewDidEndScrollAnimationHandler: CollectionScrollViewDidEndScrollAnimation?
    public var scrollViewDidEndDeceleratingHandler: CollectionScrollViewDidEndDecelerating?
    public var scrollViewWillEndDraggingHandler: CollectionScrollViewWillEndDragging?
    public var scrollViewDidEndDraggingHandler: CollectionScrollViewDidEndDragging?
    
    

    // MARK: - Initialiers
    
    public init(collectionView: UICollectionView, provider: Provider) {
        self.collectionView = collectionView
        self.provider = provider
        super.init()
        setup()
    }
    
    private func setup() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        collectionView.register(UICollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionHeader,
                                withReuseIdentifier: Constants.ReuseIdentifiers.defaultHeaderReuseIdentifier)
        collectionView.register(UICollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionElementKindSectionFooter,
                                withReuseIdentifier: Constants.ReuseIdentifiers.defaultFooterReuseIdentifier)
    }
    
    
    
    // NOTE
    // "open" declaration is so that these functions can
    // be subclassed
    
    
    
    
    // MARK: - UICollectionView datasource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return provider.numberOfSections()
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if provider.numberOfItems(in: section) > 0 {
            collectionView.backgroundView = nil
            return provider.numberOfItems(in: section)
        } else {
            collectionView.backgroundView = emptyDataSourceView
            return 0
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier,
                                                            for: indexPath) as? Cell else {
                                                                return UICollectionViewCell()
        }
        let item = provider.item(at: indexPath)
        if let item = item {
            cell.configure(with: item, at: indexPath)
        }
        return cell
    }

    
    
    
    // MARK: - UICollectionView delegate
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = provider.item(at: indexPath)
        // This is called "binding"
        // Here's another link on the subject
        // https://www.raywenderlich.com/667-bond-tutorial-bindings-in-swift
        // https://stackoverflow.com/questions/50039663/uicollectionviewcell-talking-to-its-uicollectionviewcontroller
        collectionItemSelectionHandler?(indexPath, item)
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let item = provider.item(at: indexPath)
        collectionItemDeselectionHandler?(indexPath, item)
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             willDisplay cell: UICollectionViewCell,
                             forItemAt indexPath: IndexPath) {
        
    }
    
    
    
    
    // MARK: - UICollectionDelegateFlowLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 50, height: 50)
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             willDisplaySupplementaryView view: UICollectionReusableView,
                             forElementKind elementKind: String, at indexPath: IndexPath) {
        
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             viewForSupplementaryElementOfKind kind: String,
                             at indexPath: IndexPath) -> UICollectionReusableView
    {
        if kind == UICollectionElementKindSectionHeader {
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader,
                                                                   withReuseIdentifier: Constants.ReuseIdentifiers.defaultHeaderReuseIdentifier,
                                                                   for: indexPath)
        } else {
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter,
                                                                   withReuseIdentifier: Constants.ReuseIdentifiers.defaultFooterReuseIdentifier,
                                                                   for: indexPath)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .zero
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return .zero
    }
    
    
    
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .zero
    }
    
    
    
    
    
    // MARK: - UIScrollView delegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        collectionContentOffsetHandler?(scrollView.contentOffset)
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        scrollViewWillBeginDraggingHandler?(scrollView)
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        scrollViewWillEndDraggingHandler?(scrollView, velocity, targetContentOffset)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewDidEndDraggingHandler?(scrollView, decelerate)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        scrollViewDidEndScrollAnimationHandler?(scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        scrollViewDidEndDeceleratingHandler?(scrollView)
    }
}
