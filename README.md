# ComposableDataSource

[![CI Status](https://img.shields.io/travis/ChrishonWyllie/ComposableDataSource.svg?style=flat)](https://travis-ci.org/ChrishonWyllie/ComposableDataSource)
[![Version](https://img.shields.io/cocoapods/v/ComposableDataSource.svg?style=flat)](https://cocoapods.org/pods/ComposableDataSource)
[![License](https://img.shields.io/cocoapods/l/ComposableDataSource.svg?style=flat)](https://cocoapods.org/pods/ComposableDataSource)
[![Platform](https://img.shields.io/cocoapods/p/ComposableDataSource.svg?style=flat)](https://cocoapods.org/pods/ComposableDataSource)

ComposableDataSource wraps the typically verbose UICollectionView data source and delegate implementation into a more neatly packed builder pattern

Chain your UICollectionView delegate calls one after another as needed:

```swift

let dataSource = ComposableCollectionDataSource(....)
// chain selection delegate function
// chain cell size delegate function
// ... and so on ...
```

### Table of Contents  
* [Prerequisites](#prerequisites)
* [Installation](#installation)
* [Usage](#usage)
* [Advanced Usage](#advanced-usage)
    * [Adding to datasource](#adding-to-datasource)
    * [Updating datasource](#updating-datasource)
    * [Deleting from datasource](#deleting-from-datasource)
    * [Empty backgroundView](#empty-background-view)
[Example App](#example-app)
<br />

<a name="prerequisites"/>

## Prerequisites

<ul>
    <li>Xcode 8.0 or higher</li>
    <li>iOS 10.0 or higher</li>
</ul>

<a name="installation"/>

## Installation

ComposableDataSource is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'ComposableDataSource'
```

<a name="usage"/>

## Usage

There are three components to creating a ComposableDataSource:

<ul>
    <li>Setting up a View Model to represent and configure a cell</li>
    <li>Creating a Configurable Cell, using the BaseComposableCollectionViewCell superclass</li>
    <li>Creating a Composable Data Source</li>
</ul>

## Step 1/3: Setting up the View Model

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

var dataSource: ComposableCollectionDataSource!
var collectionView : UICollectionView = ...

override func viewDidLoad() {
    super.viewDidLoad()

    setupUI()

    dataSource = setupDataSource()
}

....

private func setupDataSource() -> ComposableCollectionDataSource {
        
    // Initialize double nested array of view models
    // NOTE
    // Each inner array represents each section of your data source
    // in the order they are added
    let models: [[ChatroomViewModel]] = [[....]]
    
    // Initialize array of supplementary models
    // NOTE
    // Each item represents the header and/or footer supplementary view
    // for a specific section in the order they are added
    let supplementaryModels: [GenericSupplementarySectionModel] = [....]
    
    let dataSource = ComposableCollectionDataSource(collectionView: collectionView,
                                                    cellItems: models,
                                                    supplementarySectionItems: supplementaryModels)
    .didSelectItem { (indexPath: IndexPath, model: BaseCollectionCellModel) in
        // Handle selection at indexPath
    }.sizeForItem { [unowned self] (indexPath: IndexPath, model: BaseCollectionCellModel) -> CGSize in
        // Return size for cell at the specified indexPath
    }.referenceSizeForHeader { [unowned self] (section: Int, model: BaseComposableSupplementaryViewModel) -> CGSize in
        // Return size for supplementary header view at the specified indexPath
        // If your data source will have supplementary models 
    }
    // Chain more handlers ...
    
    return dataSource
}
```

<a name="#advanced-usage"/>

## Advanced Usage

<a name="#adding-to-datasource"/>

### Adding to datasource

Adding new items the datasource is very straightforward with the public APIs offrered.

First, create new view models to represent the cells you want to add:

```swift

let newSectionOfItems: [ChatroomViewModel] = [
    ChatroomViewModel(chatroom: ....),
    // Array of items...
]

```

Then use the APIs provided by the `ComposableCollectionDataSource` to add the items. In this example, we will insert a completely new section at section 0 (Essentially inserting at the top of the list and pushing any existing sections down, as expected)

```swift

let desiredSectionIndex: Int = 0

self.dataSource.insertNewSection(withCellItems: newSectionOfItems, supplementarySectionItem: nil, 
                                 atSection: desiredSectionIndex, completion: nil)

```

Additionally, inserting view models at varying indexPaths is supported:

```swift

// Inserts view models at varying index paths
func insert(cellItems: [T], atIndexPaths indexPaths: [IndexPath], 
            updateStyle: DataSourceUpdateStyle, completion: OptionalCompletionHandler)

// Inserts supplementary section items (Struct containing view models for header and/or footer supplementary views)
func insert(supplementarySectionItems: [S], atSections sections: [Int], 
            updateStyle: DataSourceUpdateStyle, completion: OptionalCompletionHandler)

```

<a name="#updating-datasource"/>

### Updating datasource

<a name="#deleting-from-datasource"/>

### Deleting from datasource

<a name="#empty-background-view"/>

### Empty backgroundView

If you'd like to display some kind of view when the dataSource is empty:

```swift

let emptyView = UILabel()
emptyView.text = "Still loading data... :)"
emptyView.font = UIFont.boldSystemFont(ofSize: 25)
emptyView.numberOfLines = 0
emptyView.textAlignment = .center

dataSource.emptyDataSourceView = emptyView

```

<a name="example-app"/>

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

ChrishonWyllie, chrishon595@yahoo.com

## License

ComposableDataSource is available under the MIT license. See the LICENSE file for more info.
