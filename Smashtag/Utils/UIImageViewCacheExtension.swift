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
var AssociatedURLOfImageKey: UInt8 = 0
var AssociatedSpinnerKey: UInt8 = 0

extension UIImageView {
    func setImage(URL: NSURL, placeholderImage: UIImage?) {
        setImage(URL, placeholderImage: placeholderImage, showSpinner:false, success: nil, failure: nil)
    }
    
    func setImage(URL: NSURL, showSpinner: Bool) {
        setImage(URL, placeholderImage: nil, showSpinner: showSpinner, success: nil, failure: nil)
    }
    
    private func setImage(URL: NSURL, placeholderImage: UIImage?, showSpinner: Bool, success: (Void -> Void)?, failure: (NSError -> Void)?) {
        // Helper to create errors
        var createError: (code: Int) -> NSError = {
            return NSError(domain: NSBundle.mainBundle().bundleIdentifier!, code: $0, userInfo: nil)
        }
        
        // Store URL before start asynchronous download of image
        URLOfImage = URL
        // In reuse imageView case: setting placeholder or nil to clear image
        image = placeholderImage;
        
        // Optional can to add spinner
        if showSpinner { spinner = createSpinner() }
        
        if let cachedImageData = NSCache.sharedInstance.objectForKey(URL) as? NSData {
            // Get image from cache
            if let cachedImage = UIImage(data: cachedImageData) {
                image = cachedImage
                spinner?.stopAnimating()
                success?()
            } else {
                spinner?.stopAnimating()
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
                                self.spinner?.stopAnimating()
                                success?()
                            } else {
                                self.spinner?.stopAnimating()
                                failure?(createError(code: NSURLErrorDownloadDecodingFailedToComplete))
                            }
                        }
                    }
                } else {
                    self.spinner?.stopAnimating()
                    failure?(error!)
                }
            }
        }
    }
    
    // MARK: - Helpers
    private var URLOfImage: NSURL? {
        get {
            return objc_getAssociatedObject(self, &AssociatedURLOfImageKey) as? NSURL
        }
        set {
            objc_setAssociatedObject(self, &AssociatedURLOfImageKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
    private var spinner: UIActivityIndicatorView? {
        get {
            return objc_getAssociatedObject(self, &AssociatedSpinnerKey) as? UIActivityIndicatorView
        }
        set {
            objc_setAssociatedObject(self, &AssociatedSpinnerKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
        }
    }
    
    private func createSpinner() -> UIActivityIndicatorView {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        spinner.color = UIColor.blackColor()
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        addSubview(spinner)
        
        // Create constraints for spinner
        spinner.setTranslatesAutoresizingMaskIntoConstraints(false)
        let centerXConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: spinner, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
        let centerYConstraint = NSLayoutConstraint(item: self, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: spinner, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0.0)
        addConstraints([centerXConstraint, centerYConstraint])
        
        return spinner
    }
}