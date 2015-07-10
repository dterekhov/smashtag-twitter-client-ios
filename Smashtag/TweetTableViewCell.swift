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
    let profilePlaceholderImage = UIImage(named: "ProfilePlaceholderImg")
    private(set) var tweet: Tweet?
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    func setup(tweet: Tweet, tableView: UITableView, indexPath: NSIndexPath) {
        self.tweet = tweet
        
        // Setup image field
        if let profileImageURL = tweet.user.profileImageURL {
            tweetProfileImageView.setImage(profileImageURL, placeholderImage: profilePlaceholderImage, success: {
                if let updateCell = tableView.cellForRowAtIndexPath(indexPath) as? TweetTableViewCell {
                    updateCell.tweetProfileImageView.image = $0
                }
                }, failure: nil)
        }
        
        // Setup other fields
        setupTextFields(tweet)
    }
    
    private func setupTextFields(tweet: Tweet) {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
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