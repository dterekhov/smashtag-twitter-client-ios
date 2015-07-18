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
    func setImage(URL: NSURL, placeholderImage: UIImage?, success: (UIImage -> Void)?, failure: (NSError -> Void)?) {
        image = placeholderImage;
        if let cachedImageData = NSCache.sharedInstance.objectForKey(URL) as? NSData {
            // Get image from cache
            success?(UIImage(data: cachedImageData)!)
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
                var error: NSError?
                if let loadedImageData = NSData(contentsOfURL: URL, options: NSDataReadingOptions.DataReadingUncached, error: &error) {
                    // Set image in cache
                    let cost = Int(round(Double(loadedImageData.length) / 1024)) // Image size in KiloBytes
                    NSCache.sharedInstance.setObject(loadedImageData, forKey: URL, cost: cost)
                    
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        if let loadedImage = UIImage(data: loadedImageData) {
                            success?(loadedImage)
                        } else {
                            let creatingImageError = NSError(domain: "SomeDomain", code: NSURLErrorDownloadDecodingFailedToComplete, userInfo: nil)
                            failure?(creatingImageError)
                        }
                    }
                } else {
                    failure?(error!)
                }
            }
        }
    }
}