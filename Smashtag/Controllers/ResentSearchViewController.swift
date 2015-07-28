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
    private struct Storyboard {
        static let CellID = "RecentSearchTableViewCell"
        static let ShowTweetTVC = "ShowTweetTVC"
    }
    
    // MARK: - Members
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Lifecycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SearchQuerySaver.storedSearchQueries.count;
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Storyboard.CellID) as! UITableViewCell
        cell.textLabel?.text = SearchQuerySaver.storedSearchQueries[indexPath.row]
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            SearchQuerySaver.removeSearchQueryAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
        }
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let tweetTVC = segue.destinationViewController as? TweetTableViewController {
            if segue.identifier == Storyboard.ShowTweetTVC {
                if let cellText = (sender as? UITableViewCell)?.textLabel?.text {
                    tweetTVC.searchText = cellText
                    tweetTVC.title = cellText
                }
            }
        }
    }
}
