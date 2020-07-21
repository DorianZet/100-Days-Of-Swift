//
//  ViewController.swift
//  Project1
//
//  Created by MacBook on 08/04/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {
    var pictures = [String]()
    let defaults = UserDefaults.standard
    
    var picture1views = 0
    var picture2views = 0
    var picture3views = 0
    var picture4views = 0
    var picture5views = 0
    var picture6views = 0
    var picture7views = 0
    var picture8views = 0
    var picture9views = 0
    var picture10views = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Loading view counts of each picture:
        let savedPicture1Views = defaults.integer(forKey: "Picture 1 views")
        picture1views = savedPicture1Views
        let savedPicture2Views = defaults.integer(forKey: "Picture 2 views")
        picture2views = savedPicture2Views
        let savedPicture3Views = defaults.integer(forKey: "Picture 3 views")
        picture3views = savedPicture3Views
        let savedPicture4Views = defaults.integer(forKey: "Picture 4 views")
        picture4views = savedPicture4Views
        let savedPicture5Views = defaults.integer(forKey: "Picture 5 views")
        picture5views = savedPicture5Views
        let savedPicture6Views = defaults.integer(forKey: "Picture 6 views")
        picture6views = savedPicture6Views
        let savedPicture7Views = defaults.integer(forKey: "Picture 7 views")
        picture7views = savedPicture7Views
        let savedPicture8Views = defaults.integer(forKey: "Picture 8 views")
        picture8views = savedPicture8Views
        let savedPicture9Views = defaults.integer(forKey: "Picture 9 views")
        picture9views = savedPicture9Views
        let savedPicture10Views = defaults.integer(forKey: "Picture 10 views")
        picture10views = savedPicture10Views
        
        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let fm = FileManager.default
            let path = Bundle.main.resourcePath!
            let items = try! fm.contentsOfDirectory(atPath: path)
            for item in items {
                if item.hasPrefix("nssl") {
                // this is a picture to load!
                    self?.pictures.append(item)
                    self?.pictures.sort()
                }
            }
        }
        
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(pictures)
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        cell.textLabel?.text = pictures[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = pictures[indexPath.row]
            // Saving the view counts for each picture:
            if vc.selectedImage == pictures[0] {
                picture1views += 1
                defaults.set(picture1views, forKey: "Picture 1 views")
                print(defaults.integer(forKey: "Picture 1 views"))
            }
            if vc.selectedImage == pictures[1] {
                picture2views += 1
                defaults.set(picture2views, forKey: "Picture 2 views") // Saving view counts of the picture
                print(defaults.integer(forKey: "Picture 2 views"))
            }
            if vc.selectedImage == pictures[2] {
                picture3views += 1
                defaults.set(picture3views, forKey: "Picture 3 views")
                print(defaults.integer(forKey: "Picture 3 views"))
            }
            if vc.selectedImage == pictures[3] {
                picture4views += 1
                defaults.set(picture4views, forKey: "Picture 4 views")
                print(defaults.integer(forKey: "Picture 4 views"))
            }
            if vc.selectedImage == pictures[4] {
                picture5views += 1
                defaults.set(picture5views, forKey: "Picture 5 views")
                print(defaults.integer(forKey: "Picture 5 views"))

            }
            if vc.selectedImage == pictures[5] {
                picture6views += 1
                defaults.set(picture6views, forKey: "Picture 6 views")
                print(defaults.integer(forKey: "Picture 6 views"))

            }
            if vc.selectedImage == pictures[6] {
                
                picture7views += 1
                defaults.set(picture7views, forKey: "Picture 7 views")
                print(defaults.integer(forKey: "Picture 7 views"))

            }
            if vc.selectedImage == pictures[7] {
                
                picture8views += 1
                defaults.set(picture8views, forKey: "Picture 8 views")
                print(defaults.integer(forKey: "Picture 8 views"))

            }
            if vc.selectedImage == pictures[8] {
                
                picture9views += 1
                defaults.set(picture9views, forKey: "Picture 9 views")
                print(defaults.integer(forKey: "Picture 9 views"))

            }
            if vc.selectedImage == pictures[9] {
                
                picture10views += 1
                defaults.set(picture10views, forKey: "Picture 10 views")
                print(defaults.integer(forKey: "Picture 10 views"))

            }
            vc.selectedPictureNumber = indexPath.row + 1
            vc.totalPictures = pictures.count
            navigationController?.pushViewController(vc, animated: true) // OR: vc.modalPresentationStyle = .pageSheet
            // vc.modalTransitionStyle = .coverVertical
            // navigationController?.present(vc, animated: true)
            // the method above modifies the animation of the vc appearing
            
        }
    }
}

