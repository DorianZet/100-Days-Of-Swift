//
//  AuthorCommitsViewController.swift
//  Project38
//
//  Created by Mateusz Zacharski on 29/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit

class AuthorCommitsViewController: UITableViewController {
    var authorCommits = [Commit]()
    var authorName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(authorName)"
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return authorCommits.count
    }
       
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = authorCommits[indexPath.row].message
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            var currentVCStack = self.navigationController?.viewControllers
            currentVCStack?.removeLast(2) // although this solution of navigation in the view controllers stack is not perfect, what it does is that it prevents the user from creating an endless stack of vc by tapping the bar button, entering the detail vc, then tapping the button again etc., etc.
            currentVCStack?.append(detailVC)

            detailVC.detailItem = authorCommits[indexPath.row]
            detailVC.pageToLoad = authorCommits[indexPath.row].url

            self.navigationController?.setViewControllers(currentVCStack!, animated: true)
        }
    }
}
