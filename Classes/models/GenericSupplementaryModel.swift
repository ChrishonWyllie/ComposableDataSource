//
//  GenericSupplementaryModel.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import Foundation
import UIKit.UICollectionView

// This class is meant to be a superclass for the ViewModels
// Used with the CollectionArrayDataSource
// The purpose is to provide a way for the ViewModel to be aware
// of its expected supplementary view type
// similar to the GenericCellModel
// But this is to allow for generic supplementary views (header and footer)

public protocol GenericSupplementaryModel {
    var supplementaryViewClass: UICollectionReusableView.Type { get }
    var viewKind: String { get }
}




// This class contains a sort of tuple that contains
// header and footer generic supplementary models.
// Some dataSources only show headers, others only show footers,
// and some show both.
// The properties are optional


public protocol GenericSupplementarySectionModelProtocol {
    var header: GenericSupplementaryModel? { get }
    var footer: GenericSupplementaryModel? { get }
}

public struct GenericSupplementarySectionModel: GenericSupplementarySectionModelProtocol {
    public private(set) var header: GenericSupplementaryModel?
    public private(set) var footer: GenericSupplementaryModel?
    
    public init(header: GenericSupplementaryModel?, footer: GenericSupplementaryModel?) {
        if header != nil {
            guard header?.viewKind == UICollectionView.elementKindSectionHeader else { fatalError("You placed the wrong supplementary model in this parameter") }
        }
        if footer != nil {
            guard footer?.viewKind == UICollectionView.elementKindSectionFooter else { fatalError("You placed the wrong supplementary model in this parameter") }
        }
        self.header = header
        self.footer = footer
    }
}














public typealias AnyComposableCollectionReusableViewClass = BaseComposableCollectionReusableView.Type

public protocol BaseComposableSupplementaryViewModel: GenericSupplementaryModel {
    func getReusableViewClass() -> AnyComposableCollectionReusableViewClass
}

extension BaseComposableSupplementaryViewModel {
    public var supplementaryViewClass: UICollectionReusableView.Type {
        return getReusableViewClass()
    }
}
