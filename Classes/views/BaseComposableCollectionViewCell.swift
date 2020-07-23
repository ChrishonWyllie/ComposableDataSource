//
//  BaseComposableCollectionViewCell.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import UIKit

// This class is the superclass for other UICollectionViewCells
// Just cast the `item` to the necessary ViewModel
protocol GenericCollectionViewCellProtocol: ConfigurableReusableCell {
    var containerView: UIView { get set }
    func setContentViewPadding(padding: UIEdgeInsets)
    func setupUIElements()
}

@IBDesignable open class BaseComposableCollectionViewCell: UICollectionViewCell, GenericCollectionViewCellProtocol {
    public typealias T = BaseCollectionCellModel
    open func configure(with item: BaseCollectionCellModel, at indexPath: IndexPath) {}
    
    
    
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    @IBInspectable public var containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    public func setContentViewPadding(padding: UIEdgeInsets) {
        containerView.removeAllConstraints()
        containerView.anchor(leading:     contentView.leadingAnchor,
                             top:         contentView.topAnchor,
                             trailing:    contentView.trailingAnchor,
                             bottom:      contentView.bottomAnchor,
                             centerX:     nil,
                             centerY:     nil,
                             padding:     padding,
                             size:        .zero)
    }
    
    open func setupUIElements() {
        contentView.addSubview(containerView)
        containerView.anchor(to: contentView)
    }
    
}
