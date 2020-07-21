//
//  DetailViewController.swift
//  Project7
//
//  Created by MacBook on 26/04/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    var webView: WKWebView!
    var detailItem: Petition?
    
    override func loadView() {
        webView = WKWebView()
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let detailItem = detailItem else { return }
        //IMPORTANT: That 'guard' at the beginning unwraps 'detailItem' into itself if it has a value, which makes sure we exit the method if for some reason we didn't get any data passed into the detail view controller. TL;DR: If 'detailItem' doesn't have a value (for example, servers are offline), the code below won't be executed.
        
        // We can name this 'guard let' whatever we want, it doesn't have to be 'detailItem'. When you make it 'dupa', remember that below \(detailItem.body) has to be changed to \(dupa.body) as well. However, it's very common to unwrap variables using the same name, rather than create slight variations.
        let html = """
        <html>
        <head>
        <meta name = "viewport" content="width=device=width, initial-scale=1">
        <style>
        p { font-size: 150%; }
        p { text-align: justify; text-justify: inter-word; }
        p { font-family: Arial; }
        h1 { text-align: center; text-center: inter-word; }
        h1 { font-family: Arial; }
        </style>
        </head>
        <body>
        <h1>\(detailItem.title)</h1>
        <p>\(detailItem.body)</p>
        </body>
        </html>
        """
        
        webView.loadHTMLString(html, baseURL: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
