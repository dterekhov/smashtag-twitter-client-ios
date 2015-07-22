//
//  SearchResultSaver.swift
//  Smashtag
//
//  Created by Dmitry Terekhov on 05.07.15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import Foundation

class SearchQuerySaver {
    private struct Constants {
        static let savedQueriesKey = "savedQueriesKey"
        static let maxSavedQueriesCount = 10;
    }
    
    static func saveSearchQuery(queryString: String) {
        var savedQueries = lastSearchQueries()
        // Store only maxSavedQueriesCount
        if savedQueries.count == Constants.maxSavedQueriesCount {
            savedQueries.removeLast()
        }
        
        // Add only uniq queryString
        if !contains(savedQueries, queryString) {
            savedQueries.insert(queryString, atIndex: 0)
            NSUserDefaults.standardUserDefaults().setObject(savedQueries, forKey: Constants.savedQueriesKey)
        }
    }
    
    static func lastSearchQueries() -> [String] {
        if let savedQueries = NSUserDefaults.standardUserDefaults().arrayForKey(Constants.savedQueriesKey) as? [String]  {
            return savedQueries;
        }
        return []
    }
}