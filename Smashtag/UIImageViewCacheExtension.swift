//
//  UIImageViewCacheExtension.swift
//  Smashtag
//
//  Created by Dmitry Terekhov on 09.07.15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import Foundation
import UIKit

extension NSCache {
    class var sharedInstance : NSCache {
        struct Static {
            static let instance = NSCache()
        }
        return Static.instance
    }
}

extension UIImageView {
    func setImage(URL: NSURL, placeholderImage: UIImage, completionHandler: (UIImage?, NSError?) -> Void) {
        image = placeholderImage;
        if let cachedImageData = NSCache.sharedInstance.objectForKey(URL) as? NSData {
            // Get image from cache
            image = UIImage(data: cachedImageData)
        } else {
            
//            var request: NSURLRequest = NSURLRequest(URL: URL)
//            let queue:NSOperationQueue = NSOperationQueue()
//            NSURLConnection.sendAsynchronousRequest(request, queue: queue, completionHandler:{ (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
//                
//            })
            
            
            
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
                var error: NSError?
                if let loadedImageData = NSData(contentsOfURL: URL, options: NSDataReadingOptions.DataReadingUncached, error: &error) {
                    // Set image in cache
                    let cost = Int(round(Double(loadedImageData.length) / 1024)) // Image size in KiloBytes
                    NSCache.sharedInstance.setObject(loadedImageData, forKey: URL, cost: cost)
                    
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if let loadedImage = UIImage(data: loadedImageData) {
                            completionHandler(loadedImage, nil)
                        } else {
                            let creatingImageError = NSError(domain: "SomeDomail", code: NSURLErrorDownloadDecodingFailedToComplete, userInfo: nil)
                            completionHandler(nil, creatingImageError)
                        }
                        
//                        let updateCell = tableView.cellForRowAtIndexPath(indexPath)
//                        if updateCell != nil {
//                            // Set image in imageView
//                            cell.tweetProfileImageView.image = UIImage(data: loadedImageData)
//                        }
                    }
                } else {
                    completionHandler(nil, error)
                }
            }
        }
    }
}