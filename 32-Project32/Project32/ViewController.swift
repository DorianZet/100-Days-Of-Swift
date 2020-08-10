//
//  ViewController.swift
//  Project32
//
//  Created by MacBook on 07/07/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//
import SafariServices
import CoreSpotlight
import MobileCoreServices
import UIKit
import NotificationCenter

class ViewController: UITableViewController {
    var projects = [Project]()
    var favorites = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // If by any chance the user will change their Dynamic Size type, while the app is running, it's a good idea to get the app notified about it and reload the view in order to adjust the interface size:
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustInterface), name: UIContentSizeCategory.didChangeNotification, object: nil)

        // Alternatively to the thing below, we can parse the data from a json file, like in Day 59 Milestone.
        let project1 = Project(title: "Project 1: Storm Viewer", subtitle: "Constants and variables, UITableView, UIImageView, FileManager, storyboards")
        let project2 = Project(title: "Project 2: Guess the Flag", subtitle: "@2x and @3x images, asset catalogs, integers, doubles, floats, operators (+= and -=), UIButton, enums, CALayer, UIColor, random numbers, actions, string interpolation, UIAlertController")
        let project3 = Project(title: "Project 3: Social Media", subtitle: "UIBarButtonItem, UIActivityViewController, the Social framework, URL")
        let project4 = Project(title: "Project 4: Easy Browser", subtitle: "loadView(), WKWebView, delegation, classes and structs, URLRequest, UIToolbar, UIProgressView., key-value observing")
        let project5 = Project(title: "Project 5: Word Scramble", subtitle: "Closures, method return values, booleans, NSRange")
        let project6 = Project(title: "Project 6: Auto Layout", subtitle: "Get to grips with Auto Layout using practical examples and code")
        let project7 = Project(title: "Project 7: Whitehouse Petitions", subtitle: "JSON, Data, UITabBarController")
        let project8 = Project(title: "Project 8: 7 Swifty Words", subtitle: "addTarget(), enumerated(), count, index(of:), property observers, range operators.")
        
        projects.append(contentsOf: [project1, project2, project3, project4, project5, project6, project7, project8])
        
        // Load the array of favorite projects:
        let defaults = UserDefaults.standard
        if let savedFavorites = defaults.object(forKey: "favorites") as? [Int] {
            favorites = savedFavorites
        }
        
        tableView.isEditing = true
        tableView.allowsSelectionDuringEditing = true
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let project = projects[indexPath.row]
        cell.textLabel?.attributedText = makeAttributedString(title: project.title, subtitle: project.subtitle)
        
        if favorites.contains(indexPath.row) {
            cell.editingAccessoryType = .checkmark
        } else {
            cell.editingAccessoryType = .none
        }
        
        return cell
    }
    
    func makeAttributedString(title: String, subtitle: String) -> NSAttributedString {
        let titleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .headline), NSAttributedString.Key.foregroundColor: UIColor.purple]
        let subtitleAttributes = [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .subheadline)]
        
        let titleString = NSMutableAttributedString(string: "\(title)\n", attributes: titleAttributes)
        let subtitleString = NSAttributedString(string: subtitle, attributes: subtitleAttributes)
        
        titleString.append(subtitleString)
        return titleString
    }
    
    func showTutorial(_ which: Int) {
        if let url = URL(string: "https://www.hackingwithswift.com/read/\(which + 1)") { // we write "which + 1" because "indexPath.row" starts from 0.
            let config = SFSafariViewController.Configuration() // with the safari configuration, we can configure our safari view controller a little bit (the configuration is limited for security reasons)
            config.entersReaderIfAvailable = true // if reader mode is available, turn it on.
            
            let vc = SFSafariViewController(url: url, configuration: config)
            present(vc, animated: true)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showTutorial(indexPath.row)
    }
    
    // If a project has been favorited - the editing icon is delete. If not, it's an insert icon:
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if favorites.contains(indexPath.row) {
            return .delete
        } else {
            return .insert
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .insert {
            favorites.append(indexPath.row)
            index(item: indexPath.row)
        } else {
            if let index = favorites.firstIndex(of: indexPath.row) {
                favorites.remove(at: index)
                deindex(item: indexPath.row)
            }
        }
        
        let defaults = UserDefaults.standard
        defaults.set(favorites, forKey: "favorites")
        
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    // Setting a project as a searchable item (as a String):
    func index(item: Int) {
        let project = projects[item]
        
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String) // "kUTTypeText as String" tells iOS we want to store text in our indexed record.
        attributeSet.title = project.title
        attributeSet.contentDescription = project.subtitle
        
        let item = CSSearchableItem(uniqueIdentifier: "\(item)", domainIdentifier: "com.hackingwithswift", attributeSet: attributeSet)
        item.expirationDate = Date.distantFuture // By default, the content we index has an expiration date of one month after we add it, but this line probably works to make our items never expire.
        CSSearchableIndex.default().indexSearchableItems([item]) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully indexed!")
            }
        }
    }
    
    func deindex(item: Int) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(item)"]) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            } else {
                print("Search item successfully removed!")
            }
        }
    }
    
    @objc func adjustInterface() {
        loadView()
        print("View reloaded")
    }

}

