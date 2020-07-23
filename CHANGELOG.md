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
