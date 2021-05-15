## [Version 0.7.41](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.7.41)

### New
* N/A

### Improvements
* Overrote the `numberOfSections(in:)` and the `collectionView(_: numberOfItemsInSection:)` to use the separately overrideable functions. This allows for easier subclassing with varying dataProvider setups

### Bug fixes
* N/A

## [Version 0.7.37](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.7.37)

### New
* N/A

### Improvements
* Made some functions more open, so they can be overrideable
* Overrote the didSelect function to use the `item(at:)`, which is also overrideable itself

### Bug fixes
* N/A

## [Version 0.7.32](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.7.32)

### New
* N/A

### Improvements
* N/A

### Bug fixes
* Fixed issue where the `SectionableCollectionDataSource` was registering the Generic versions of the cell and supplementary view models. This resulted in crashes in subclasses about not registering cells before dequeueing them.

## [Version 0.7.28](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.7.28)

### New
* N/A

### Improvements
* Made the `reset(keepingStructure:shouldReloadCollectionView:)` function open, so it can be overriden
* Made the `numberOfItems(in:)` function open so that it can be overriden

### Bug fixes
* N/A

## [Version 0.7.24](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.7.24)

### New
* N/A

### Improvements
* Added an optional boolean argument to the `reset(keepingStructure:)` function to optionally reload the underlying UICollectionView when the data is cleared.
* Made the DataSourceProvider open, so it can be subclassed.
* Exposed the `provider` variable within the dataSource, so its operations can be used in overriden CRUD functions without performing any batch updates or reloading.
* Fixed an issue where the `BaseSupplementarySectionModel`'s header and footer properties had been using the generic protocol as its type rather than the `BaseCollectionSupplementaryViewModel`

### Bug fixes
* N/A

## [Version 0.7.9](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.7.9)

### New
* Exposed functions within the DataSourceProvider to the ComposableDataSource for getting the cell and supplementary view model items.

### Improvements
* N/A

### Bug fixes
* N/A

## [Version 0.7.4](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.7.4)

### New
* N/A

### Improvements
* Replaced uses of `count == 0` or `counf > 0` with simply checking if an array `isEmpty`. According to sources, this is a more efficient approach

### Bug fixes
* Fixed issue where empty data source view does not supply after first time

## [Version 0.7.0](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.7.0)

### New
* Links to more documentation

### Improvements
* Updated README
* Added link in README to more documentation elsewhere
* Renamed GenericSupplementarySectionModel to BaseSupplementarySectionModel
* Renamed BaseComposableSupplementaryViewModel to BaseCollectionSupplementaryViewModel

### Bug fixes
* Fixed issue where empty data source view does not supply after first time

## [Version 0.6.21](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.6.21)

### New
* N/A

### Improvements
* N/A

### Bug fixes
* Fixed bug where calling `DataProvider.updateSections(...)` would not update the actual backing-store of cell view models

## [Version 0.6.5](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.6.5)

### New
* N/A

### Improvements
* Replaced builder pattern function names with ones similar to original delegate function names

### Bug fixes
* N/A

## [Version 0.6.0](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.6.0)

### New
* Added Table of Contents to README
* Updated to latest version of Celestial
* Downgraded minimum deployment target from iOS 11 to iOS 10

### Improvements
* Updated README
* Added navigation buttons to test CRUD
* Replaced generic protocols with Base protocols to be used ComposableCollectionDataSource
* Renamed GenericCollectionViewCell and GenericCollectionReusableView to BaseComposableCollectionViewCell and BaseComposableCollectionReusableView

### Bug fixes
* N/A

## [Version 0.5.9](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.5.9)

### New
* Added function for deleting sections
* Adding function for inserting new section with cell items and supplementary section items

### Improvements
* Replaced return value of generic protocol to return ComposableCollectionDataSource instead. Type casting the final builder pattern function’s return value to the desired dataSource class no longer necessary

### Bug fixes
* N/A

## [Version 0.5.0](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.5.0) 

### New
* Added DebugLogger, replacing print statements

### Improvements
* Cleaned up the header declarations of the data source functions by using convenient typealiases
* Added documentation for ComposableCollectionDataSource builder pattern functions
* More documentation for functions and classes

### Bug fixes
* N/A

## [Version 0.4.0](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.4.0) 

### New
* Allow all `UICollectionView` delegate and datasource functions to be overriden
* Replaced handlers with builder pattern
* Added function for getting all `GenericCellModels` at designated indexPaths
* Added conformance for prefetching
* Added associatedType `U` to `DataSourceProvider` to represent individual header and footer models in GenericSupplementaryContainerModel `S`

### Improvements
* Adoption of builder pattern allows for easier code completion. 
* Replaced optional `GenericCellModel` argument in handlers with non optional. Removes need for unwrapping a guaranteed non-nil-but-still optional argument
* Moved all supplementary code (enums, protocols, structs, etc.) out of code. Improving code readability
* Removed designated section argument from supplementary models

### Bug fixes
N/A

## [Version 0.3.0](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.3.0)  

### New
  * Working example code

### Improvements
N/A

### Bug fixes
N/A

## [Version 0.2.0](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.2.0)  

### New
  * Implemented basic file and folder structure.

### Improvements
N/A

### Bug fixes
N/A


## [Version 0.1.0](https://github.com/ChrishonWyllie/ComposableDataSource/releases/tag/0.1.0)  

### New
  * First commit

### Improvements
N/A

### Bug fixes
N/A
