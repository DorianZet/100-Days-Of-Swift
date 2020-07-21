//
//  ViewController.swift
//  Day 59. Milestone
//
//  Created by MacBook on 21/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
var miasta = [Miasto]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Miasta"
        let filePath = Bundle.main.url(forResource: "Towns", withExtension: "json")
        
        if let url = filePath {
            if let data = try? Data(contentsOf: url) {
                parse(json: data)
                print("data parsed")
                return
            } else {
                print("error")
            }
        } else {
            print("error")
        }
        
}

    func parse(json: Data) {
    let decoder = JSONDecoder()
    
        if let jsonMiasta = try? decoder.decode(Miasta.self, from: json) {
        miasta = jsonMiasta.results
        tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return miasta.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let miasto = miasta[indexPath.row]
        cell.textLabel?.text = miasto.miasto
        cell.detailTextLabel?.text = miasto.info
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.detailItem = miasta[indexPath.row]
            vc.title = miasta[indexPath.row].miasto
            navigationController?.pushViewController(vc, animated: true)
        }
        
    }

}
