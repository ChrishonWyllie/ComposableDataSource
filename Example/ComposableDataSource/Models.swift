//
//  Models.swift
//  ComposableDataSource_Example
//
//  Created by Chrishon Wyllie on 7/17/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation

protocol URLCellModel {
    var urlString: String { get }
}

protocol SupplementaryItemModel {
    var title: String { get }
}

struct HeaderItemModel: GenericSupplementaryModel, SupplementaryItemModel {
    var viewKind: String {
        return UICollectionView.elementKindSectionHeader
    }
    
    var supplementaryViewClass: AnyClass {
        return ExampleSupplementaryHeaderView.self
    }
    let title: String
}

struct VideoCellModel: GenericCellModel, URLCellModel {
    var cellClass: AnyClass {
        return VideoCell.self
    }
    let urlString: String
}

struct ImageCellModel: GenericCellModel, URLCellModel {
    var cellClass: AnyClass {
        return ImageCell.self
    }
    let urlString: String
}
