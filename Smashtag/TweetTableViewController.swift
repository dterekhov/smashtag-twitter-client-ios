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
        refresh()
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == searchTextField {
            textField.resignFirstResponder()
            searchText = textField.text
        }
        return true
    }
    
    private struct Storyboard {
        static let CellReuseIdentifier = "Tweet"
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

        cell.tweet = tweets[indexPath.section][indexPath.row]
        
        
        
//        if let profileImageURL = cell.tweet!.user.profileImageURL {
//            cell.tweetProfileImageView.image = nil;
//            if let cachedImageData = NSCache.sharedInstance.objectForKey(profileImageURL) as? NSData {
//                // Get image from cache
//                cell.tweetProfileImageView.image = UIImage(data: cachedImageData)
//            } else {
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
//                    if let profileImageData = NSData(contentsOfURL: profileImageURL) {
//                        // Set image in cache
//                        let cost = Int(round(Double(profileImageData.length) / 1024)) // Image size in KiloBytes
//                        NSCache.sharedInstance.setObject(profileImageData, forKey: profileImageURL, cost: cost)
//                        
//                        dispatch_async(dispatch_get_main_queue()) { () -> Void in
//                            let updateCell = tableView.cellForRowAtIndexPath(indexPath)
//                            if updateCell != nil {
//                                // Set image in imageView
//                                updateCell.tweetProfileImageView.image = UIImage(data: profileImageData)
//                            }
//                        }
//                    }
//                }
//            }
//        }
        
        if let profileImageURL = cell.tweet!.user.profileImageURL {
            let profilePlaceholderImage = UIImage(named: "ProfilePlaceholderImg")
            cell.tweetProfileImageView.setImage(profileImageURL, placeholderImage: profilePlaceholderImage!) { (image, error) -> Void in
                if error != nil {
                    println(error)
                    return
                }
                if image != nil {
                    if let updateCell = tableView.cellForRowAtIndexPath(indexPath) as? TweetTableViewCell {
                        updateCell.tweetProfileImageView.image = image
                    }
                }
            }
        }

        return cell
    }
}
