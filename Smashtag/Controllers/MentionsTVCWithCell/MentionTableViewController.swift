//
//  DetailTweetTableViewController.swift
//  Smashtag
//
//  Created by Dmitry Terekhov on 18.07.15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class MentionTableViewController: UITableViewController, UIActionSheetDelegate {
    // MARK: - Constants
    private struct Storyboard {
        // Cell's identifiers
        static let MentionTableViewCellID = "MentionTableViewCell"
        static let ImageMentionTableViewCellID = "ImageMentionTableViewCell"
        
        // Storyboard's segue identifiers
        static let ShowWebVC = "ShowWebVC"
    }
    
    private struct Constants {
        static let appName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String
        
        // Category names
        static let ImageCategoryName = "Images"
        static let HashtagCategoryName = "Hashtags"
        static let UserCategoryName = "Users"
        static let URLCategoryName = "URLs"
        
        // UIActionSheet button indexes
        static let OpenURLInsideApp = 1
        static let OpenURLInSafari = 2
    }
    
    // MARK: - Mention type
    private var mentionCategories = [MentionCategory]()
    
    private struct MentionCategory: Printable {
        var name: String
        var mentions: [Mention]
        var description: String { return "\(name): \(mentions)" }
    }
    
    private enum Mention: Printable {
        case Keyword(String) // Row name
        case Image(URL: NSURL, aspectRatio: Double)
        
        var description: String {
            switch self {
            case .Keyword(let keyword): return keyword
            case .Image(let URL, _): return URL.path!
            }
        }
    }
    
    // MARK: - Members
    private var openingURL: NSURL?
    
    // MARK: - Public API
    var tweet: Tweet? {
        didSet {
            // Create imageCategory
            if let imagesFromTweet = tweet?.media where imagesFromTweet.count > 0 {
                let imageCategory = MentionCategory(name: Constants.ImageCategoryName, mentions: imagesFromTweet.map({ Mention.Image(URL: $0.url, aspectRatio: $0.aspectRatio) }))
                mentionCategories.append(imageCategory)
            }
            // Create hashtagCategory
            if let hashtagsFromTweet = tweet?.hashtags where hashtagsFromTweet.count > 0 {
                let hashtagCategory = MentionCategory(name: Constants.HashtagCategoryName, mentions: hashtagsFromTweet.map({ Mention.Keyword($0.keyword) }))
                mentionCategories.append(hashtagCategory)
            }
            // Create userCategory
            if let usersFromTweet = tweet?.userMentions {
                // Add author user
                var userItems = [Mention.Keyword("@" + tweet!.user.screenName)]
                // Add other users
                if usersFromTweet.count > 0 {
                    userItems += usersFromTweet.map { Mention.Keyword($0.keyword) }
                }
                
                let userCategory = MentionCategory(name: Constants.UserCategoryName, mentions: userItems)
                mentionCategories.append(userCategory)
            }
            // Create URLCategory
            if let URLsFromTweet = tweet?.urls where URLsFromTweet.count > 0 {
                let URLsCategory = MentionCategory(name: Constants.URLCategoryName, mentions: URLsFromTweet.map({ Mention.Keyword($0.keyword) }))
                mentionCategories.append(URLsCategory)
            }
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - TableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return mentionCategories.count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentionCategories[section].name;
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionCategories[section].mentions.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let mention = mentionCategories[indexPath.section].mentions[indexPath.row]
        switch (mention) {
        case .Image(_, let aspectRatio):
            return tableView.bounds.size.width / CGFloat(aspectRatio)
        default:
            return UITableViewAutomaticDimension
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let mention = mentionCategories[indexPath.section].mentions[indexPath.row]
        switch (mention) {
        case .Keyword(let keyword):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.MentionTableViewCellID, forIndexPath: indexPath) as! UITableViewCell
            cell.textLabel?.text = keyword
            return cell
        case .Image(let URL, _):
            let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.ImageMentionTableViewCellID, forIndexPath: indexPath) as! ImageTableViewCell
            cell.URL = URL
            return cell
        }
    }
    
    // MARK: - Navigation
    override func shouldPerformSegueWithIdentifier(identifier: String?, sender: AnyObject?) -> Bool {
        if let categoryWithMentionTuple = categoryWithMentionByTappedSender(sender) {
            switch (categoryWithMentionTuple.category.name) {
            // Can perform segue: Never
            case Constants.URLCategoryName:
                switch (categoryWithMentionTuple.mention) {
                case .Keyword(let keyword):
                    openingURL = NSURL(string: keyword)!
                    let test = Constants.appName
                    let openURLActionSheet = UIActionSheet(title: "Open URL in", delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: Constants.appName, "Safari");
                    openURLActionSheet.showInView(self.view)
                    return false
                default:
                    return false
                }
            // Can perform segue: Always
            case Constants.HashtagCategoryName, Constants.UserCategoryName: return true
            // Can perform segue: Only if image is set
            case Constants.ImageCategoryName:
                return (sender as? ImageTableViewCell)?.tweetImage != nil
            // Can perform segue for unknown Caterory's names: Never
            default: return false
            }
        }
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let categoryWithMentionTuple = categoryWithMentionByTappedSender(sender) {
            switch (categoryWithMentionTuple.mention) {
            case .Keyword(var keyword):
                if let tweetTVC = segue.destinationViewController as? TweetTableViewController {
                    tweetTVC.title = self.title
                    if categoryWithMentionTuple.category.name == Constants.UserCategoryName {
                        keyword += " OR from:" + keyword
                    }
                    tweetTVC.searchText = keyword
                }
            case .Image(_, _):
                if let imageCell = sender as? ImageTableViewCell {
                    if let imageVC = segue.destinationViewController as? ImageViewController {
                        imageVC.title = self.title
                        imageVC.image = imageCell.tweetImage
                    }
                }
            }
        } else if segue.identifier == Storyboard.ShowWebVC {
            if let webVC = segue.destinationViewController as? WebViewController where openingURL != nil {
                webVC.URL = openingURL
            }
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if buttonIndex == Constants.OpenURLInsideApp {
            performSegueWithIdentifier(Storyboard.ShowWebVC, sender: actionSheet)
        } else if buttonIndex == Constants.OpenURLInSafari {
            UIApplication.sharedApplication().openURL(openingURL!)
        }
        openingURL = nil
    }
    
    // MARK: - Helpers
    private func categoryWithMentionByTappedSender(sender: AnyObject?) -> (category: MentionCategory, mention: Mention)? {
        if let cell = sender as? UITableViewCell {
            if let indexPath = tableView.indexPathForCell(cell) {
                let category = mentionCategories[indexPath.section]
                return (category, category.mentions[indexPath.row])
            }
        }
        return nil
    }
}