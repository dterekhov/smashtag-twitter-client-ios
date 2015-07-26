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
    
    var tweets: [[Tweet]] = [] {
        didSet {
            images = tweets.flatMap({ $0 })
                .map { tweet in
                    tweet.media.map { TweetMedia(tweet: tweet, mediaItem: $0) }
                    }.flatMap({ $0 })
        }
    }
    
    private var images = [TweetMedia]()
    
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
        
        var size = CGSize(width: itemSize.width * 1, height: itemSize.height * 1)
        if ratio > 1 {
            size.height /= ratio
        } else {
            size.width *= ratio
        }
        
        if size.width > collectionViewWidth {
            size.width = collectionViewWidth
            size.height = size.width / ratio
        }
        return size
    }
}
