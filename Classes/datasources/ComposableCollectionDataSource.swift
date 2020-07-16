//
//  ComposableCollectionDataSource.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import UIKit

// This class can handle multiple kinds of UICollectionViewCells

open class ComposableCollectionDataSource: SectionableCollectionDataSource<GenericCellModel, GenericCollectionViewCell, GenericSupplementaryContainerModel, GenericSupplementaryModel, GenericCollectionReusableView> {
    
    private var cellPadding: UIEdgeInsets = .zero
    private var cellCornerRadius: CGFloat = 0.0
    
    public init(collectionView: UICollectionView,
                array: [[GenericCellModel]],
                supplementaryItems: [GenericSupplementaryContainerModel],
                cellPadding: UIEdgeInsets = .zero,
                cellCornerRadius: CGFloat = 0.0) {
        
        super.init(collectionView: collectionView, array: array, supplementaryItems: supplementaryItems)
        
        self.cellPadding = cellPadding
        self.cellCornerRadius = cellCornerRadius
    }
    
    public init(collectionView: UICollectionView,
                dataProvider: DataSourceProvider<GenericCellModel, GenericSupplementaryContainerModel, GenericSupplementaryModel>,
                cellPadding: UIEdgeInsets = .zero,
                cellCornerRadius: CGFloat = 0.0) {
        
        super.init(collectionView: collectionView, dataProvider: dataProvider)
        
        self.cellPadding = cellPadding
        self.cellCornerRadius = cellCornerRadius
    }
    
    public var isEmpty: Bool {
        return super.provider.isEmpty
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
        
        guard let item = super.provider.item(at: indexPath) else {
            return UICollectionViewCell()
        }
        
        let cellType = type(of: item.cellClass)
        
        var cell: GenericCollectionViewCell?
        
        cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: cellType), for: indexPath) as? GenericCollectionViewCell
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
        
        guard let supplementaryContainerModel = super.supplementaryContainerItem(at: indexPath.section) else {
            print("Could not get supplementary item at index section: \(indexPath.section)")
            print("supplementary items: \(String(describing: super.provider.allSupplementaryItems().count))")
            print("supplementary items: \(String(describing: super.supplementaryContainerItem(at: indexPath.section)))")
            return UICollectionReusableView()
        }
        
        var supplementaryItem: GenericSupplementaryModel?
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            supplementaryItem = supplementaryContainerModel.header
        case UICollectionView.elementKindSectionFooter:
            supplementaryItem = supplementaryContainerModel.footer
        default: fatalError()
        }
        
        guard let item = supplementaryItem else {
            return UICollectionReusableView()
        }
        
        let viewType = type(of: item.supplementaryViewClass)
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: String(describing: viewType), for: indexPath) as? GenericCollectionReusableView
        print("generic supplementary item: \(item)")
        print("generic supplementary view type: \(viewType)")
        view?.configure(with: item, at: indexPath)
        
        if self.cellPadding != .zero {//&& self.cellCornerRadius > 0.0 {
            view?.setContentViewPadding(padding: cellPadding)
        }
        
        return view!
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        guard let supplementaryModel = provider.supplementaryContainerItem(at: section)?.header else {
            return .zero
        }
        return collectionHeaderItemSizeHandler?(section, supplementaryModel) ?? .zero
    }
    
    open override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let supplementaryModel = provider.supplementaryContainerItem(at: section)?.footer else {
            return .zero
        }
        return collectionFooterItemSizeHandler?(section, supplementaryModel) ?? .zero
    }
    
    // Since each collectionView/dataSource displays different cells,
    // The method of determing the IndexPath of a specific model will
    // vary.
    // e.g. id of a ProjectUser,
    // localIdentifier of a PHAsset
    // So by default, this implementation will also vary
    open func indexPath(for model: GenericCellModel) -> IndexPath? {
        fatalError("This needs to be subclassed to provide the proper comparison")
    }
    
    // Same for this function
    open func contains(model: GenericCellModel) -> Bool {
        fatalError("This needs to be subclassed to provide the proper comparison")
    }
    
    open func updateItemAndResortDataSource(indexPaths: [IndexPath], values: [GenericCellModel], completion: OptionalCompletionHandler) {
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
    
    public func insertItemsMaintainingPosition(items: [GenericCellModel], indexPaths: [IndexPath], completion: OptionalCompletionHandler) {
        
        let currentOffsetBeforeChanges = getCurrentOffset()
        print("maintain offset: \(currentOffsetBeforeChanges)")
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        CATransaction.setCompletionBlock {
            completion?(true)
        }
        
        super.register(models: items, supplementaryContainerItems: [])
        
        self.collectionView.performBatchUpdates({
            let indicesOfNewSectionsToInsert = super.provider.insertItems(at: indexPaths, values: items)
            super.collectionView.insertItems(at: indexPaths)
            if indicesOfNewSectionsToInsert.count > 0 {
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
        
        print("collectionView contentOffset before: \(collectionView.contentOffset)")
        print("collectionView contentSize before: \(collectionView.contentSize)")
        if scrollDirection == .vertical {
            // TODO
            // Confirm that this works
            let maintainedOffset = CGPoint(x: 0, y: collectionView.contentSize.height - offset)
            print("maintained offset: \(maintainedOffset)")
            collectionView.contentOffset = maintainedOffset
        } else {
            let xValue = collectionView.contentSize.width - collectionView.frame.size.width - offset
            collectionView.contentOffset = CGPoint(x: xValue, y: 0)
            print("collectionView contentOffset after: \(collectionView.contentOffset)")
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    @discardableResult open func handleSelection(_ completion: @escaping CollectionItemSelectionHandler<GenericCellModel>) -> ComposableCollectionDataSource {
        super.collectionItemSelectionHandler = completion
        return self
    }
       
    @discardableResult open func handleDeselection(_ completion: @escaping CollectionItemDeselectionHandler<GenericCellModel>) -> ComposableCollectionDataSource {
        super.collectionItemDeselectionHandler = completion
        return self
    }
    
    @discardableResult open func handleItemSize(_ completion: @escaping CollectionItemSizeHandler<GenericCellModel>) -> ComposableCollectionDataSource {
        super.collectionItemSizeHandler = completion
        return self
    }
    
    @discardableResult open func handleSupplementaryHeaderItemSize(_ completion: @escaping CollectionSupplementaryHeaderSizeHandler<GenericSupplementaryModel>) -> ComposableCollectionDataSource {
        super.collectionHeaderItemSizeHandler = completion
        return self
    }
    
    @discardableResult open func handleSupplementaryFooterItemSize(_ completion: @escaping CollectionSupplementaryFooterSizeHandler<GenericSupplementaryModel>) -> ComposableCollectionDataSource {
        super.collectionFooterItemSizeHandler = completion
        return self
    }
    
    @discardableResult open func handlRequestedPrefetching(_ completion: @escaping CollectionBeginPrefetchingHandler<GenericCellModel>) -> ComposableCollectionDataSource {
        super.collectionBeginPrefetchingHandler = completion
        return self
    }
    
    @discardableResult open func handleCanceledPrefetching(_ completion: @escaping CollectionCancelPrefetchingHandler<GenericCellModel>) -> ComposableCollectionDataSource {
        super.collectionCancelPrefetchingHandler = completion
        return self
    }
}
