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
    
    private var dataSource: ComposableCollectionDataSource?
    
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        view.addSubview(collectionView)
        
//        Celestial.shared.setDebugMode(on: true)
        
        collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        dataSource = setupDataSource()
        fetchData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func fetchData() {
        
        let urlString: String = "https://picsum.photos/v2/list?limit=25"
        guard let url = URL(string: urlString) else {
            return
        }
        
        var supplementaryModels: [GenericSupplementaryHeaderFooterModel] = []
        var cellModels: [GenericCellModel] = []
        
        let group = DispatchGroup()
        
        group.enter()
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            let headerModel = HeaderItemModel(title: urlString)
            let containerModel = GenericSupplementaryHeaderFooterModel(header: headerModel, footer: nil)
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

    private func setupDataSource() -> ComposableCollectionDataSource {
            
        let models: [[GenericCellModel]] = [[]]
        let supplementaryModels: [GenericSupplementarySectionModel] = []
        
        let dataSource = ComposableCollectionDataSource(collectionView: collectionView, cellItems: models, supplementarySectionItems: supplementaryModels)
        .handleSelection { (indexPath, model) in
                print("selected model: \(model) at indexPath: \(indexPath)")
        }.handleItemSize { [unowned self] (indexPath, model) -> CGSize in
            return CGSize.init(width: self.collectionView.frame.size.width, height: 400.0)
        }.handleSupplementaryHeaderItemSize { [unowned self] (indexPath, model) -> CGSize in
            return CGSize.init(width: self.collectionView.frame.size.width, height: 50.0)
        }.handlRequestedPrefetching { (indexPaths, models) in
            let models = models as! [ImageCellModel]
            Celestial.shared.prefetchResources(at: models.map { $0.urlString} )
        }.handleCanceledPrefetching { (indexPaths, models) in
            let models = models as! [ImageCellModel]
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
