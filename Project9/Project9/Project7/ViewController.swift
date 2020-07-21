//
//  ViewController.swift
//  Project7
//
//  Created by MacBook on 25/04/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var petitions = [Petition]()
    var filteredPetitions = [Petition]()
    var initialPetitions = [Petition]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "CREDITS", style: .plain, target: self, action: #selector(credits))
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchText))
        let clearFilterButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(clearFilter))
        navigationItem.rightBarButtonItems = [searchButton, clearFilterButton]
        
        performSelector(inBackground: #selector(fetchJSON), with: nil) // That means: run the fetchJSON() method on the current object - our view controller - in the background.
    }
    
    @objc func fetchJSON() {
        let urlString: String
          
        if navigationController?.tabBarItem.tag == 0 {
              urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
          } else {
              urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
          }
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                return
            }
        }
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    
    
    @objc func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem loading the feed. Please check your connection and try again", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func credits() {
        let ac = UIAlertController(title: "CREDITS", message: """
        The gathered data comes from
        the We The People API of the Whitehouse.
        """, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func searchText() {
           let ac = UIAlertController(title: "What are you looking for?", message: nil, preferredStyle: .alert)
           ac.addTextField()
           
            let searchPrompt = UIAlertAction(title: "Search", style: .default) {
            [weak self, weak ac] _ in
                       guard let text = ac?.textFields?[0].text else { return }
                       self?.submit(text)
            }
        let cancelPrompt = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addAction(searchPrompt)
        ac.addAction(cancelPrompt)
        present(ac, animated: true)
    }
    
    @objc func clearFilter() {
        petitions.removeAll()
        petitions += initialPetitions
        tableView.reloadData()
    }
    
    func noFoundError() {
        let ac = UIAlertController(title: "No results found", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func submit(_ text: String) {
        filteredPetitions.removeAll()
        for item in initialPetitions {
            if item.title.lowercased().contains("\(text.lowercased())") {
                filteredPetitions.append(item)
            }
        }
        petitions.removeAll()
        petitions += filteredPetitions
        if petitions.isEmpty {
            noFoundError()
        } else {
        tableView.reloadData()
        }
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            initialPetitions = jsonPetitions.results
            
            tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        } else {
            performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return petitions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let petition = petitions[indexPath.row]
        cell.textLabel?.text = petition.title
        cell.detailTextLabel?.text = petition.body
        return cell

    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DetailViewController()
        // Because in this project DetailViewController isn't in the storyboard (it's just a free-floating class), didSelectRowAt can load the class directly, so we don't have to use the instantiateViewController() method.
        vc.detailItem = petitions[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
 

}


