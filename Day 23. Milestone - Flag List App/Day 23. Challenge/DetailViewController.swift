//
//  DetailViewController.swift
//  Day 23. Challenge
//
//  Created by MacBook on 15/04/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var selectedImage: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        if let imageToLoad = selectedImage {
            imageView.layer.borderWidth = 1
            imageView.layer.borderColor = UIColor.lightGray.cgColor
            imageView.image = UIImage(named: imageToLoad)
        }
    
    if selectedImage == "uk" || selectedImage == "us" {
        selectedImage = selectedImage?.uppercased()
    } else {
        selectedImage = selectedImage?.capitalized
    }
        title = selectedImage
    }
    
    @objc func shareTapped() {
    guard let image = imageView.image?.jpegData(compressionQuality: 0.8) else {
        print("No image found")
        return
    }
        let vc = UIActivityViewController(activityItems: [image], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
}
