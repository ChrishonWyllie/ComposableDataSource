//
//  GenericCollectionViewCell.swift
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

open class GenericCollectionViewCell: UICollectionViewCell, GenericCollectionViewCellProtocol {
    public typealias T = GenericCellModel
    open func configure(with item: GenericCellModel, at indexPath: IndexPath) {}
    
    
    
    
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    public var containerView: UIView = {
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









// A Generic view that appears when a collectionView has
// an empty data source
// Use the emptyDataSourceView property on the dataSource

class GenericEmptyCollectionBackgroundView: UIView {
    
    // MARK: - UI Elements
    
    
    // MARK: - Initialiers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUIElements()
    }
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Functions
    
    open func setupUIElements() {}
}


// Generic version with a UILabel in center

class GenericTitleEmptyBackgroundView: GenericEmptyCollectionBackgroundView {
    
    // MARK: - UI Elements
    
    let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Friend Stories will appear here!"
        titleLabel.textColor = UIColor.lightGray
        titleLabel.textAlignment = .center
//        titleLabel.font = UIFont.classicFont.withSize(12)
        titleLabel.numberOfLines = 0
        return titleLabel
    }()
    
    override func setupUIElements() {
        addSubview(titleLabel)
        titleLabel.anchor(leading: leadingAnchor, top: nil, trailing: trailingAnchor, bottom: nil, centerX: nil, centerY: centerYAnchor)
    }
}
