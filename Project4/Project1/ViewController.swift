//
//  ViewController.swift
//  Project1
//
//  Created by MacBook on 08/04/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UITableViewController {
    @IBOutlet var ViewController: UITableView!
    
    var websites = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let startWordsURL = Bundle.main.url(forResource: "webpageList", withExtension: "txt") {
            if let websitesInDoc = try? String(contentsOf: startWordsURL) {
                websites = websitesInDoc.components(separatedBy: "\n")
            }
        }
        title = "Websites"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        print(websites)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return websites.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Website", for: indexPath)
        cell.textLabel?.text = websites[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.pageToLoad = websites[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
}

