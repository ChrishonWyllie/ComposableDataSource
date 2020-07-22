//
//  ViewController.swift
//  ComposableDataSource
//
//  Created by ChrishonWyllie on 07/08/2020.
//  Copyright (c) 2020 ChrishonWyllie. All rights reserved.
//

import UIKit
import ComposableDataSource
import Celestial

class ViewController: UIViewController {
    
    // MARK: - Variables
    
    private var dataSource: ComposableCollectionDataSource?
    
    
    
    
    
    // MARK: - UI Elements
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.allowsSelection = true
        collectionView.alwaysBounceVertical = true
        return collectionView
    }()
    
    private lazy var addItemsButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addItems))
        return btn
    }()
    
    private lazy var updateItemsButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(title: "Update", style: .plain, target: self, action: #selector(updateItems))
        return btn
    }()
    
    private lazy var deleteItemsButton: UIBarButtonItem = {
        let btn = UIBarButtonItem(title: "Delete", style: .plain, target: self, action: #selector(deleteItems))
        return btn
    }()
    
    
    
    
    
    // MARK: - View life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        navigationItem.rightBarButtonItems = [deleteItemsButton, updateItemsButton, addItemsButton]
        
        setupCollectionView()
        dataSource = setupDataSource()
        
        fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// MARK: - Setup functions

extension ViewController {
    
    private func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    private func setupDataSource() -> ComposableCollectionDataSource {
            
        let models: [[BaseCollectionCellModel]] = [[]]
        let supplementaryModels: [GenericSupplementarySectionModel] = []
        
        let dataSource = ComposableCollectionDataSource(collectionView: collectionView,
                                                        cellItems: models,
                                                        supplementarySectionItems: supplementaryModels)
        .handleSelection { (indexPath, model) in
            print("selected model: \(model) at indexPath: \(indexPath)")
        }.handleItemSize { [unowned self] (indexPath: IndexPath, model: BaseCollectionCellModel) -> CGSize in
            return CGSize.init(width: self.collectionView.frame.size.width, height: 400.0)
        }.handleSupplementaryHeaderItemSize { [unowned self] (section: Int, model: BaseComposableSupplementaryViewModel) -> CGSize in
            return CGSize.init(width: self.collectionView.frame.size.width, height: 60.0)
        }.handlRequestedPrefetching { (indexPaths: [IndexPath], models: [BaseCollectionCellModel]) in
            let models = models as! [URLCellModel]
            Celestial.shared.prefetchResources(at: models.map { $0.urlString} )
        }.handleCanceledPrefetching { (indexPaths: [IndexPath], models: [BaseCollectionCellModel]) in
            let models = models as! [URLCellModel]
            Celestial.shared.pausePrefetchingForResources(at: models.map { $0.urlString}, cancelCompletely: false)
        }
        
        let emptyView = UILabel()
        emptyView.text = "Still loading data... :)"
        emptyView.font = UIFont.boldSystemFont(ofSize: 25)
        emptyView.numberOfLines = 0
        emptyView.textAlignment = .center
        
        dataSource.emptyDataSourceView = emptyView
        return dataSource
    }
}

// MARK: - CRUD functions

extension ViewController {
    
    @objc private func addItems() {
        let urlStrings: [String] = [
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4",
            "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"
        ]
        
        let videoCellModels: [BaseCollectionCellModel] = urlStrings.map {
            return VideoCellModel(urlString: $0)
        }
        
        let headerModel = HeaderItemModel(title: "Videos")
        let supplementarySectionItem = GenericSupplementarySectionModel(header: headerModel, footer: nil)
        
        dataSource?.insertNewSection(withCellItems: videoCellModels, supplementarySectionItem: supplementarySectionItem, atSection: 0, completion: nil)
        
    }
    
    @objc private func updateItems() {
//        dataSource?.updateSections(atItemSectionIndices: <#T##[Int]#>, newCellItems: <#T##[[BaseCollectionCellModel]]#>, completion: <#T##OptionalCompletionHandler##OptionalCompletionHandler##(Bool) -> ()#>)
    }
    
    @objc private func deleteItems() {
        dataSource?.deleteSections(atSectionIndices: [0], completion: nil)
    }
    
    private func fetchData() {
        
        let urlString: String = "https://picsum.photos/v2/list?limit=25"
        guard let url = URL(string: urlString) else {
            return
        }
        
        var supplementaryModels: [GenericSupplementarySectionModel] = []
        var cellModels: [BaseCollectionCellModel] = []
        
        let group = DispatchGroup()
        
        group.enter()
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            let headerModel = HeaderItemModel(title: urlString)
            let containerModel = GenericSupplementarySectionModel(header: headerModel, footer: nil)
            supplementaryModels.append(containerModel)
            
            guard let data = data else { return }
            do {
                guard let jsonDataArray = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as? [[String: AnyObject]] else {
                    return
                }
                
                jsonDataArray.forEach { (jsonObject) in
                    let urlSessionObject = URLSessionObject(object: jsonObject)
                    cellModels.append(ImageCellModel(urlString: urlSessionObject.downloadURL))
                }
                
                group.leave()
                
            } catch let error {
                print("error converting data to json: \(error)")
            }
            
        }.resume()
        
        group.notify(queue: DispatchQueue.main) {
            self.dataSource?.replaceDataSource(withCellItems: [cellModels],
                                               supplementarySectionItems: supplementaryModels,
                                               completion: nil)
        }
    }
}

fileprivate struct URLSessionObject {
    let author: String
    let downloadURL: String
    let height: NSNumber
    let id: NSNumber
    let url: String
    let width: NSNumber
    
    init(object: [String: AnyObject]) {
        author = object["author"] as? String ?? ""
        downloadURL = object["download_url"] as? String ?? ""
        height = object["height"] as? NSNumber ?? 0
        id = object["id"] as? NSNumber ?? 0
        url = object["url"] as? String ?? ""
        width = object["width"] as? NSNumber ?? 0
    }
}
