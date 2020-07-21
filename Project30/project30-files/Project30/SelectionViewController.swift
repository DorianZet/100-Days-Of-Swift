//
//  SelectionViewController.swift
//  Project30
//
//  Created by TwoStraws on 20/08/2016.
//  Copyright (c) 2016 TwoStraws. All rights reserved.
//

import UIKit

class SelectionViewController: UITableViewController {
	var items = [String]() // this is the array that will store the filenames to load
    var itemsSmall = [String]()
	var dirty = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = UserDefaults.standard
        if let savedItemsSmall = defaults.object(forKey: "itemsSmall") as? [String] {
            itemsSmall = savedItemsSmall
            print("Small items loaded successfully.")
            print(itemsSmall[0])
        }
        
		title = "Reactionist"

		tableView.rowHeight = 90
		tableView.separatorStyle = .none
        // When we request a cell, we'll get one back reused automatically:
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")

		// load all the JPEGs into our array
		let fm = FileManager.default
        let path = Bundle.main.resourcePath
        if let path = path {
            if let tempItems = try? fm.contentsOfDirectory(atPath: path) {
                for item in tempItems {
                    if item.range(of: "Large") != nil {
                        items.append(item)
                    }
                }
            }
        }
        
        if itemsSmall.isEmpty {
            print("itemsSmall was empty")
            for imageIndex in 0...items.count - 1 {
            
                let currentImage = items[imageIndex]
                let imageRootName = currentImage.replacingOccurrences(of: "Large", with: "Thumb")
            
                guard let path = Bundle.main.path(forResource: imageRootName, ofType: nil) else {
                    print("Error. Could not create the bundle path")
                    return }
                guard let original = UIImage(contentsOfFile: path) else {
                    print("Error. Could not create the original image")
                    return }
            
                let imageName = UUID().uuidString
                let pathDD = getDocumentsDirectory().appendingPathComponent(imageName)
                if let jpegData = original.jpegData(compressionQuality: 0.8) {
                    do {
                         try jpegData.write(to: pathDD)
                    } catch {
                        print("jpeg write error")
                    }
                    itemsSmall.append(pathDD.path)
                    print("Small item saved successfully.")
                }
            }
            let defaults = UserDefaults.standard
            defaults.set(itemsSmall, forKey: "itemsSmall")
        }
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		if dirty {
			// we've been marked as needing a counter reload, so reload the whole table
			tableView.reloadData()
		}
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections.
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of rows in the section.
        return items.count * 10
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
		// find the image for this cell, and load its thumbnail
		let currentImage = items[indexPath.row % itemsSmall.count]
		
        let renderRect = CGRect(origin: .zero, size: CGSize(width: 90, height: 90))
        let renderer = UIGraphicsImageRenderer(size: renderRect.size)

		let rounded = renderer.image { ctx in
			ctx.cgContext.addEllipse(in: renderRect)
			ctx.cgContext.clip()
            if let original = UIImage(contentsOfFile: itemsSmall[indexPath.row % itemsSmall.count]) {
                original.draw(in: renderRect)
            }
		}
        
		cell.imageView?.image = rounded

		// give the images a nice shadow to make them look a bit more dramatic
		cell.imageView?.layer.shadowColor = UIColor.black.cgColor
		cell.imageView?.layer.shadowOpacity = 1
		cell.imageView?.layer.shadowRadius = 10
		cell.imageView?.layer.shadowOffset = CGSize.zero
        cell.imageView?.layer.shadowPath = UIBezierPath(ovalIn: renderRect).cgPath

		// each image stores how often it's been tapped
		let defaults = UserDefaults.standard
		cell.textLabel?.text = "\(defaults.integer(forKey: currentImage))"
        
        return cell
    }

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vc = ImageViewController()
		vc.image = items[indexPath.row % itemsSmall.count]
		vc.owner = self

		// mark us as not needing a counter reload when we return
		dirty = false

        navigationController?.pushViewController(vc, animated: true)
	}
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
