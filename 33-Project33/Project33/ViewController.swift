//
//  ViewController.swift
//  Project33
//
//  Created by MacBook on 08/07/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//
import CloudKit
import UIKit

class ViewController: UITableViewController {
    static var isDirty = true // it's a STATIC property so we can set it on the whole class rather than trying to find the correct instance of the class
    var whistles = [Whistle]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "What's that Whistle?"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWhistle))
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Home", style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Genres", style: .plain, target: self, action: #selector(selectGenre))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if ViewController.isDirty {
            loadWhistles()
        }
    }
    
    func loadWhistles() {
        // First, load whistles that were saved locally before:
        loadWhistlesLocal()
        tableView.reloadData()
        
        // Then try to load all whistles from the cloud:
        let pred = NSPredicate(value: true) // describes a filter that we'll use to decide which results to show. Here it says: "all records that match true" or just "all records".
        let sort = NSSortDescriptor(key: "creationDate", ascending: false) // tells CloudKit which field we want to sort on, and whether we want it ascending or descending.
        let query = CKQuery(recordType: "Whistles", predicate: pred) // combines a predicate and sort descriptors with the name of the record type we want to query.
        query.sortDescriptors = [sort]
        
        let operation = CKQueryOperation(query: query)
        operation.desiredKeys = ["genre", "comments"] // We execute the operation on the query, putting the record keys we want into an array.
        operation.resultsLimit = 50
        
        var newWhistles = [Whistle]()
        
        // The '.recordFetchedBlock' closure on our CKQueryOperation object will give one CKRecord value for every record that gets downloaded, and we'll convert that into a Whistle object:
        operation.recordFetchedBlock = { record in
            let whistle = Whistle()
            whistle.recordID = record.recordID
            whistle.genre = record["genre"]
            whistle.comments = record["comments"]
            newWhistles.append(whistle)
        }
        
        // If there was no error we're going to overwrite our current 'whistles' array with the 'newWhistles' array that was build from the downloaded records. We also need to clear the 'isDirty' flag so we know the update was fetch and then reload the table view.
        operation.queryCompletionBlock = { [unowned self] (cursor, error) in
            DispatchQueue.main.async {
                if error == nil {
                    ViewController.isDirty = false
                    self.whistles = newWhistles
                    self.tableView.reloadData()
                    self.saveWhistlesToLocal()
                } else {
                    let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the list of whistles, please try again: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Retry", style: .default, handler: self.retryLoadingWhistles))
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self.present(ac, animated: true)
                }
            }
        }
        
        // Now that we've created a query, added it to a CKQueryOperation, then configured its TWO closures to handle downloading data, it's just a matter of asking CloudKit to run it:
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    func retryLoadingWhistles(action: UIAlertAction) {
        loadWhistles()
    }
   
    @objc func addWhistle() {
        let vc = RecordWhistleViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        let titleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline), NSAttributedString.Key.foregroundColor: UIColor.purple]
        let subtitleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)]
        
        let titleString = NSMutableAttributedString(string: "\(title)", attributes: titleAttributes)
        
        if subtitle.count > 0 {
            let subtitleString = NSAttributedString(string: "\n\(subtitle)", attributes: subtitleAttributes)
            titleString.append(subtitleString)
        }
        
        return titleString
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.attributedText = makeAttributedString(title: whistles[indexPath.row].genre, subtitle: whistles[indexPath.row].comments)
        cell.textLabel?.numberOfLines = 0
        
        return cell
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.whistles.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ResultsViewController()
        vc.whistle = whistles[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }

    @objc func selectGenre() {
        let vc = MyGenresViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func saveWhistlesToLocal() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: whistles, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "whistles")
        }
    }
    
    func loadWhistlesLocal() {
        // Reading the saved data:
        let defaults = UserDefaults.standard
        if let savedWhistles = defaults.object(forKey: "whistles") as? Data {
            if let decodedWhistles = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedWhistles) as? [Whistle] {
                whistles = decodedWhistles
            }
        }
    }

}

