# ComposableDataSource

[![CI Status](https://img.shields.io/travis/ChrishonWyllie/ComposableDataSource.svg?style=flat)](https://travis-ci.org/ChrishonWyllie/ComposableDataSource)
[![Version](https://img.shields.io/cocoapods/v/ComposableDataSource.svg?style=flat)](https://cocoapods.org/pods/ComposableDataSource)
[![License](https://img.shields.io/cocoapods/l/ComposableDataSource.svg?style=flat)](https://cocoapods.org/pods/ComposableDataSource)
[![Platform](https://img.shields.io/cocoapods/p/ComposableDataSource.svg?style=flat)](https://cocoapods.org/pods/ComposableDataSource)

ComposableDataSource wraps the typically verbose UICollectionView data source and delegate implementation into a more neatly packed builder pattern

```swift

private func setupDataSource() -> ComposableCollectionDataSource {
        
    let models: [[GenericCellModel]] = [[]]
    let supplementaryModels: [GenericSupplementarySectionModel] = []
    
    let dataSource = ComposableCollectionDataSource(collectionView: collectionView,
                                                    cellItems: models,
                                                    supplementarySectionItems: supplementaryModels)
    .handleSelection { (indexPath: IndexPath, model: GenericCellModel) in
        // Handle selection at indexPath
    }.handleItemSize { (indexPath: IndexPath, model: GenericCellModel) -> CGSize in
        // Return CGSize
    }.handleSupplementaryHeaderItemSize { (section: Int, model: GenericSupplementaryModel) -> CGSize in
        // Return CGSize
    }
    // Chain more handlers
    
    
    let emptyView = UILabel()
    emptyView.text = "Still loading data... :)"
    emptyView.font = UIFont.boldSystemFont(ofSize: 25)
    emptyView.numberOfLines = 0
    emptyView.textAlignment = .center
    
    dataSource.emptyDataSourceView = emptyView
    return dataSource
}

```

## Requirements

<hr />

<ul>
    <li>Xcode 9.0+</li>
    <li>iOS 11.0+</li>
</ul>

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

ComposableDataSource is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ComposableDataSource'
```

## Author

ChrishonWyllie, chrishon595@yahoo.com

## License

ComposableDataSource is available under the MIT license. See the LICENSE file for more info.
