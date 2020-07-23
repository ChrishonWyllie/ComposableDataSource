//
//  Models.swift
//  ComposableDataSource_Example
//
//  Created by Chrishon Wyllie on 7/17/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import ComposableDataSource

protocol URLCellModel {
    var urlString: String { get }
}

protocol SupplementaryItemModel {
    var title: String { get }
}

struct HeaderItemModel: BaseComposableSupplementaryViewModel, SupplementaryItemModel {
    var viewKind: String {
        return UICollectionView.elementKindSectionHeader
    }
    
    func getReusableViewClass() -> AnyComposableCollectionReusableViewClass {
        return ExampleSupplementaryHeaderView.self
    }
    let title: String
}

struct VideoCellModel: BaseCollectionCellModel, URLCellModel {
    func getCellClass() -> AnyComposableCellClass {
        return VideoCell.self
    }
    let urlString: String
}

struct ImageCellModel: BaseCollectionCellModel, URLCellModel {
    func getCellClass() -> AnyComposableCellClass {
        return ImageCell.self
    }
    let urlString: String
}
