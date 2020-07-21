//
//  ViewController.swift
//  Day 32. Milestone
//
//  Created by MacBook on 24/04/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
var shoppingList = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Shopping list"
        navigationController?.navigationBar.prefersLargeTitles = true

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Clear list", style: .plain, target: self, action: #selector(clearList))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(promptForProduct))
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareList))
        navigationItem.rightBarButtonItems = [addButton, shareButton]
    }
    
    func newList() {
        shoppingList.removeAll(keepingCapacity: true)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        shoppingList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Product", for: indexPath)
        cell.textLabel?.text = "• " + shoppingList[indexPath.row]
        return cell
    }
    
    @objc func promptForProduct() {
           let ac = UIAlertController(title: "Enter the product", message: nil, preferredStyle: .alert)
           ac.addTextField()
           
            let submitProduct = UIAlertAction(title: "OK", style: .default) {
            [weak self, weak ac] _ in
                       guard let product = ac?.textFields?[0].text else { return }
                       self?.submit(product)
            }
        let cancelPrompt = UIAlertAction(title: "Cancel", style: .cancel)
        
        ac.addAction(submitProduct)
        ac.addAction(cancelPrompt)
        present(ac, animated: true)
    }
    
    func submit(_ product: String) {
    shoppingList.insert(product, at: 0)
                       
    let indexPath = IndexPath(row: 0, section: 0)
    tableView.insertRows(at: [indexPath], with: .left)

    }
    
    @objc func clearList() {
        newList()
    }
    
    @objc func shareList() {
    let list = shoppingList.joined(separator: "\n• ")
        
        let vc = UIActivityViewController(activityItems: ["• " + list], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    // Now, here is the code to delete a single product with a swipe from the list:
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            shoppingList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }



}
