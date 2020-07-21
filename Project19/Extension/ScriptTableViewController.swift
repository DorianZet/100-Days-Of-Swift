//
//  ScriptTableViewController.swift
//  Extension
//
//  Created by MacBook on 01/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit
import MobileCoreServices

class ScriptTableViewController: UITableViewController {
    var tableScripts = [scriptSavedForTableView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTableViewScripts()
        tableView.reloadData()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(saveScriptToTableView))
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableScripts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = tableScripts[indexPath.row].tableName
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": tableScripts[indexPath.row].tableScript]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableScripts.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func saveToTable() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(tableScripts) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "tableScriptsSaved")
            print("Saved script to table successfully.")
        } else {
            print("Failed to save scripts.")
        }
    }
    
    @objc func saveScriptToTableView() {
        let ac1 = UIAlertController(title: "Type in the script and name it.", message: nil, preferredStyle: .alert)
        ac1.addTextField()
        ac1.addTextField()
        ac1.textFields![0].placeholder = "Name"
        ac1.textFields![1].placeholder = "Script"
        
        ac1.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac1] _ in
            let newName = ac1?.textFields?[0].text
            let newScript = ac1?.textFields?[1].text
            let savedScriptToTable = scriptSavedForTableView(tableName: newName!, tableScript: newScript!)
                self?.tableScripts.append(savedScriptToTable)
                self?.saveToTable()
            self?.tableView.reloadData()
            })
        ac1.addAction(UIAlertAction(title: "Cancel", style: .cancel))
       present(ac1, animated: true)
        }
    
    
    func loadTableViewScripts() {
        let defaults = UserDefaults.standard
        
        if let scriptsToLoad = defaults.object(forKey: "tableScriptsSaved") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                tableScripts = try jsonDecoder.decode([scriptSavedForTableView].self, from: scriptsToLoad)
                print("Scripts to table view loaded succesfully.")
            } catch {
                print("Failed to load scripts")
            }
        }
    }

}
