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

protocol GenericCellModel {
    var cellClass: AnyClass { get }
}
