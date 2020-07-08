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
    var supplementaryViewClass: AnyClass { get }
    var viewKind: String { get }
}




// This class contains a sort of tuple that contains
// header and footer generic supplementary models.
// Some dataSources only show headers, others only show footers,
// and some show both.
// The properties are optional

// TODO
// This protocol is somewhat unnecessary since the GenericSupplementaryHeaderFooterModel
// is the only model that implements it

public protocol SupplementaryContainer {
    associatedtype H
    associatedtype F
}

public protocol GenericSupplementaryContainerModel: SupplementaryContainer {
    var header: H? { get }
    var footer: F? { get }
    var designatedSection: Int { get }
}

struct GenericSupplementaryHeaderFooterModel: GenericSupplementaryContainerModel {
    typealias H = GenericSupplementaryModel
    
    typealias F = GenericSupplementaryModel
    
    public private(set) var header: H?
    public private(set) var footer: F?
    public private(set) var designatedSection: Int
    
    init(header: H?, footer: F?, designatedSection: Int) {
        if header != nil {
            guard header?.viewKind == UICollectionElementKindSectionHeader else { fatalError("You placed the wrong supplementary model in this parameter") }
        }
        if footer != nil {
            guard footer?.viewKind == UICollectionElementKindSectionFooter else { fatalError("You placed the wrong supplementary model in this parameter") }
        }
        self.header = header
        self.footer = footer
        self.designatedSection = designatedSection
    }
}
