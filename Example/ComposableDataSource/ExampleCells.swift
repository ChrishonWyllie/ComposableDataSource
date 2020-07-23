//
//  ExampleCells.swift
//  ComposableDataSource_Example
//
//  Created by Chrishon Wyllie on 7/8/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import UIKit
import ComposableDataSource
import Celestial
import AVFoundation

class TestCollectionCell: BaseComposableCollectionViewCell {
    
    override func configure(with item: BaseCollectionCellModel, at indexPath: IndexPath) {
        guard let item = item as? URLCellModel else { fatalError() }
        titleLabel.text = item.urlString
    }
    
    fileprivate var progressLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()
    
    fileprivate var progressView: UIProgressView = {
        let v = UIProgressView(progressViewStyle: .default)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.progressTintColor = UIColor.red
        return v
    }()
    
    fileprivate var titleLabel: UILabel = {
        let lbl = UILabel()
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.numberOfLines = 0
        return lbl
    }()
    
    
    
    
    override func setupUIElements() {
        super.setupUIElements()
        
        [titleLabel, progressLabel, progressView].forEach { (subview) in
            super.containerView.addSubview(subview)
        }
        
        // Handle layout...
        
        let padding: CGFloat = 12.0
        
        titleLabel.leadingAnchor.constraint(equalTo: super.containerView.leadingAnchor, constant: padding).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: super.containerView.trailingAnchor, constant: -padding).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: progressLabel.topAnchor, constant: -padding).isActive = true
        
        progressLabel.leadingAnchor.constraint(equalTo: super.containerView.leadingAnchor, constant: padding).isActive = true
        progressLabel.trailingAnchor.constraint(equalTo: super.containerView.trailingAnchor, constant: -padding).isActive = true
        progressLabel.bottomAnchor.constraint(equalTo: progressView.topAnchor, constant: -padding).isActive = true
        progressLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        progressView.leadingAnchor.constraint(equalTo: super.containerView.leadingAnchor, constant: padding).isActive = true
        progressView.trailingAnchor.constraint(equalTo: super.containerView.trailingAnchor, constant: -padding).isActive = true
        progressView.bottomAnchor.constraint(equalTo: super.containerView.bottomAnchor, constant: -padding).isActive = true
    }
    
    func updateCompletion() {
        DispatchQueue.main.async {
            self.progressLabel.text = "Finished Downloadin'!"
        }
    }

    func updateProgress(_ progress: Float, humanReadableProgress: String) {
        DispatchQueue.main.async {
            self.progressView.progress = Float(progress)
            self.progressLabel.text = humanReadableProgress
        }
    }
    
    func updateError() {
        DispatchQueue.main.async {
            self.progressLabel.text = "Error downloading!"
            self.progressLabel.textColor = .red
        }
    }
}













// MARK: - VideoCell

class VideoCell: TestCollectionCell {
    
    override func configure(with item: BaseCollectionCellModel, at indexPath: IndexPath) {
        super.configure(with: item, at: indexPath)
        guard let item = item as? VideoCellModel else { fatalError() }
        
        let urlString = item.urlString
        playerView.loadVideoFrom(urlString: urlString)
                
//        playerView.loadVideoFrom(urlString: someCellModel.urlString, progressHandler: { (progress) in
//            print("current downlod progress: \(progress)")
//            self.updateProgress(progress, humanReadableProgress: "Not sure")
//        }, completion: {
//            print("Image has finished loading")
//            self.updateCompletion()
//        }) { (error) in
//            print("Error loading image")
//            self.updateError()
//        }
        
        if playtimeObserver != nil {
            NotificationCenter.default.removeObserver(playtimeObserver!)
            playtimeObserver = nil
        }
    }
    
