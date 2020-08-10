//
//  ViewController.swift
//  Project31
//
//  Created by MacBook on 06/07/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//
import WebKit
import UIKit

class ViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    @IBOutlet var addressBar: UITextField!
    @IBOutlet var stackView: UIStackView!
    
    weak var activeWebView: WKWebView? // It's weak because it might go away at any time if the user deletes it.
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setDefaultTitle()
        
        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWebView))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteWebView))
        navigationItem.rightBarButtonItems = [delete, add]
                
    }
    
    func setDefaultTitle() {
        title = "Multibrowser"
        
        addressBar.placeholder = "Enter URL"
    }

    @objc func addWebView() {
        let webView = WKWebView()
        webView.navigationDelegate = self
        
        stackView.addArrangedSubview(webView)
        
        let url = URL(string: "https://www.hackingwithswift.com")!
        webView.load(URLRequest(url: url))
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(webViewTapped))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
    }
    
    func addWebViewWithAddress(urlString: String) {
        let webView = WKWebView()
        webView.navigationDelegate = self
        
        stackView.addArrangedSubview(webView)
        
        let url = URL(string: urlString)!
        webView.load(URLRequest(url: url))
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(webViewTapped))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
    }
    
    func selectWebView(_ webView: WKWebView) {
        for view in stackView.arrangedSubviews {
            view.layer.borderWidth = 0
        }
        
        activeWebView = webView
        webView.layer.borderWidth = 3
        
        updateUI(for: webView)
    }
    
    @objc func deleteWebView() {
        // safely unwrap our webview:
        if let webView = activeWebView {
            if let index = stackView.arrangedSubviews.firstIndex(of: webView) {
                // We found the webview - remove it from the stack view and destroy it:
                webView.removeFromSuperview()
                
                if stackView.arrangedSubviews.count == 0 {
                    // go back to our defaul UI:
                    setDefaultTitle()
                    addressBar.text = ""
                } else {
                    //convert the Index value into an integer:
                    var currentIndex = Int(index)
                    
                    // if that was the last web view in the stack, go back one:
                    if currentIndex == stackView.arrangedSubviews.count {
                        currentIndex = stackView.arrangedSubviews.count - 1
                    }
                    
                    // find the web view at the current index and select/activate it:
                    if let newSelectedWebView = stackView.arrangedSubviews[currentIndex] as? WKWebView {
                        selectWebView(newSelectedWebView)
                    }
                }
            }
        }
    }
    
    @objc func webViewTapped(_ recognizer: UITapGestureRecognizer) {
        if let selectedWebView = recognizer.view as? WKWebView {
            selectWebView(selectedWebView)
        }
    }
    
    // We want our gesture recognizer to trigger alongside the recognizers built into the WKWebView, so we have to add this too:
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // We already set this view controller to be the delegate of the address bar, so we'll get sent the textFieldShouldReturn() delegate method when the user presses Return on their iPad keyboard. We're also going to call resignFirstResponder() on the text field so that the keyboard hides:
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // If the stackView is empty, we don't need to manually create a new web view, we just type the address into the address bar:
        if let address = addressBar.text {
            if address.contains(".") {
                if stackView.arrangedSubviews.count == 0 {
                    addWebViewWithAddress(urlString: "https://" + address)
                }
            }
        }
        
        if let webView = activeWebView, let address = addressBar.text {
            if let url = URL(string: "https://" + address) {
                webView.load(URLRequest(url: url))
            }
        }
        textField.resignFirstResponder()
        return true
    }
    
    // Tapping on the address bar selects the text:
    func textFieldDidBeginEditing(_ textField: UITextField) {
    
        textField.text?.removeFirst(textField.text!.count)
    }
    
    
    // In multitasking mode (split-screen) we have to detect when the size class has changed and update our stack view appropriately. When we have a regular horizontal size class - we'll use horizontal stacking. When we have a compact size class - we'll use vertical stacking:
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass == .compact {
            stackView.axis = .vertical
        } else {
            stackView.axis = .horizontal
        }
    }
    // This method will be called in two cases: when we selected a web view, and when we enter a page address (or change it by navigating on a website, like clicking a link for example).
    func updateUI(for webView: WKWebView) {
        title = webView.title
        addressBar.text = webView.url?.absoluteString ?? ""
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView == activeWebView {
            updateUI(for: webView)
        }
        // If the stackView is empty, we can just type in the address and then we get a new subview with the loaded page. Once it gets loaded, we automatically select it:
        if stackView.arrangedSubviews.count == 1 {
            if let webView = stackView.arrangedSubviews[0] as? WKWebView {
                 selectWebView(webView)
            }
        }
    }
    
    

}

