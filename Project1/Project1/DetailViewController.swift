//
//  DetailViewController.swift
//  Project1
//
//  Created by MacBook on 09/04/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var selectedImage: String?
    var selectedPictureNumber = 0
    var totalPictures = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Picture \(selectedPictureNumber) of \(totalPictures)"
        navigationItem.largeTitleDisplayMode = .never
        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
            assert(selectedImage != nil, "Selected image is nil") // making sure that selectedImage always has a value
            
            navigationController?.hidesBarsOnTap = true
            navigationController?.hidesBarsOnTap = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.hidesBarsOnTap = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.hidesBarsOnTap = false
    }
    
}
