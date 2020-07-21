//
//  DetailViewController.swift
//  Project16
//
//  Created by MacBook on 23/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
var webView: WKWebView!
var pageToLoad: String?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black // The background color is black at the beginning of loading the view.
        
        webView.alpha = 0 // Setting the view alpha to 0
        navigationController?.navigationBar.alpha = 0 // Setting the navBar alpha to 0
        let url = URL(string: "https://" + pageToLoad!)!
        webView.load(URLRequest(url: url))
        // Fade-in animation when loading the view:
        webView.allowsBackForwardNavigationGestures = true
        UIView.animate(withDuration: 1, animations: {
            self.view.backgroundColor = .white // The background slowly becomes white when loading (so does the navBar).
            self.webView.alpha = 1
            self.navigationController?.navigationBar.alpha = 1
        })
    }
}
