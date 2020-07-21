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

        let urlString: String
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "CREDITS", style: .plain, target: self, action: #selector(credits))
      let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchText))
      let clearFilterButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(clearFilter))
        navigationItem.rightBarButtonItems = [searchButton, clearFilterButton]

        
        if navigationController?.tabBarItem.tag == 0 {
            urlString = "https://www.hackingwithswift.com/samples/petitions-1.json"
        } else {
            urlString = "https://www.hackingwithswift.com/samples/petitions-2.json"
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let url = URL(string: urlString) {
                if let data = try? Data(contentsOf: url) {
                self?.parse(json: data)
                return
                }
            }
            self?.showError()
        }
    }
    
    // Inserting 'return' after the call to parse() means that the method would exit if parsing was reached, so if we get to the end of the method, it means parsing WASN'T reached and we can show the error. This is a cleaner way to show it. Alternatively, we could do this:
    // if let url = URL(string: urlString) {
    //     if let data = try? Data(contentsOf: url) {
    //         parse(json: data)
    //     } else {
    //         showError()
    //     }
    // } else {
    //     showError()
    // }
    
    
    func showError() {
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
        DispatchQueue.main.async { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
    func noFoundError() {
        DispatchQueue.main.async { [weak self] in
            let ac = UIAlertController(title: "No results found", message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(ac, animated: true)
        }
    }
    
    func submit(_ text: String) {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.filteredPetitions.removeAll()
            for item in self!.initialPetitions {
                if item.title.lowercased().contains("\(text.lowercased())") {
                    self?.filteredPetitions.append(item)
                }
            }
            self?.petitions.removeAll()
            self!.petitions += self!.filteredPetitions
            if self!.petitions.isEmpty {
                self?.noFoundError()
                self?.clearFilter()
            } else {
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            }
        }
    }
    
    func parse(json: Data) {
        let decoder = JSONDecoder()
        
        if let jsonPetitions = try? decoder.decode(Petitions.self, from: json) {
            petitions = jsonPetitions.results
            initialPetitions = jsonPetitions.results
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
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


