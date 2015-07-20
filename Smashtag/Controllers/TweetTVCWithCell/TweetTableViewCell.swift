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
    private struct Pallete {
        static let HashtagColor = UIColor.brownColor()
        static let URLColor = UIColor.blueColor()
        static let UserColor = UIColor.purpleColor()
    }
    
    let profilePlaceholderImage = UIImage(named: "ProfilePlaceholderImg")
    private(set) var tweet: Tweet?
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetScreenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    // MARK: - Setups
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
        setupFont()
    }
    
    private func setupTextFields(tweet: Tweet) {
        // reset any existing tweet information
        tweetTextLabel?.attributedText = nil
        tweetScreenNameLabel?.text = nil
        tweetCreatedLabel?.text = nil
        
        // load new information from our tweet (if any)
        if let tweet = self.tweet
        {
            setupTweetTextLabel(tweet)
            
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
    
    private func setupTweetTextLabel(tweet: Tweet) {
        // Create text to colorize
        var tweetText: String = tweet.text
        for _ in tweet.media { tweetText += " 📷" }
        var attributtedText = NSMutableAttributedString(string: tweet.text)
        
        // Colorize text
        colorizeAttributedStringByKeywords(&attributtedText, keywords: tweet.hashtags, highlightingColor: Pallete.HashtagColor)
        colorizeAttributedStringByKeywords(&attributtedText, keywords: tweet.urls, highlightingColor: Pallete.URLColor)
        colorizeAttributedStringByKeywords(&attributtedText, keywords: tweet.userMentions, highlightingColor: Pallete.UserColor)
        tweetTextLabel.attributedText = attributtedText
    }
    
    private func setupFont() {
        tweetScreenNameLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        tweetTextLabel.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    }
    
    // MARK: - Utils
    private func colorizeAttributedStringByKeywords(inout attributedString: NSMutableAttributedString, keywords: [Tweet.IndexedKeyword], highlightingColor: UIColor) {
        for keyword in keywords {
            attributedString.addAttribute(NSForegroundColorAttributeName, value: highlightingColor, range: keyword.nsrange)
        }
    }
}