//
//  ImageTableViewCell.swift
//  Smashtag
//
//  Created by Dmitry Terekhov on 18.07.15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    // MARK: - Members
    @IBOutlet private weak var tweetImageView: UIImageView!
    
    // MARK: - Public API
    var URL: NSURL? {
        didSet {
            if URL != nil {
                tweetImageView.setImage(URL!, showSpinner: true)
            }
        }
    }
    
    var tweetImage: UIImage? {
        return tweetImageView.image
    }
}