    public lazy var playerView: URLVideoPlayerView = {
        let v = URLVideoPlayerView(delegate: self, cacheLocation: .fileSystem)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
//        v.isMuted = true
        return v
    }()
    
    
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playerView.reset()
        resetLoopObserver()
    }
    
    override func setupUIElements() {
        super.setupUIElements()
        
        [playerView].forEach { (subview) in
            containerView.addSubview(subview)
        }
        
        let padding: CGFloat = 12
        
        // Handle layout...
        playerView.leadingAnchor.constraint(equalTo: super.containerView.leadingAnchor, constant: padding).isActive = true
        playerView.topAnchor.constraint(equalTo: super.containerView.topAnchor, constant: padding).isActive = true
        playerView.trailingAnchor.constraint(equalTo: super.containerView.trailingAnchor, constant: -padding).isActive = true
        playerView.bottomAnchor.constraint(equalTo: super.titleLabel.topAnchor, constant: -padding).isActive = true
        
    }
    
    
    private weak var playtimeObserver: NSObjectProtocol?

    private func observeDidPlayToEndTime() {
        
        let playerItem = (playerView.player!.currentItem)
        
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                                                  object: playerItem,
                                                                  queue: .main,
                                                                  using: { [weak self] (notification) in
            guard let strongSelf = self else { return }
            strongSelf.playerView.player!.seek(to: CMTime.zero)
            strongSelf.playerView.player!.play()
        })
    }
    
    private func resetLoopObserver() {
        if playtimeObserver != nil {
            NotificationCenter.default.removeObserver(playtimeObserver!)
            playtimeObserver = nil
        }
    }
    
}

extension VideoCell: URLVideoPlayerViewDelegate {
    
    func urlVideoPlayerIsReadyToPlay(_ view: URLVideoPlayerView) {
        view.play()
        observeDidPlayToEndTime()
    }
   
    func urlCachableView(_ view: URLCachableView, didFinishDownloading media: Any) {
        super.updateCompletion()
    }
  
    func urlCachableView(_ view: URLCachableView, downloadFailedWith error: Error) {
        super.updateError()
    }
  
    func urlCachableView(_ view: URLCachableView, downloadProgress progress: Float, humanReadableProgress: String) {
        super.updateProgress(progress, humanReadableProgress: humanReadableProgress)
    }
    
}

























// MARK: - ImageCell

class ImageCell: TestCollectionCell {
    
    override func configure(with item: BaseCollectionCellModel, at indexPath: IndexPath) {
        super.configure(with: item, at: indexPath)
        
        guard let item = item as? ImageCellModel else { fatalError() }
        
//        imageView.loadImageFrom(urlString: someCellModel.urlString)
        
        imageView.loadImageFrom(urlString: item.urlString, progressHandler: { (progress) in
            print("current downlod progress: \(progress)")
            self.updateProgress(progress, humanReadableProgress: "Not sure")
        }, completion: {
            print("Image has finished loading")
            self.updateCompletion()
        }) { (error) in
            print("Error loading image")
            self.updateError()
        }
    }

    // Initialize the URLImageView within the cell as a variable.
    // NOTE: The second initializer is used which does NOT have the urlString argument.
    private lazy var imageView: URLImageView = {
        let img = URLImageView(delegate: self, cacheLocation: .inMemory)
        img.translatesAutoresizingMaskIntoConstraints = false
        img.backgroundColor = .gray
        img.contentMode = .scaleAspectFill
        img.clipsToBounds = true
        return img
    }()
    
    
    
    override func setupUIElements() {
        super.setupUIElements()
        
        [imageView].forEach { (subview) in
            containerView.addSubview(subview)
        }
        
        let padding: CGFloat = 12
        
        // Handle layout...
        imageView.leadingAnchor.constraint(equalTo: super.containerView.leadingAnchor, constant: padding).isActive = true
        imageView.topAnchor.constraint(equalTo: super.containerView.topAnchor, constant: padding).isActive = true
        imageView.trailingAnchor.constraint(equalTo: super.containerView.trailingAnchor, constant: -padding).isActive = true
        imageView.bottomAnchor.constraint(equalTo: super.titleLabel.topAnchor, constant: -padding).isActive = true
    }
}

extension ImageCell: URLCachableViewDelegate {
    
    func urlCachableView(_ view: URLCachableView, didFinishDownloading media: Any) {
        updateCompletion()
    }
    
    func urlCachableView(_ view: URLCachableView, downloadFailedWith error: Error) {
        updateError()
    }
    
    func urlCachableView(_ view: URLCachableView, downloadProgress progress: Float, humanReadableProgress: String) {
        updateProgress(progress, humanReadableProgress: humanReadableProgress)
    }
}
