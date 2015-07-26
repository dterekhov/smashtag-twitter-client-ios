//
//  ImageCollectionViewController.swift
//  Smashtag
//
//  Created by Dmitry Terekhov on 26.07.15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ImageCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    private struct Storyboard {
        static let CellID = "ImageCollectionViewCell"
    }
    
    private struct Constants {
        static let MinImageCellWidth: CGFloat = 60
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
            collectionViewLayout.invalidateLayout()
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

    // MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let ratio = CGFloat(images[indexPath.row].mediaItem.aspectRatio)
        let collectionViewWidth = collectionView.bounds.size.width
        let itemSize = (collectionViewLayout as! UICollectionViewFlowLayout).itemSize
        
        var size = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
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
