//
//  GenericCellModel.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import Foundation

// This class is meant to be a superclass for the ViewModels
// Used with the CollectionArrayDataSource
// The purpose is to provide a way for the ViewModel to be aware
// of its expected cell type
// Therefore, the ArrayDataProvider can provide the correct cell
// and allow for Multiple cell types

public protocol GenericCellModel {
    var cellClass: UICollectionViewCell.Type { get }
}

public typealias AnyComposableCellClass = BaseComposableCollectionViewCell.Type

public protocol BaseCollectionCellModel: GenericCellModel {
    func getCellClass() -> AnyComposableCellClass
}

extension BaseCollectionCellModel {
    public var cellClass: UICollectionViewCell.Type {
        return getCellClass()
    }
}
