//
//  GenericCollectionReusableView.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import UIKit

// This class is the superclass for other UICollectionReusableViews
// Just cast the `item` to the necessary ViewModel
public protocol GenericCollectionReusableViewProtocol: ConfigurableReusableSupplementaryView {
    var containerView: UIView { get set }
    func setContentViewPadding(padding: UIEdgeInsets)
    func setupUIElements()
}
open class GenericCollectionReusableView: UICollectionReusableView, GenericCollectionReusableViewProtocol {
    public typealias T = GenericSupplementaryModel
    open func configure(with item: GenericSupplementaryModel, at indexPath: IndexPath) {}
    
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    public var containerView: UIView = {
        let v = UIView()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    public func setContentViewPadding(padding: UIEdgeInsets) {
        containerView.removeAllConstraints()
        containerView.anchor(leading:     leadingAnchor,
                             top:         topAnchor,
                             trailing:    trailingAnchor,
                             bottom:      bottomAnchor,
                             centerX:     nil,
                             centerY:     nil,
                             padding:     padding,
                             size:        .zero)
    }
    
    open func setupUIElements() {
        addSubview(containerView)
        containerView.anchor(to: self)
    }
}
