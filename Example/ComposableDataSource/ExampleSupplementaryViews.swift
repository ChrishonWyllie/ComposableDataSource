//
//  ExampleSupplementaryViews.swift
//  ComposableDataSource_Example
//
//  Created by Chrishon Wyllie on 7/16/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import ComposableDataSource

class ExampleSupplementaryHeaderView: BaseComposableCollectionReusableView {
    
    override func configure(with item: BaseCollectionSupplementaryViewModel, at indexPath: IndexPath) {
        guard let item = item as? SupplementaryItemModel else { fatalError() }
        titleLabel.text = item.title
    }

    
    fileprivate var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        lbl.font = UIFont.boldSystemFont(ofSize: 28)
        lbl.textAlignment = .center
        lbl.textColor = .red
        return lbl
    }()
    
    
    
    
    override func setupUIElements() {
        super.setupUIElements()
        
        [titleLabel].forEach { (subview) in
            super.containerView.addSubview(subview)
        }
        
        if #available(iOS 13.0, *) {
            super.containerView.backgroundColor = UIColor.systemGroupedBackground
        } else {
            // Fallback on earlier versions
            super.containerView.backgroundColor = UIColor.groupTableViewBackground
        }
        
        // Handle layout...
        
        let padding: CGFloat = 12.0
        
        titleLabel.leadingAnchor.constraint(equalTo: super.containerView.leadingAnchor, constant: padding).isActive = true
        titleLabel.topAnchor.constraint(equalTo: super.containerView.topAnchor, constant: padding).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: super.containerView.trailingAnchor, constant: -padding).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: super.containerView.bottomAnchor, constant: -padding).isActive = true
        
    }
}
