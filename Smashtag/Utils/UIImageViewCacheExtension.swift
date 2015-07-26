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

// Declare a global var to produce a unique address as the assoc object handle
var AssociatedObjectHandle: UInt8 = 0

extension UIImageView {
    private var URLOfImage:NSURL? {
        get {
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as? NSURL
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
    func setImage(URL: NSURL, placeholderImage: UIImage?) {
        setImage(URL, placeholderImage: placeholderImage, success: nil, failure: nil)
    }
    
    func setImage(URL: NSURL, placeholderImage: UIImage?, success: (Void -> Void)?, failure: (NSError -> Void)?) {
        // Helper to create errors
        var createError: (code: Int) -> NSError = {
            return NSError(domain: NSBundle.mainBundle().bundleIdentifier!, code: $0, userInfo: nil)
        }
        
        // Store URL before start asynchronous download of image
        URLOfImage = URL
        // In reuse imageView case: setting placeholder or nil to clear image
        image = placeholderImage;
        
        if let cachedImageData = NSCache.sharedInstance.objectForKey(URL) as? NSData {
            // Get image from cache
            if let cachedImage = UIImage(data: cachedImageData) {
                image = cachedImage
                success?()
            } else {
                failure?(createError(code: NSURLErrorCannotDecodeRawData))
            }
        } else {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
                var error: NSError?
                if let loadedImageData = NSData(contentsOfURL: URL, options: NSDataReadingOptions.DataReadingUncached, error: &error) {
                    // Set image in cache
                    let cost = Int(round(Double(loadedImageData.length) / 1024)) // Image size in KiloBytes
                    NSCache.sharedInstance.setObject(loadedImageData, forKey: URL, cost: cost)
                    
                    dispatch_async(dispatch_get_main_queue()) { () -> Void in
                        /* In reuse imageView case: sure that
                        imageViewBeforeAsynchronousDownload == imageViewAfterAsynchronousDownload
                        (verification by URL) */
                        if URL == self.URLOfImage {
                            if let loadedImage = UIImage(data: loadedImageData) {
                                self.image = loadedImage
                                success?()
                            } else {
                                failure?(createError(code: NSURLErrorDownloadDecodingFailedToComplete))
                            }
                        }
                    }
                } else {
                    failure?(error!)
                }
            }
        }
    }
}