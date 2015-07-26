//
//  TweetTableViewController.swift
//  Smashtag
//
//  Created by CS193p Instructor.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class TweetTableViewController: UITableViewController, UITextFieldDelegate
{
    private struct Storyboard {
        static let CellReuseIdentifier = "Tweet"
        static let showMentionVC = "showMentionVC"
        static let showImageCVC = "showImageCVC"
    }
    
    // MARK: - Public API
    var tweets = [[Tweet]]()

    var searchText: String? = "#stanford" {
        didSet {
            lastSuccessfulRequest = nil
            searchTextField?.text = searchText
            tweets.removeAll()
            tableView.reloadData() // clear out the table view
            refresh()
        }
    }
    
    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = tableView.rowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "contentSizeCategoryDidChanged", name:UIContentSizeCategoryDidChangeNotification, object: nil)
        
        if tweets.count == 0 {
            refresh()
        } else {
            showImagesButton.enabled = true // Can segue by button tap if tweets.count > 0
            searchTextField.text = ""
            let tweet = tweets.first!.first!
            title = "Tweets by " + tweet.user.name
            tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.None)
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    @objc private func contentSizeCategoryDidChanged() {
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    // MARK: - Refreshing
    private var lastSuccessfulRequest: TwitterRequest?

    private var nextRequestToAttempt: TwitterRequest? {
        if lastSuccessfulRequest == nil {
            if searchText != nil {
                SearchQuerySaver.saveSearchQuery(searchText!)
                return TwitterRequest(search: searchText!, count: 100)
            } else {
                return nil
            }
        } else {
            return lastSuccessfulRequest!.requestForNewer
        }
    }
    
    @IBAction private func refresh(sender: UIRefreshControl?) {
        if let request = nextRequestToAttempt {
            request.fetchTweets { (newTweets) -> Void in
                dispatch_async(dispatch_get_main_queue()) { () -> Void in
                    if newTweets.count > 0 {
                        self.lastSuccessfulRequest = request // oops, forgot this line in lecture
                        self.tweets.insert(newTweets, atIndex: 0)
                        self.showImagesButton.enabled = true // Can segue by button tap if tweets.count > 0
                        self.tableView.reloadData()
                    }
                    sender?.endRefreshing()
                }
            }
        } else {
            sender?.endRefreshing()
        }
    }
    
    func refresh() {
        refreshControl?.beginRefreshing()
        refresh(refreshControl)
    }
    
    // MARK: - Storyboard Connectivity
    @IBOutlet private weak var searchTextField: UITextField! {
        didSet {
            searchTextField.delegate = self
            searchTextField.text = searchText
        }
    }
    
    @IBOutlet weak var showImagesButton: UIButton!
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
    // MARK: - UITableViewDataSource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tweets.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellReuseIdentifier, forIndexPath: indexPath) as! TweetTableViewCell
        cell.setup(tweets[indexPath.section][indexPath.row])
        return cell
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let mentionsTVC = segue.destinationViewController as? MentionTableViewController where segue.identifier == Storyboard.showMentionVC {
            if let cell = sender as? TweetTableViewCell {
                mentionsTVC.tweet = cell.tweet
                mentionsTVC.title = "\(cell.tweet!.user)"
            }
        } else if let imageCVC = segue.destinationViewController as? ImageCollectionViewController where segue.identifier == Storyboard.showImageCVC {
            imageCVC.tweets = tweets
        }
    }
}
