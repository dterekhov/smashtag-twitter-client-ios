//
//  ImageViewController.swift
//  Smashtag
//
//  Created by Dmitry Terekhov on 19.07.15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController, UIScrollViewDelegate {
    // MARK: - Members
    private var imageView = UIImageView()
    @IBOutlet private weak var scrollView: UIScrollView!
    
    // MARK: - Public API
    var image: UIImage? {
        didSet {
            refreshUI()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.addSubview(imageView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshUI()
    }
    
    // MARK: - Setups
    private func refreshUI() {
        if scrollView == nil {
            return
        }
        imageView.image = image
        imageView.sizeToFit()
        imageView.frame.origin = CGPointZero
        scrollView.contentSize = imageView.frame.size
        println(scrollView.contentSize)
        autoZoomed = true
        zoomScaleToFit()
    }
    
    // MARK: - Autozooming-to-fit
    private var autoZoomed = true
    
    private func zoomScaleToFit() {
        if !autoZoomed {
            return
        }
        if image != nil && imageView.bounds.size.width > 0 && scrollView.bounds.size.width > 0 {
            let widthRatio = scrollView.bounds.size.width / imageView.bounds.size.width
            let heightRatio = scrollView.bounds.size.height / imageView.bounds.size.height
            scrollView.minimumZoomScale = min(widthRatio, heightRatio)
            scrollView.zoomScale = max(widthRatio, heightRatio)
            scrollView.contentOffset = CGPoint(x: (imageView.frame.size.width - scrollView.frame.width) / 2,
                y: (imageView.frame.size.height - scrollView.frame.height) / 2)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewWillBeginZooming(scrollView: UIScrollView, withView view: UIView!) {
        autoZoomed = false
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // MARK: - UITapGestureRecognizer handler
    @IBAction private func scrollViewDoubleTap(sender: UITapGestureRecognizer) {
        scrollView.setZoomScale(scrollView.zoomScale > scrollView.minimumZoomScale ? scrollView.minimumZoomScale : scrollView.maximumZoomScale, animated: true)
        scrollView.contentOffset = CGPoint(x: (imageView.frame.size.width - scrollView.frame.width) / 2,
            y: (imageView.frame.size.height - scrollView.frame.height) / 2)
    }
}
