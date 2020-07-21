//
//  ViewController.swift
//  Day 74. Milestone
//
//  Created by MacBook on 06/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
var notes = [Note]()

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let showDetailViewButton = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(showDetailView))
        showDetailViewButton.tintColor = .brown
        navigationItem.rightBarButtonItems = [showDetailViewButton]
        
        loadNotes()
        
        title = "Notes"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = .systemYellow

        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        loadNotes()
        tableView.reloadData()
        print("data reloaded!")
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = notes[indexPath.row].noteName
        cell.detailTextLabel?.text = notes[indexPath.row].noteText
        cell.backgroundColor = .clear
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.nameToLoad = notes[indexPath.row].noteName
            vc.textToLoad = notes[indexPath.row].noteText
            vc.rowNumber = indexPath.row
            navigationController?.pushViewController(vc, animated: true)

        }

    }
    
    @objc func showDetailView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
        navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func loadNotes() {
        let defaults = UserDefaults.standard
        
        if let notesToLoad = defaults.object(forKey: "notes") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                notes = try jsonDecoder.decode([Note].self, from: notesToLoad)
                print("Notes loaded to table view successfully.")
            } catch {
                print("Failed to load notes.")
            }
        }
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(notes) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "notes")
        } else {
            print("Failed to save notes.")
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
        save()
    }
    
    
}

