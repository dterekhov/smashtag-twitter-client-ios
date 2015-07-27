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
        static let CellSizeWidth: CGFloat = 120
        static let CellSizeHeight: CGFloat = 120
        
        static let WaterfallColumnCount = 3
        static let WaterfallMinimumColumnSpacing: CGFloat = 1
        static let WaterfallMinimumInteritemSpacing: CGFloat = 1
        static let WaterfallMaxColumnCount = 8
        static let WaterfallMinColumnCount = 1
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
    
    @IBAction func zoomCollectionView(sender: UIPinchGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.Changed {
            scale *= sender.scale
            sender.scale = 1.0
        }
    }
    
    // MARK: - Members
    private var images = [TweetMedia]()
    private var scale: CGFloat = 1 {
        didSet {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWaterfallCollectionViewLayout()
    }
    
    private func setupWaterfallCollectionViewLayout() {
        var layout = CHTCollectionViewWaterfallLayout()
        layout.columnCount = Constants.WaterfallColumnCount
        layout.minimumColumnSpacing = Constants.WaterfallMinimumColumnSpacing
        layout.minimumInteritemSpacing = Constants.WaterfallMinimumInteritemSpacing
        collectionView?.collectionViewLayout = layout
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
        
        let ratio = CGFloat(images[indexPath.row].mediaItem.aspectRatio)
        let collectionViewWidth = collectionView.bounds.size.width
        var size = CGSize(width: Constants.CellSizeWidth * scale, height: Constants.CellSizeHeight * scale)
        
        if ratio > 1 {
            size.height /= ratio
        } else {
            size.width *= ratio
        }
        
        if size.width > collectionViewWidth {
            size.width = collectionViewWidth
            size.height = size.width / ratio
        } else if size.width < Constants.MinImageCellWidth {
            size.width = Constants.MinImageCellWidth
            size.height = size.width / ratio
        }
        return size
    }
}
