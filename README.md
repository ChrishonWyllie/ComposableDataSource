# ComposableDataSource

[![CI Status](https://img.shields.io/travis/ChrishonWyllie/ComposableDataSource.svg?style=flat)](https://travis-ci.org/ChrishonWyllie/ComposableDataSource)
[![Version](https://img.shields.io/cocoapods/v/ComposableDataSource.svg?style=flat)](https://cocoapods.org/pods/ComposableDataSource)
[![License](https://img.shields.io/cocoapods/l/ComposableDataSource.svg?style=flat)](https://cocoapods.org/pods/ComposableDataSource)
[![Platform](https://img.shields.io/cocoapods/p/ComposableDataSource.svg?style=flat)](https://cocoapods.org/pods/ComposableDataSource)

ComposableDataSource wraps the typically verbose UICollectionView data source and delegate implementation into a more neatly packed builder pattern

## Prerequisites

<hr />

<ul>
    <li>Xcode 8.0 or higher</li>
    <li>iOS 10.0 or higher</li>
</ul>

## Usage

There are three components to creating a ComposableDataSource:

<ul>
    <li>Setting up a View Model to represent and configure a cell</li>
    <li>Creating a Configurable Cell, using the BaseComposableCollectionViewCell superclass</li>
    <li>Creating a Composable Data Source</li>
</ul>

## Step 1/3: Setting up the View Model

<hr />

Technically, there's two steps here:
<ul>
    <li>Creating a View Model</li>
    <li>Creating a Model (Optional)</li>
</ul>

The view model decorates the cell with info from the model when the cell is dequeued with `collectionView(_:cellForItemAt:)`.
Your View Model but conform to the `BaseCollectionCellModel` protocol. Doing so will require you to return the UICollectionViewCell class

```swift

// View Model
struct ChatroomViewModel: BaseCollectionCellModel {
    
    func getCellClass() -> AnyComposableCellClass {
        return VideoCell.self
    }

    let chatroom: Chatroom
}

// Model
struct Chatroom {
    // ...
}
```

Your View Model must conform to `BaseCollectionCellModel` and provide a subclass of `BaseComposableCollectionViewCell` subclass. Similar to how you would normally use `collectionView.register(:forCellWithReuseIdentifier:)`

## Step 2/3: Setting up a cell

<hr />

```swift

class ChatroomCell: BaseComposableCollectionViewCell {

    override func configure(with item: BaseCollectionCellModel, at indexPath: IndexPath) {
        let chatroomViewModel = item as! ChatroomViewModel
        let chatroom = chatroomViewModel.chatroom
        // Decorate cell using chatroom object
    }

    // UIViews ...

    override func setupUIElements() {
        super.setupUIElements()

        // Use `super.containerView` instead of contentView to add your subviews
    
    }

}
```

Your UICollectionViewCell must subclass `BaseComposableCollectionViewCell`. Additionally, take advantage of two overridable functions:

```swift

func configure(with item: BaseCollectionCellModel, at indexPath: IndexPath) {

}
```
And

```swift
func setupUIElements() {

}
```

The `configure(with:at:)` function is an overridable function from the `BaseComposableCollectionViewCell` that is automatically called when the cell is dequeued with `collectionView(_:cellForItemAt:)`. Use this to decorate your cell with data.

The `setupUIElements()` function is an overridable function from the `BaseComposableCollectionViewCell` that is automatically called when the cell is initialized. Add your subviews, constraints, etc. here.

<br />
<br />

## Step 3/3: Setting up the data source

```swift

private func setupDataSource() -> ComposableCollectionDataSource {
        
    let models: [[BaseCollectionCellModel]] = [[]]
    let supplementaryModels: [GenericSupplementarySectionModel] = []
    
    let dataSource = ComposableCollectionDataSource(collectionView: collectionView,
                                                    cellItems: models,
                                                    supplementarySectionItems: supplementaryModels)
    .handleSelection { (indexPath: IndexPath, model: BaseCollectionCellModel) in
        // Handle selection at indexPath
    }.handleItemSize { (indexPath: IndexPath, model: BaseCollectionCellModel) -> CGSize in
        // Return CGSize
    }.handleSupplementaryHeaderItemSize { (section: Int, model: BaseComposableSupplementaryViewModel) -> CGSize in
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
