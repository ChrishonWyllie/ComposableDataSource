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
        
        guard let url = URL(string: "https://picsum.photos/v2/list?limit=25") else {
            return
        }
        
        var cellModels: [GenericCellModel] = []
        
        let group = DispatchGroup()
        
        group.enter()
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
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
            self.dataSource?.replaceAllItems(with: [cellModels], supplementaryContainerItems: [], updateStyle: .withBatchUpdates, completion: nil)
        }
    }

    private func setupDataSource() -> ComposableCollectionDataSource {
            
        let models: [[GenericCellModel]] = [[]]
        
        let dataSource = TestDataSource(collectionView: collectionView,
                                                      array: models,
                                                      supplementaryItems: [])
        
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

fileprivate class TestDataSource: ComposableCollectionDataSource {
    override func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: collectionView.frame.size.width, height: 400.0)
    }
}
