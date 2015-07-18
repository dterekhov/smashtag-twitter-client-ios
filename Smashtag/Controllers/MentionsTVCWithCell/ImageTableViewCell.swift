//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Dmitry Terekhov on 18.07.15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
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
}
