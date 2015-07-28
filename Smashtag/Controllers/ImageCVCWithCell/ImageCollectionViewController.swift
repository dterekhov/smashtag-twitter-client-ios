//
//  ImageCollectionViewController.swift
//  Smashtag
//
//  Created by Dmitry Terekhov on 26.07.15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ImageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout, CHTCollectionViewDelegateWaterfallLayout {
    private struct Storyboard {
        static let CellID = "ImageCollectionViewCell"
    }
    
    private struct Constants {
        static let MinImageCellWidth: CGFloat = 60
        static let CellSize = CGSize(width: 104, height: 104)
        
        static let MinimumColumnSpacing: CGFloat = 2
        static let MinimumInteritemSpacing: CGFloat = 2
        static let SectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        
        static let WaterfallColumnCount = 3
        static let WaterfallMaxColumnCount = 8
        static let WaterfallMinColumnCount = 1
        
        static let FlowLayoutIcon = UIImage(named: "ico_flow_layout")
        static let WaterfallLayoutIcon = UIImage(named: "ico_waterfall_layout")
    }
    
    // MARK: - Public API
    var tweets: [[Tweet]] = [] {
        didSet {
            images = tweets.flatMap({ $0 })
                .map { tweet in
                    tweet.media.map { TweetMedia(tweet: tweet, mediaItem: $0) }
                    }.flatMap({ $0 })
        }
    }
    
    // MARK: - Members
    private var images = [TweetMedia]()
    private var scale: CGFloat = 1 {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    private var flowLayout = UICollectionViewFlowLayout()
    private var waterfallLayout = CHTCollectionViewWaterfallLayout()
    private var changeLayoutButton: UIBarButtonItem?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChangeLayoutButton()
        setupWaterfallCollectionViewLayout()
    }
    
    // MARK: - Setups
    private func setupChangeLayoutButton() {
        changeLayoutButton = UIBarButtonItem(image: Constants.FlowLayoutIcon, style: UIBarButtonItemStyle.Plain, target: self, action: "changeLayout:")
        if let existButton = navigationItem.rightBarButtonItem {
            navigationItem.rightBarButtonItems = [existButton, changeLayoutButton!]
        } else {
            navigationItem.rightBarButtonItem = changeLayoutButton
        }
    }
    
    private func setupWaterfallCollectionViewLayout() {
        // Setup flowLayout
        flowLayout.minimumLineSpacing = Constants.MinimumColumnSpacing
        flowLayout.minimumInteritemSpacing = Constants.MinimumInteritemSpacing
        flowLayout.sectionInset = Constants.SectionInset
        
        // Setup waterfallLayout
        waterfallLayout.columnCount = Constants.WaterfallColumnCount
        waterfallLayout.minimumColumnSpacing = Constants.MinimumColumnSpacing
        waterfallLayout.minimumInteritemSpacing = Constants.MinimumInteritemSpacing
        
        // By default: waterfallLayout
        collectionView?.collectionViewLayout = waterfallLayout
    }
    
    private func refreshWaterfallLayoutColumnCount(collectionView: UICollectionView) {
        if let waterfallLayout = collectionView.collectionViewLayout as? CHTCollectionViewWaterfallLayout {
            let changedColumnCount = Int(CGFloat(Constants.WaterfallColumnCount) / scale)
            // Handle column count with min and max values
            if changedColumnCount < Constants.WaterfallMinColumnCount {
                waterfallLayout.columnCount = Constants.WaterfallMinColumnCount
            } else if changedColumnCount > Constants.WaterfallMaxColumnCount {
                waterfallLayout.columnCount = Constants.WaterfallMaxColumnCount
            } else {
                waterfallLayout.columnCount = changedColumnCount
            }
        }
    }
    
    // MARK: - User interaction
    @IBAction private func zoomCollectionView(sender: UIPinchGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Changed {
            scale *= sender.scale
            sender.scale = 1.0
        }
    }
    
    @objc private func changeLayout(sender: UIBarButtonItem) {
        if let currentLayout = collectionView?.collectionViewLayout {
            if currentLayout is CHTCollectionViewWaterfallLayout {
                changeLayoutButton?.image = Constants.WaterfallLayoutIcon
                collectionView?.setCollectionViewLayout(flowLayout, animated: true)
            } else {
                changeLayoutButton?.image = Constants.FlowLayoutIcon
                collectionView?.setCollectionViewLayout(waterfallLayout, animated: true)
            }
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tweetTVC = segue.destinationViewController as? TweetTableViewController {
            if let imageCell = sender as? ImageCollectionViewCell, let tweetMedia = imageCell.tweetMedia {
                tweetTVC.tweets = [[tweetMedia.tweet]]
            }
        }
    }

    // MARK: - UICollectionViewDataSource
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Storyboard.CellID, forIndexPath: indexPath) as! ImageCollectionViewCell
        cell.tweetMedia = images[indexPath.row]
        return cell
    }

    // MARK: - UICollectionViewDelegateFlowLayout, CHTCollectionViewDelegateWaterfallLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        // Refresh columnCount only for waterfallLayout
        refreshWaterfallLayoutColumnCount(collectionView)
        
        let ratio = CGFloat(images[indexPath.row].mediaItem.aspectRatio)
        let maxCellWidth = collectionView.bounds.size.width
        var size = CGSize(width: Constants.CellSize.width * scale, height: Constants.CellSize.height * scale)
        
        if ratio > 1 {
            size.height /= ratio
        } else {
            size.width *= ratio
        }
        
        if size.width > maxCellWidth {
            size.width = maxCellWidth
            size.height = size.width / ratio
        } else if size.width < Constants.MinImageCellWidth {
            size.width = Constants.MinImageCellWidth
            size.height = size.width / ratio
        }
        return size
    }
}
