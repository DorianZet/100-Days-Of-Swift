//
//  ViewController.swift
//  Project38
//
//  Created by Mateusz Zacharski on 25/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

// To set up the basic Core Data system, we need to write code that will do the following:
// 1. Load our data model we just created from the application bundle and create a 'NSManagedObjectModel' object from it.
// 2. Create an 'NSPersistentStoreCoordinator' object, which is responsible for reading from and writing to disk.
// 3. Set up a URL pointing to the database on disk where our actual saved objects live. This will be an SQLite database named 'Project38.sqlite'.
// 4. Load that database into the 'NSPersistentStoreCoordinator' so it knows where we want it to save. If it doesn't exist, it will be created automatically.
// 5. Create an 'NSManagedObjectContext' and point it at the persistent store coordinator.

// All of those 5 steps are exactly what 'NSPersistentContainer' does for us.
import CoreData // in our app, Core Data is responsible for reading data from a persistent store (the SQLite database) and making it available for us to use as objects. After changing those objects, we can save them back to the persistent store, which is when Core Data converts them back from objects to database records.
import UIKit

class ViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    var container: NSPersistentContainer!
        
    var commitPredicate: NSPredicate? // we make the predicate optional because that's exactly what our fetch request takes: either a valid predicate that specifies a filter, or nil to mean "no filter".
    
    var fetchedResultsController: NSFetchedResultsController<Commit>! // hold the fetched results controller for commits.
    
    var newCommits = [Commit]()

    override func viewDidLoad() {
        super.viewDidLoad()

        container = NSPersistentContainer(name: "Project38") // The container must be given the name of the Core Data model we created: "Project38".
        container.loadPersistentStores { storeDescription, error in // Loads the saved database IF IT EXISTS, or creates it otherwise.
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy // this instructs Core Data to allow updates to objects: if an object exists in its data store with message A, and an object with the same unique constraint ("sha" attribute) exists in memory with message B, the in-memory version "trumps" (overwrites) the data store version. That way we avoid the repetition of commits.
            
            if let error = error {
                print("Unresolved error \(error)")
            }
        }
        
        // Fetch commits from GitHub in background:
        performSelector(inBackground: #selector(fetchCommits), with: nil)
        loadSavedData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Filter", style: .plain, target: self, action: #selector(changeFilter))
    }
    
    // Once we've finished our changes and we want to write them permanently - i.e., save them to disk - we need to call the save() method on the 'viewContext' property.
    func saveContext() {
        if container.viewContext.hasChanges { // save only if there are any changes since the last save.
            do {
                try container.viewContext.save()
            } catch {
                print("An error occured while saving: \(error)")
            }
        }
    }
    
    @objc func fetchCommits() {
        let newestCommitDate = getNewestCommitDate()
        
        if let data = try? String(contentsOf: URL(string: "https://api.github.com/repos/apple/swift/commits?per_page=100&since=\(newestCommitDate)")!) { // now as the date is set to one second after our most recent commit, we can send that to the GitHub using its "since" parameter to receive back only newer commits.
            // give the data to SwiftyJSON to parse:
            let jsonCommits = JSON(parseJSON: data)
            
            // read the commits back out as an array:
            let jsonCommitArray = jsonCommits.arrayValue
            
            DispatchQueue.main.async { [unowned self] in
                for jsonCommit in jsonCommitArray {
                    let commit = Commit(context: self.container.viewContext) // creates a 'Commit' object inside the managed object context given to us by the 'NSPersistentContainer' we created. This means its data will get saved back to the SQLite database when we call 'saveContext()'.
                    self.configure(commit: commit, usingJSON: jsonCommit) // Once we have a new 'Commit' object, we pass it onto the 'configure(commit:)' method, along with the JSON data for the matching commit.
                }
                                
                self.saveContext()
                self.loadSavedData()
            }
        }
    }
    
    func getNewestCommitDate() -> String {
        let formatter = ISO8601DateFormatter()

        let newest = Commit.createFetchRequest()
        let sort = NSSortDescriptor(key: "date", ascending: false)
        newest.sortDescriptors = [sort]
        newest.fetchLimit = 1 // it's always more efficient to fetch as few objects as needed, so if you can set a fetch limit - you should do so.

        if let commits = try? container.viewContext.fetch(newest) {
            if commits.count > 0 {
                return formatter.string(from: commits[0].date.addingTimeInterval(1)) // 'string(from:)' is the inverse of the 'date(from:)' method we used when parsing the commit JSON. We use the same date format that was defined earlier, because GitHub's "since" parameter is specified in an identical way. 'addingTimeInterval' adds one second to the time from the previous commit, otherwise GitHub will return the newest commit again.
            }
        }

        return formatter.string(from: Date(timeIntervalSince1970: 0)) // if no valid date is found, the method returns a date from the 1st of January 1970, which will reproduce the same behavior we had before introducing this date change.
    }
    
    
    // We use SwiftyJSON to configure parsed data. It automatically ensures a safe value gets returned even if the data is missing or broken.:
    func configure(commit: Commit, usingJSON json: JSON) {
        commit.sha = json["sha"].stringValue
        commit.message = json["commit"]["message"].stringValue // For example, if "commit" or "message" don't exist or if they do exist but actually contain an integer for some reason, we'll get back an empty string.
        commit.url = json["html_url"].stringValue
        
        let formatter = ISO8601DateFormatter()
        commit.date = formatter.date(from: json["commit"]["committer"]["date"].stringValue) ?? Date() // we use nil coalescing operator to use a new 'Date' instance if the date failed to parse. We put [][][] next to each other to access the data tree. ["date"] is in ["committer"], while ["committer"] is in ["commit"].
        
        var commitAuthor: Author!
        
        // see if this author exists already:
        let authorRequest = Author.createFetchRequest()
        authorRequest.predicate = NSPredicate(format: "name == %@", json["commit"]["committer"]["name"].stringValue)
        
        if let authors = try? container.viewContext.fetch(authorRequest) { // we use 'try?' for 'fetch()' this time, because we don;t really care if the request failed: it will still fall through and get caught by the 'if commitAuthor == nil' check below.
            if authors.count > 0 {
                // we have this author already:
                commitAuthor = authors[0]
            }
        }
        
        if commitAuthor == nil {
            // we didn't find a saved author - create a new one then:
            let author = Author(context: container.viewContext)
            author.name = json["commit"]["committer"]["name"].stringValue
            author.email = json["commit"]["committer"]["email"].stringValue
            commitAuthor = author
        }
        
        // use the author, either saved or new:
        commit.author = commitAuthor
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Commit", for: indexPath)
        
        let commit = fetchedResultsController.object(at: indexPath)
        cell.textLabel!.text = commit.message
        cell.detailTextLabel!.text = "By \(commit.author.name) on \(commit.date.description)" // 'description' shows a date as a readable string.
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.detailItem = fetchedResultsController.object(at: indexPath)
            vc.pageToLoad = fetchedResultsController.object(at: indexPath).url
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    // How to delete commits from the table view, using fetchedResultsController:
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let commit = fetchedResultsController.object(at: indexPath)
            container.viewContext.delete(commit)
            saveContext() // saves the context. REMEMBER: you must call saveContext() whenever you want your change to persist.
        }
    }
    
    // Create a header section with the author's name above his commits in the table view:
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController.sections![section].name // the 'name' here is equal to the key in NSSortDescriptor from 'loadSavedData' method - to make it an author's email, change "author.name" to "author.email".
    }
    
    func loadSavedData() {
        if fetchedResultsController == nil {
            let request = Commit.createFetchRequest() // create the NSFetchRequest
            let sort = NSSortDescriptor(key: "author.name", ascending: true)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20 // only 20 objects are loaded at a time.
            
            // Create a fetchedResultsController:
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: container.viewContext, sectionNameKeyPath: "author.name", cacheName: nil)
            fetchedResultsController.delegate = self
        }
        
        fetchedResultsController.fetchRequest.predicate = commitPredicate
        
        do {
            try fetchedResultsController.performFetch() // use the 'performFetch()' method on our fetched results controller to make it load its data.
            tableView.reloadData() // once the array of all 'Commit' objects that exist in the data store is returned, we call 'reloadData()' to have the data appear in the table.
        } catch {
            print("Fetch failed")
        }
    }
    
    @objc func changeFilter() {
        let ac = UIAlertController(title: "Filter commits...", message: nil, preferredStyle: .actionSheet)
        
        // Filter 1:
        ac.addAction(UIAlertAction(title: "Show only fixes", style: .default) { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "message CONTAINS[c] 'fix'") // 'CONTAINS[c]' is an operator, just like '=='. The CONTAINS part will ensure this predicate matches only objects that contain a string somewhere in their messsage, in our case, that's the text "fix". The '[c]' part is predicate-speak for "case-insensitive", which means it will match "FIX", "Fix", "fix" and so son. N
            self.loadSavedData()
        })
        // Filter 2:
        ac.addAction(UIAlertAction(title: "Ignore Pull Requests", style: .default) { [unowned self] _ in
            self.commitPredicate = NSPredicate(format: "NOT message BEGINSWITH 'Merge pull request'") // 'BEGINSWITH' works just like 'CONTAINS' except the matching text must be at the start of a string. 'NOT' keyword flips the match around, so ths action will match only objects that DON'T begin with 'Merge pull request'.
            self.loadSavedData()
        })
        // Filter 3:
        ac.addAction(UIAlertAction(title: "Show only recent", style: .default) { [unowned self] _ in
            let twelveHoursAgo = Date().addingTimeInterval(-43200)
            self.commitPredicate = NSPredicate(format: "date > %@", twelveHoursAgo as NSDate) // Request only commits that took place 43,200 seconds ago, which is equivalent to 12 hours. Core Data wants to work with the old type of the date, so we typecast using 'as'. '%@' stands for 'twelveHoursAgo as NSDate' here.
            self.loadSavedData()
        })
        //Filter 4:
        ac.addAction(UIAlertAction(title: "Show only Durian commits", style: .default) { [ unowned self] _ in
            self.commitPredicate = NSPredicate(format: "author.name == 'Joe Groff'") // by using 'author.name' that predicate will perform 2 steps: it will find the "author" relation for our commit, then look up the "name" attribute of the matching object.
            self.loadSavedData()
        })
        // Filter 5:
        ac.addAction(UIAlertAction(title: "Show all commits", style: .default) { [unowned self] _ in
            self.commitPredicate = nil // resets the filter to none, so that all commits are shown again.
            self.loadSavedData()
        })
        
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    // This method gets called by the fetched results controller when an object changes. We'll get told the index path of the object that got changed, and all we need to do is pass that on to the deleteRows(at:) method of our table view:
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .delete:
            if tableView.numberOfRows(inSection: indexPath!.section) > 1 {
                    tableView.deleteRows(at: [indexPath!], with: .automatic)
            } else {
                let section = indexPath!.section
                let indexSet = IndexSet(integer: section)
                //tableView.deleteRows(at: [indexPath!], with: .automatic)
                tableView.deleteSections(indexSet, with: .automatic)
            }
           
        default:
            break
        }
    }
}

