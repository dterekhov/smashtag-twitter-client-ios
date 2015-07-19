//
//  ResentSearchViewController.swift
//  Smashtag
//
//  Created by Dmitry Terekhov on 05.07.15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit
import Foundation

class ResentSearchViewController: UIViewController, UITableViewDataSource {
    private struct Constants {
        static let CellIdentifier = "RecentSearchTableViewCell"
        static let SelectRowSegue = "ShowTweetTVC"
    }
    
    @IBOutlet weak var tableView: UITableView!
    var searchQueries = [String]();
    
    // MARK: - Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        searchQueries = SearchQuerySaver.lastSearchQueries()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchQueries.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.CellIdentifier) as! UITableViewCell
        cell.textLabel?.text = searchQueries[indexPath.row]
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tweetTVC = segue.destinationViewController as? TweetTableViewController {
            if segue.identifier == Constants.SelectRowSegue {
                if let cellText = (sender as? UITableViewCell)?.textLabel?.text {
                    tweetTVC.searchText = cellText
                    tweetTVC.title = cellText
                }
            }
        }
    }
}
