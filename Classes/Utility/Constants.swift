//
//  Constants.swift
//  ComposableDataSource
//
//  Created by Chrishon Wyllie on 7/8/20.
//

import Foundation

internal struct Constants {
    private init() {}
    
    struct ReuseIdentifiers {
        private init() {}
        static let defaultHeaderReuseIdentifier = "headerViewIdentifier"
        static let defaultFooterReuseIdentifier = "footerViewIdentifier"
    }
}
