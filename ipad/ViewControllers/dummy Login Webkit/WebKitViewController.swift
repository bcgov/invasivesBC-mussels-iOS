//
//  WebKitViewController.swift
//  ipad
//
//  Created by Amir Shayegh on 2020-04-06.
//  Copyright © 2020 Amir Shayegh. All rights reserved.
//

import UIKit
import WebKit

class WebKitViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {
    
    // MARK: Variables
    private var initialURL: URL = URL(string:"https://www.bceid.ca/register/")!
    
    // MARK: Outlets
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var lockIcon: UIImageView!
    @IBOutlet weak var navbar: UIView!
    
    // MARK: ViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        addressLabel.text = ""
        lockIcon.alpha = 0
        navbar.backgroundColor = Colors.primary
        webview.uiDelegate = self
        webview.navigationDelegate = self
        let myRequest = URLRequest(url: initialURL)
        webview.load(myRequest)
    }
    
    // MARK: Outlet Actions
    @IBAction func closeButtonAction(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Setup
    public func setInitial(url: URL) {
        self.initialURL = url
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard let route = webView.url else { return }
        self.addressLabel.text = route.absoluteString
        lockIcon.alpha = route.absoluteString.contains("https") ? 1 : 0
    }
}
