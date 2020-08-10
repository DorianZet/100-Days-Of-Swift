//
//  ResultsViewController.swift
//  Project33
//
//  Created by MacBook on 09/07/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import AVFoundation
import CloudKit
import UIKit

class ResultsViewController: UITableViewController {
    var whistle: Whistle!
    var suggestions = [String]()
    
    var whistlePlayer: AVAudioPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Genre: \(whistle.genre!)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Download", style: .plain, target: self, action: #selector(downloadTapped))
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        downloadSuggestions()
    }
    
    func downloadSuggestions() {
        // To download all suggestions tht belong to a particular whistle, we need to create another 'CKRecord.Reference', just like in 'add(suggestion:)' method. Then we can pass that reference into an NSPredicate that will check for suggestions where 'owningWhistle' matches that predicate. Then we can sort the results by 'creationDate' ascending:
        let reference = CKRecord.Reference(recordID: whistle.recordID, action: .deleteSelf)
        let pred = NSPredicate(format: "owningWhistle == %@", reference)
        let sort = NSSortDescriptor(key: "creationDate", ascending: true)
        let query = CKQuery(recordType: "Suggestions", predicate: pred)
        query.sortDescriptors = [sort]
        
        
        // Unlike in ViewController, CKQueryOperation isn't needed here because we want ALL THE FIELDS, which means we can use the much easier convenience API: 'performQuery()':
        CKContainer.default().publicCloudDatabase.perform(query, inZoneWith: nil) { [unowned self] results, error in
            if let error = error {
                DispatchQueue.main.async {
                    let ac = UIAlertController(title: "Downloading suggestions failed", message: "There was a problem showing the list of the whistle suggestions, please try again: \(error.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Retry", style: .default, handler: self.retryDownloadingSuggestions))
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self.present(ac, animated: true)
                }
            } else {
                if let results = results {
                    self.parseResults(records: results)
                }
            }
        }
    }
    
    func retryDownloadingSuggestions(action: UIAlertAction) {
        downloadSuggestions()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Suggested songs"
        }
        
        return nil
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        } else {
            return suggestions.count + 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        cell.textLabel?.numberOfLines = 0
        
        if indexPath.section == 0 {
            // the user's comments about this whistle:
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .title1)
            
            if whistle.comments.count == 0 {
                cell.textLabel?.text = "Comments: None"
            } else {
                cell.textLabel?.text = whistle.comments
            }
        } else {
            cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .body)
            
            if indexPath.row == suggestions.count {
                // this is our extra row:
                cell.textLabel?.text = "Add suggestion"
                cell.selectionStyle = .gray
            } else {
                cell.textLabel?.text = suggestions[indexPath.row]
            }
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Only the last row in the 2nd section is tappable:
        guard indexPath.section == 1 && indexPath.row == suggestions.count else { return }
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let ac = UIAlertController(title: "Suggest a song...", message: nil, preferredStyle: .alert)
        ac.addTextField()
        
        ac.addAction(UIAlertAction(title: "Submit", style: .default) { [unowned self, ac] action in
            if let textField = ac.textFields?[0] {
                if textField.text!.count > 0 {
                    self.add(suggestion: textField.text!)
                }
            }
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    // When we create a 'CKRecord.Reference' we need to provide it two things: a record ID to link to, and a behavior to trigger when that linked record is deleted. We already have the record ID to link to because we're storing it in the 'whistle' property, and for the action trigger we'll use '.deleteSelf' - which means that when the parent whistle is deleted, the child suggestions are deleted too.
    // CKRecord.Reference, like CKAssets, can be placed directly into a CKRecord:
    func add(suggestion: String) {
        let whistleRecord = CKRecord(recordType: "Suggestions")
        let reference = CKRecord.Reference(recordID: whistle.recordID, action: .deleteSelf)
        whistleRecord["text"] = suggestion as CKRecordValue
        whistleRecord["owningWhistle"] = reference as CKRecordValue
        
        CKContainer.default().publicCloudDatabase.save(whistleRecord) { [unowned self] record, error in
            DispatchQueue.main.async {
                if error == nil {
                    self.suggestions.append(suggestion) // we append the user's new suggestion to the existing suggestions so they see it has been posted successfully
                    self.tableView.reloadData()
                } else {
                    let ac = UIAlertController(title: "Error", message: "There was a problem submitting your suggestion: \(error!.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                }
            }
        }
    }
    
    // To parse the results of suggestions for each whistle, we'll loop through an array of records, pull out the text property of each record and add it to our suggestions string array. To make things safer ON MULTIPLE THREADS, we'll use an intermediate array called 'newSuggestions', AS IT'S NEVER SMART TO MODIFY DATA IN A BACKGROUND THREAD THAT IS BEING USED ON A MAIN THREAD.
    func parseResults(records: [CKRecord]) {
        var newSuggestions = [String]()
        
        for record in records {
            newSuggestions.append(record["text"] as! String)
        }
        
        DispatchQueue.main.async { [unowned self] in
            self.suggestions = newSuggestions
            self.tableView.reloadData()
        }
    }
    
    @objc func downloadTapped() {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.tintColor = UIColor.black
        spinner.startAnimating()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: spinner)
        
        // Fetching whole records is done through a simple CloudKit convenience API - 'fetch(withRecordID:)'. Once that fetches the complete whistle record, we can pull out the CKAsset and read its fileURL property to know where CloudKit downloaded to. ALL USER INTERFACE WORK NEEDS TO BE PUSHED ONTO THE MAIN THREAD:
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: whistle.recordID) { [unowned self] record, error in
            if let error = error {
                DispatchQueue.main.async {
                    let ac = UIAlertController(title: "Download failed", message: "There was a problem downloading your whistle, please try again: \(error.localizedDescription)", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Retry", style: .default, handler: self.retryDownloadTapped))
                    ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self.present(ac, animated: true)
                    self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Download", style: .plain, target: self, action: #selector(self.downloadTapped))
                }
            } else {
                if let record = record {
                    if let asset = record["audio"] as? CKAsset {
                        self.whistle.audio = asset.fileURL
                        
                        DispatchQueue.main.async {
                            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Listen", style: .plain, target: self, action: #selector(self.listenTapped))
                        }
                    }
                }
            }
        }
    }
    
    func retryDownloadTapped(action: UIAlertAction) {
        downloadTapped()
    }
    
    @objc func listenTapped() {
        do {
            whistlePlayer = try AVAudioPlayer(contentsOf: whistle.audio)
            whistlePlayer.play()
        } catch {
            let ac = UIAlertController(title: "Playback failed", message: "There was a problem playing your whistle, please try re-recording.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

}
