//
//  WebViewController.swift
//  Smashtag
//
//  Created by Dmitry Terekhov on 21.07.15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
    private struct Constants {
        static let BackButtonImage = UIImage(named: "ico_back")
    }
    
    // MARK: - Members
    @IBOutlet private weak var webView: UIWebView! {
        didSet {
            if URL != nil {
                self.title = URL!.host
                webView.scalesPageToFit = true
                webView.loadRequest(NSURLRequest(URL: URL!))
            }
        }
    }
    @IBOutlet private weak var errorLabel: UILabel!
    
    // MARK: - Public API
    var URL: NSURL?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: Constants.BackButtonImage, style: UIBarButtonItemStyle.Plain, target: self, action: "navigateToPreviousWebPageOrVC:")
    }
    
    // MARK: - Users interaction
    @objc private func navigateToPreviousWebPageOrVC(sender: UIBarButtonItem) {
        if webView.canGoBack {
            webView.goBack()
        } else {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    // MARK: - UIWebViewDelegate
    func webViewDidStartLoad(webView: UIWebView) {
        
        errorLabel.hidden = true
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        errorLabel.hidden = false
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}