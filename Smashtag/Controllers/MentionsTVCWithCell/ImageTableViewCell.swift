//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Dmitry Terekhov on 18.07.15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    @IBOutlet private weak var tweetImageView: UIImageView!
    @IBOutlet private weak var spinner: UIActivityIndicatorView!
    
    // MARK: - Public API
    var URL: NSURL? {
        didSet {
            if URL == nil { return }
            
            tweetImageView.setImage(URL!, placeholderImage: nil, success: {
                self.tweetImageView.image = $0
                self.spinner.stopAnimating()
                }, failure: { (_) -> () in
                    self.spinner.stopAnimating()
            })
        }
    }
    
    var tweetImage: UIImage? {
        return tweetImageView.image
    }
}
