//
//  ComposableCollectionDataSource.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import UIKit

// This class can handle multiple kinds of UICollectionViewCells

open class ComposableCollectionDataSource: SectionableDataSourceInheriableProtocol, ComposableDataSourceActionHandlerProtocol {
    
    // MARK: - Variables
    
    public static var debugModeIsActive: Bool = false
    
    private var cellPadding: UIEdgeInsets = .zero
    private var cellCornerRadius: CGFloat = 0.0
    
    public var isEmpty: Bool {
        return super.provider.isEmpty
    }
    
    
    
    
    // MARK: - Initializers
    
    public init(collectionView: UICollectionView,
                cellItems: [[BaseCollectionCellModel]],
                supplementarySectionItems: [BaseSupplementarySectionModel],
                cellPadding: UIEdgeInsets = .zero,
                cellCornerRadius: CGFloat = 0.0) {
        
        super.init(collectionView: collectionView, cellItems: cellItems, supplementarySectionItems: supplementarySectionItems)
        
        self.cellPadding = cellPadding
        self.cellCornerRadius = cellCornerRadius
    }
    
    public init(collectionView: UICollectionView,
                dataProvider: DataSourceProvider<BaseCollectionCellModel, BaseSupplementarySectionModel, BaseCollectionSupplementaryViewModel>,
                cellPadding: UIEdgeInsets = .zero,
                cellCornerRadius: CGFloat = 0.0) {
        
        super.init(collectionView: collectionView, dataProvider: dataProvider)
        
        self.cellPadding = cellPadding
        self.cellCornerRadius = cellCornerRadius
    }
    
    
    
    private func getRoundedRectCorners(for indexPath: IndexPath) -> UIRectCorner {
        var corners: UIRectCorner = []
        
        switch indexPath.item {
        case 0:
            corners = [.topLeft, .topRight]
        case super.indexPathOfLastItem(in: indexPath.section).item:
            corners = [.bottomLeft, .bottomRight]
        default: break
        }
        return corners
    }
    
    
    
    // Since each collectionView/dataSource displays different cells,
    // The method of determing the IndexPath of a specific model will
    // vary.
    // e.g. id of a ProjectUser,
    // localIdentifier of a PHAsset
    // So by default, this implementation will also vary
    open func indexPath(for model: BaseCollectionCellModel) -> IndexPath? {
        fatalError("This needs to be subclassed to provide the proper comparison")
    }
    
    // Same for this function
    open func contains(model: BaseCollectionCellModel) -> Bool {
        fatalError("This needs to be subclassed to provide the proper comparison")
    }
    
    open func updateItemAndResortDataSource(indexPaths: [IndexPath], values: [BaseCollectionCellModel], completion: OptionalCompletionHandler) {
        fatalError("This needs to be subclassed to provide the proper comparison")
    }
    
    public func manuallyTriggerSelection(atIndexPath indexPath: IndexPath) {
        super.collectionView.delegate?.collectionView?(super.collectionView, didSelectItemAt: indexPath)
    }
    
