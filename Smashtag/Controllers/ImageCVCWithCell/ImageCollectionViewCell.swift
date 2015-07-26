//
//  ImageCollectionViewCell.swift
//  Smashtag
//
//  Created by Dmitry Terekhov on 26.07.15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

struct TweetMedia: Printable {
    var tweet: Tweet
    var mediaItem: MediaItem
    var description: String { return "\(tweet): \(mediaItem)" }
}

class ImageCollectionViewCell: UICollectionViewCell {
    // MARK: - Members
    @IBOutlet private weak var imageView: UIImageView!
    
    // MARK: - Public API
    var tweetMedia: TweetMedia? {
        didSet {
            if let URL = tweetMedia?.mediaItem.url {
                imageView.setImage(URL, showSpinner: true)
            }
        }
    }
}
