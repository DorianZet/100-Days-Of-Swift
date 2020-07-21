//
//  ViewController.swift
//  Project1
//
//  Created by MacBook on 08/04/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var pictures = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Storm Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true

        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        for item in items {
            if item.hasPrefix("nssl") {
            // this is a picture to load!
                pictures.append(item)
                pictures.sort()
            }
        }
        print(pictures)
    }

   override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return pictures.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Picture", for: indexPath) as? PictureCell else {
            fatalError("Unable to dequeue PictureCell.")
        }
        
        let picture = pictures[indexPath.item] // .item instead of .row, as it's a grid, not a table
        
        cell.name.text = picture
        cell.imageView?.image = UIImage(named: pictures[indexPath.row])
        
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController {
            vc.selectedImage = pictures[indexPath.item]
            vc.selectedPictureNumber = indexPath.item + 1
            vc.totalPictures = pictures.count
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}


