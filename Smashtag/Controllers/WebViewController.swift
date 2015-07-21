//
//  WebViewController.swift
//  Smashtag
//
//  Created by Dmitry Terekhov on 21.07.15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {
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
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var backToRootItem: UIBarButtonItem!
    
    // MARK: - Public API
    var URL: NSURL?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Rewind, target: self, action: "navigateToPreviousWebPage:")
        let forwardItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FastForward, target: self, action: "navigateToForwardWebPage:")
        let refreshItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refreshWebPage:")
        navigationItem.rightBarButtonItems = [backToRootItem, refreshItem, forwardItem, backItem]
    }
    
    // MARK: - BarButtonItem actions
    @objc private func navigateToPreviousWebPage(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @objc private func navigateToForwardWebPage(sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    @objc private func refreshWebPage(sender: UIBarButtonItem) {
        webView.reload()
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