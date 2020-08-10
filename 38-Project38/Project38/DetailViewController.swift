//
//  DetailViewController.swift
//  Project38
//
//  Created by Mateusz Zacharski on 25/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import WebKit
import UIKit

class DetailViewController: UIViewController, WKNavigationDelegate {
    @IBOutlet var detailLabel: UILabel!
    var detailItem: Commit?
    
    var webView: WKWebView!
    var pageToLoad: String?
        
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let detail = self.detailItem {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Commit 1/\(detail.author.commits.count)", style: .plain, target: self, action: #selector(showAuthorCommits))
        }
        
        let url = URL(string: pageToLoad!)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    @objc func showAuthorCommits() {
        if let detail = self.detailItem {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "AuthorCommits") as? AuthorCommitsViewController {
                vc.authorCommits = detail.author.commits.array as! [Commit]
                vc.authorName = detail.author.name
                navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}



    
       
