//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell
{
    var tweet: Tweet? {
        didSet {
            updateUI()
        }
    }
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    let profilePlaceholderImage = UIImage(named: "ProfilePlaceholderImg")
    
    func updateUI() {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
//        tweetProfileImageView?.image = profilePlaceholderImage
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet
        {
            tweetTextLabel?.text = tweet.text
            if tweetTextLabel?.text != nil  {
                for _ in tweet.media {
                    tweetTextLabel.text! += " 📷"
                }
            }
            
            tweetScreenNameLabel?.text = "\(tweet.user)" // tweet.user.description
            
            
            
//            if let profileImageURL = tweet.user.profileImageURL {
//                let indexPath = indexPathByCell(self)
//                
//                if let cachedImageData = NSCache.sharedInstance.objectForKey(profileImageURL) as? NSData {
//                    // Get image from cache
//                    tweetProfileImageView.image = UIImage(data: cachedImageData)
//                } else {
//                    let qos = Int(QOS_CLASS_USER_INITIATED.value)
//                    dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
//                        let profileImageData = NSData(contentsOfURL: profileImageURL)
//                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
//                            if indexPath == indexPathByCell(self) {
//                                if profileImageURL == tweet.user.profileImageURL && profileImageData != nil {
//                                    // Set image in cache
//                                    let cost = Int(round(Double(profileImageData!.length) / 1024)) // Image size in KiloBytes
//                                    NSCache.sharedInstance.setObject(profileImageData!, forKey: profileImageURL, cost: cost)
//                                    
//                                    self.tweetProfileImageView.image = UIImage(data: profileImageData!)
//                                } else {
//                                    self.tweetProfileImageView.image = self.profilePlaceholderImage
//                                }
//                            }
//                        }
//                    }
//                }
//            }
            
            
            
//            if let profileImageURL = tweet.user.profileImageURL {
//                let qos = Int(QOS_CLASS_USER_INITIATED.value)
//                dispatch_async(dispatch_get_global_queue(qos, 0)) { () -> Void in
//                    let profileImageData = (NSCache.sharedInstance.objectForKey(profileImageURL) as? NSData) ?? NSData(contentsOfURL: profileImageURL)
//                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
//                        if profileImageURL == tweet.user.profileImageURL && profileImageData != nil {
//                            // Set image in cache
//                            let cost = Int(round(Double(profileImageData!.length) / 1024)) // Image size in KiloBytes
//                            NSCache.sharedInstance.setObject(profileImageData!, forKey: profileImageURL, cost: cost)
//                            
//                            self.tweetProfileImageView.image = UIImage(data: profileImageData!)
//                        } else {
//                            self.tweetProfileImageView.image = nil//self.profilePlaceholderImage
//                        }
//                    }
//                }
//            }
            
            
            
            
            
            let formatter = NSDateFormatter()
            if NSDate().timeIntervalSinceDate(tweet.created) > 24*60*60 {
                formatter.dateStyle = NSDateFormatterStyle.ShortStyle
            } else {
                formatter.timeStyle = NSDateFormatterStyle.ShortStyle
            }
            tweetCreatedLabel?.text = formatter.stringFromDate(tweet.created)
        }

    }
}

//// MARK: -
//func tableViewByCell(cell: UITableViewCell) -> UITableView {
//    var view = cell.superview
//    while view != nil && !(view is UITableView) {
//        view = view!.superview
//    }
//    return view as! UITableView
//}
//
//func indexPathByCell(cell: UITableViewCell) -> NSIndexPath {
//    return tableViewByCell(cell).indexPathForRowAtPoint(cell.center)!
//}

// MARK: -
extension NSCache {
    class var sharedInstance : NSCache {
        struct Static {
            static let instance = NSCache()
        }
        return Static.instance
    }
}