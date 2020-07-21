//
//  DetailViewController.swift
//  Project1
//
//  Created by MacBook on 09/04/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//
import WebKit
import UIKit

class DetailViewController: UIViewController, WKNavigationDelegate {
   
    var webView: WKWebView!
    var progressView: UIProgressView!
    var pageToLoad: String?
     
   
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
            
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload))
        let goBack = UIBarButtonItem(title: "<-", style: .plain, target: webView, action: #selector(webView.goBack))
        let goForward = UIBarButtonItem(title: "->", style: .plain, target: webView, action: #selector(webView.goForward))

     
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        toolbarItems = [progressButton, spacer, goBack, spacer, goForward, spacer, refresh]
        navigationController?.isToolbarHidden = false
        
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        let url = URL(string: "https://" + pageToLoad!)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url
        let ac = UIAlertController(title: "Adres niezgodny z hostem strony, debilu.", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Sam jesteś debil", style: .cancel))
        // We can put the alert when the site is not allowed if we want to.
        if let host = url?.host { // 'host' is lowercased by default, so if we want APPLE.COM to load, we need to write 'url?.host?.uppercased()' - however, then the other lowercased links won't load.
            if host.contains(pageToLoad!) {
                decisionHandler(.allow)
                print("WEBSITE ALLOWED")
                return
            }
        }
        decisionHandler(.cancel)
        print("WEBSITE NOT ALLOWED")
    } // The reason why in certain cases we get both print messages at the same time is that we get the "WEBSITE ALLOWED" for the main layout of the website, but inside there may be other elements than the standard ones like CSS/HTML/etc. - for example YouTube or Google Map windows imbedded in the webpage layout. For those, their host DOES NOT contain our webpage, so we get the warning.
     // So, the host of "www.hackingwithswift.com" is "www.hackingwithswift.com". The host of "www.wp.pl/film/4.mp4" is "www.wp.pl". As long as the loaded webpage contains "hackingwithswift.com" or "wp.pl", it will load, without the outside hosts though (like, for example, embedded YouTube videos - the page will be blank there).
}
    
    
    