    public func getCurrentOffset() -> CGFloat {
        
        guard
            let scrollDirection = (super.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection
            else {
                fatalError()
        }
        
        switch scrollDirection {
        case .vertical:
            let contentHeight = super.collectionView.contentSize.height
            let offsetY = super.collectionView.contentOffset.y
            let bottomOffset = contentHeight - offsetY
            return bottomOffset
            
        default:
            
            let contentWidth = super.collectionView.contentSize.width
            let offsetX = super.collectionView.contentOffset.x
            let rightOffset = contentWidth - offsetX
            return rightOffset
        }
    }
    
    public func insertItemsMaintainingPosition(cellItems: [BaseCollectionCellModel], indexPaths: [IndexPath], completion: OptionalCompletionHandler) {
        
        let currentOffsetBeforeChanges = getCurrentOffset()
        DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - maintain offset: \(currentOffsetBeforeChanges)")
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock {
            completion?(true)
        }
        
        super.register(cellItems: cellItems, supplementarySectionItems: [])
        
        self.collectionView.performBatchUpdates({
            let indicesOfNewSectionsToInsert = super.provider.insert(cellItems: cellItems, atIndexPaths: indexPaths)
            super.collectionView.insertItems(at: indexPaths)
            if indicesOfNewSectionsToInsert.isEmpty == false {
                let indexSet = IndexSet(integersIn: indicesOfNewSectionsToInsert.min()!...indicesOfNewSectionsToInsert.max()!)
                super.collectionView.insertSections(indexSet)
            }
        }, completion: { [weak self] (finished) in
            guard let confirmedSelf = self else { fatalError() }
            confirmedSelf.maintainOffsetAfterBatchUpdates(offset: currentOffsetBeforeChanges)
            CATransaction.commit()
        })
    }
    
    public func maintainOffsetAfterBatchUpdates(offset: CGFloat) {
        
        guard
            let scrollDirection = (super.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.scrollDirection
            else {
                fatalError()
        }
        
        DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - collectionView contentOffset before: \(collectionView.contentOffset)")
        DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - collectionView contentSize before: \(collectionView.contentSize)")
        if scrollDirection == .vertical {
            // TODO
            // Confirm that this works
            let maintainedOffset = CGPoint(x: 0, y: collectionView.contentSize.height - offset)
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - maintained offset: \(maintainedOffset)")
            collectionView.contentOffset = maintainedOffset
        } else {
            let xValue = collectionView.contentSize.width - collectionView.frame.size.width - offset
            collectionView.contentOffset = CGPoint(x: xValue, y: 0)
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - collectionView contentOffset after: \(collectionView.contentOffset)")
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    // MARK: - Builder functions
    
    @discardableResult open func didSelectItem(_ completion: @escaping ComposableItemSelectionHandler<BaseCollectionCellModel>) -> ComposableCollectionDataSource {
        super.composableItemSelectionHandler = completion
        return self
    }
       
    @discardableResult open func didDeselectItem(_ completion: @escaping ComposableItemDeselectionHandler<BaseCollectionCellModel>) -> ComposableCollectionDataSource {
        super.composableItemDeselectionHandler = completion
        return self
    }
    
    @discardableResult open func sizeForItem(_ completion: @escaping ComposableItemSizeHandler<BaseCollectionCellModel>) -> ComposableCollectionDataSource {
        super.composableItemSizeHandler = completion
        return self
    }
    
    @discardableResult open func referenceSizeForHeader(_ completion: @escaping ComposableSupplementaryHeaderSizeHandler<BaseCollectionSupplementaryViewModel>) -> ComposableCollectionDataSource {
        super.composableHeaderItemSizeHandler = completion
        return self
    }
    
    @discardableResult open func referenceSizeForFooter(_ completion: @escaping ComposableSupplementaryFooterSizeHandler<BaseCollectionSupplementaryViewModel>) -> ComposableCollectionDataSource {
        super.composableFooterItemSizeHandler = completion
        return self
    }
    
    @discardableResult open func prefetchItems(_ completion: @escaping ComposableBeginPrefetchingHandler<BaseCollectionCellModel>) -> ComposableCollectionDataSource {
        super.composableBeginPrefetchingHandler = completion
        return self
    }
    
    @discardableResult open func cancelPrefetchingForItems(_ completion: @escaping ComposableCancelPrefetchingHandler<BaseCollectionCellModel>) -> ComposableCollectionDataSource {
        super.composableCancelPrefetchingHandler = completion
        return self
    }
    
    @discardableResult open func observeContentOffset(_ completion: @escaping ComposableContentOffsetHandler) -> ComposableCollectionDataSource {
        super.composableContentOffsetHandler = completion
        return self
    }
    
    @discardableResult open func observeScrollViewWillBeginDragging(_ completion: @escaping ComposableScrollViewWillBeginDraggingHandler) -> ComposableCollectionDataSource {
        super.composableScrollViewWillBeginDraggingHandler = completion
        return self
    }
    
    @discardableResult open func observeScrollViewWillEndDragging(_ completion: @escaping ComposableScrollViewWillEndDraggingHandler) -> ComposableCollectionDataSource {
        super.composableScrollViewWillEndDraggingHandler = completion
        return self
    }
    
    @discardableResult open func observeScrollViewDidEndDragging(_ completion: @escaping ComposableScrollViewDidEndDraggingHandler) -> ComposableCollectionDataSource {
        super.composableScrollViewDidEndDraggingHandler = completion
        return self
    }
    
    @discardableResult open func observeScrollViewDidEndScrollAnimation(_ completion: @escaping ComposableScrollViewDidEndScrollAnimationHandler) -> ComposableCollectionDataSource {
        super.composableScrollViewDidEndScrollAnimationHandler = completion
        return self
    }
    
    @discardableResult open func observeScrollViewDidEndDecelerating(_ completion: @escaping ComposableScrollViewDidEndDeceleratingHandler) -> ComposableCollectionDataSource {
        super.composableScrollViewDidEndDeceleratingHandler = completion
        return self
    }
    
    
    
    
    
    
    
    
    // MARK: - Overriden functions
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if self.cellPadding != .zero && self.cellCornerRadius > 0.0 {
            let corners: UIRectCorner = getRoundedRectCorners(for: indexPath)
            cell.roundCellCorners(with: cellPadding,
                                  corners: corners,
                                  cornerRadius: cellCornerRadius,
                                  forItemAt: indexPath,
                                  in: collectionView)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let item = super.provider.item(atIndexPath: indexPath) else {
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Internal inconsistency. No cell model for indexPath: \(indexPath)")
            return UICollectionViewCell()
        }
        
        let cellIdentifier = String(describing: item.getCellClass())
        
        var cell: BaseComposableCollectionViewCell?
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: cellIdentifier), for: indexPath) as? BaseComposableCollectionViewCell
        cell?.configure(with: item, at: indexPath)
        
        if self.cellPadding != .zero {
            cell?.setContentViewPadding(padding: cellPadding)
        }
        
        return cell!
    }
    
    open override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        if self.cellPadding != .zero && self.cellCornerRadius > 0.0 {
            view.roundCorners(with: cellPadding, corners: [.allCorners], cornerRadius: cellCornerRadius)
        }
    }
    
    open override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let supplementarySectionItem = super.supplementarySectionItem(atSection: indexPath.section) else {
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - Could not get supplementary item at index section: \(indexPath.section)")
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - supplementary items: \(String(describing: super.provider.allSupplementarySectionItems().count))")
            DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - supplementary items: \(String(describing: super.supplementarySectionItem(atSection: indexPath.section)))")
            return UICollectionReusableView()
        }
        
        var supplementaryItem: GenericSupplementaryModel?
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            supplementaryItem = supplementarySectionItem.header
        case UICollectionView.elementKindSectionFooter:
            supplementaryItem = supplementarySectionItem.footer
        default: fatalError()
        }
        
        guard let item = supplementaryItem as? BaseCollectionSupplementaryViewModel else {
            return UICollectionReusableView()
        }
        
        let viewIdentifier = String(describing: item.getReusableViewClass())
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: viewIdentifier), for: indexPath) as? BaseComposableCollectionReusableView
        DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - generic supplementary item: \(item)")
        DebugLogger.shared.addDebugMessage("\(String(describing: type(of: self))) - generic supplementary view type: \(viewIdentifier)")
        view?.configure(with: item, at: indexPath)
        
        if self.cellPadding != .zero {
            view?.setContentViewPadding(padding: cellPadding)
        }
        
        return view!
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        guard let supplementarySectionItem = provider.supplementarySectionItem(atSection: section)?.header as? BaseCollectionSupplementaryViewModel else {
            return .zero
        }
        return composableHeaderItemSizeHandler?(section, supplementarySectionItem) ?? .zero
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let supplementarySectionItem = provider.supplementarySectionItem(atSection: section)?.footer as? BaseCollectionSupplementaryViewModel else {
            return .zero
        }
        return composableFooterItemSizeHandler?(section, supplementarySectionItem) ?? .zero
    }
}
