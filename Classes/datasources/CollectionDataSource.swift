//
//  CollectionDataSource.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import UIKit

/**
 Object for encapsulating UICollectionView delegate, datasource, delegateFlowLayout and datasourcePrefetching
 
 */
open class CollectionDataSource<Provider: CollectionDataProvider, Cell: UICollectionViewCell, View: UICollectionReusableView>:
    NSObject,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSourcePrefetching
where Cell: ConfigurableReusableCell, Provider.T == Cell.T {
    
    // MARK: - Variables
    
    internal let provider: Provider
    public private(set) var collectionView: UICollectionView
    public var emptyDataSourceView: UIView?
    
    internal var composableItemSelectionHandler: ComposableItemSelectionHandler<Provider.T>?
    internal var composableItemDeselectionHandler: ComposableItemDeselectionHandler<Provider.T>?
    internal var composableItemSizeHandler: ComposableItemSizeHandler<Provider.T>?
    internal var composableHeaderItemSizeHandler: ComposableSupplementaryHeaderSizeHandler<Provider.U>?
    internal var composableFooterItemSizeHandler: ComposableSupplementaryFooterSizeHandler<Provider.U>?
    internal var composableBeginPrefetchingHandler: ComposableBeginPrefetchingHandler<Provider.T>?
    internal var composableCancelPrefetchingHandler: ComposableCancelPrefetchingHandler<Provider.T>?
    
    internal var composableContentOffsetHandler: ComposableContentOffsetHandler?
    internal var composableScrollViewWillBeginDraggingHandler: ComposableScrollViewWillBeginDraggingHandler?
    internal var composableScrollViewDidEndScrollAnimationHandler: ComposableScrollViewDidEndScrollAnimationHandler?
    internal var composableScrollViewDidEndDeceleratingHandler: ComposableScrollViewDidEndDeceleratingHandler?
    internal var composableScrollViewWillEndDraggingHandler: ComposableScrollViewWillEndDraggingHandler?
    internal var composableScrollViewDidEndDraggingHandler: ComposableScrollViewDidEndDraggingHandler?
    
    

    // MARK: - Initialiers
    
    internal init(collectionView: UICollectionView, provider: Provider) {
        self.collectionView = collectionView
        self.provider = provider
        super.init()
        setDelegatesAndRegisterViews()
    }
    
    private func setDelegatesAndRegisterViews() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
        collectionView.register(UICollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: Constants.ReuseIdentifiers.defaultHeaderReuseIdentifier)
        collectionView.register(UICollectionReusableView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                withReuseIdentifier: Constants.ReuseIdentifiers.defaultFooterReuseIdentifier)
    }
    
    
    
    
    
    
    
    
    // MARK: - UICollectionView datasource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return provider.numberOfSections()
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
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
        
        if let item = provider.item(atIndexPath: indexPath) {
            cell.configure(with: item, at: indexPath)
        }
        return cell
    }

    
    
    
    // MARK: - UICollectionView delegate
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = provider.item(atIndexPath: indexPath) else {
            return
        }
        // This is called "binding"
        // Here's another link on the subject
        // https://www.raywenderlich.com/667-bond-tutorial-bindings-in-swift
        // https://stackoverflow.com/questions/50039663/uicollectionviewcell-talking-to-its-uicollectionviewcontroller
        composableItemSelectionHandler?(indexPath, item)
    }
    
    open func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let item = provider.item(atIndexPath: indexPath) else {
            return
        }
        composableItemDeselectionHandler?(indexPath, item)
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             willDisplay cell: UICollectionViewCell,
                             forItemAt indexPath: IndexPath) {
        
    }
    
    
    
    
    // MARK: - UICollectionDelegateFlowLayout
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let item = provider.item(atIndexPath: indexPath) else {
            return .zero
        }
        
        return composableItemSizeHandler?(indexPath, item) ?? .init(width: 50, height: 50)
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             willDisplaySupplementaryView view: UICollectionReusableView,
                             forElementKind elementKind: String, at indexPath: IndexPath) {
        
    }
    
    open func collectionView(_ collectionView: UICollectionView,
                             viewForSupplementaryElementOfKind kind: String,
                             at indexPath: IndexPath) -> UICollectionReusableView
    {
        if kind == UICollectionView.elementKindSectionHeader {
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                   withReuseIdentifier: Constants.ReuseIdentifiers.defaultHeaderReuseIdentifier,
                                                                   for: indexPath)
        } else {
            return collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter,
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
    
    
    
    
    
    
    
    
    // MARK: - UICollectionViewDataSourcePrefetching
    
    open func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let items = provider.items(atIndexPaths: indexPaths) else {
            return
        }
        composableBeginPrefetchingHandler?(indexPaths, items)
    }
    
    open func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        guard let items = provider.items(atIndexPaths: indexPaths) else {
            return
        }
        composableCancelPrefetchingHandler?(indexPaths, items)
    }
    
    
    
    
    
    // MARK: - UIScrollView delegate
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        composableContentOffsetHandler?(scrollView.contentOffset)
    }
    
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        composableScrollViewWillBeginDraggingHandler?(scrollView)
    }
    
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        composableScrollViewWillEndDraggingHandler?(scrollView, velocity, targetContentOffset)
    }
    
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        composableScrollViewDidEndDraggingHandler?(scrollView, decelerate)
    }
    
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        composableScrollViewDidEndScrollAnimationHandler?(scrollView)
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        composableScrollViewDidEndDeceleratingHandler?(scrollView)
    }
}
