//
//  ViewController.swift
//  Project39
//
//  Created by Mateusz Zacharski on 30/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit

class ViewController: UITableViewController, UITextFieldDelegate {
    var playData = PlayData() // that line creates the object immediately, which in turn will call the 'init()' method to load the word data.
    var filterTextField: UITextField!
    var filterButton: UIAlertAction!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playData.filteredWords.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let word = playData.filteredWords[indexPath.row]
        cell.textLabel!.text = word
        cell.detailTextLabel!.text = "\(playData.wordCounts.count(for: word))" // show the count for each word in subtitle text.
        
        return cell
    }
    
    @objc func searchTapped() {
        let ac = UIAlertController(title: "Filter...", message: nil, preferredStyle: .alert)
        ac.addTextField { (textField) in
            self.filterTextField = textField
            self.filterTextField.placeholder = "Filter"
            self.filterTextField.delegate = self
            
            // Block the user from entering empty string by disabling the button:
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: self.filterTextField, queue: OperationQueue.main) { (notification) in
                
                if self.filterTextField.text!.isEmpty {
                    self.filterButton.isEnabled = false
                } else {
                    self.filterButton.isEnabled = true
                }
            }
        }
        
        filterButton = UIAlertAction(title: "Filter", style: .default) { [unowned self] _ in
            let userInput = self.filterTextField.text ?? "0" // 'userInput' will always be a 'String' and not a 'String?': it will either be something the user entered, or "0".
            self.playData.applyUserFilter(userInput)
            if self.playData.filteredWords.count == 0 {
                self.showNoResultsAlert()
            } else {
                self.tableView.reloadData()
            }
        }
        
        ac.addAction(filterButton)
        filterButton.isEnabled = false
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        present(ac, animated: true)
    }
    
    func showNoResultsAlert() {
        let ac = UIAlertController(title: "No results found!", message: "Try again", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
}

