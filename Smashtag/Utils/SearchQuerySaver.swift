//
//  SearchResultSaver.swift
//  Smashtag
//
//  Created by Dmitry Terekhov on 05.07.15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import Foundation

class SearchQuerySaver {
    // MARK: - Constants
    private struct Constants {
        static let storedQueriesKey = "savedQueriesKey"
        static let maxSavedQueriesCount = 10;
    }
    
    private static let userDefaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: - Public API
    static func saveSearchQuery(queryString: String) {
        // Remove item if exist
        var localQueries = storedSearchQueries
        if let existQueryIndex = find(localQueries, queryString) {
            localQueries.removeAtIndex(existQueryIndex)
        }
        
        // Add new item
        localQueries.insert(queryString, atIndex: 0)
        // Clear old overflow items
        while localQueries.count > Constants.maxSavedQueriesCount {
            localQueries.removeLast()
        }
        
        // Save
        storedSearchQueries = localQueries
    }
    
    static func removeSearchQueryAtIndex(index: Int) {
        var localQueries = storedSearchQueries
        localQueries.removeAtIndex(index)
        storedSearchQueries = localQueries
    }
    
    static var storedSearchQueries: [String] {
        get { return userDefaults.arrayForKey(Constants.storedQueriesKey) as? [String] ?? [] }
        set { userDefaults.setObject(newValue, forKey: Constants.storedQueriesKey) }
    }
}