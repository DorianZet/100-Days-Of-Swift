//
//  SelectGenreViewController.swift
//  Project33
//
//  Created by MacBook on 08/07/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class SelectGenreViewController: UITableViewController {
     static var genres = ["Unknown", "Blues", "Classical", "Electronic", "Jazz", "Metal", "Pop", "Reggae", "RnB", "Rock", "Soul"] // We mark it as "static" so we can use it in other places (for example, a different class).
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Select genre"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Genre", style: .plain, target: nil, action: nil)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SelectGenreViewController.genres.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = SelectGenreViewController.genres[indexPath.row]
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            let genre = cell.textLabel?.text ?? SelectGenreViewController.genres[0] // Using nil coalescing guarantees that we get a default of 'Unknown' genre
            let vc = AddCommentsViewController()
            vc.genre = genre
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
