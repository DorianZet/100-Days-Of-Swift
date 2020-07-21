//
//  DetailViewController.swift
//  Day 50. Milestone
//
//  Created by MacBook on 12/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var selectedImage: String?
    var detailTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        title = detailTitle
        navigationItem.largeTitleDisplayMode = .never
        
        if let imageToLoad = selectedImage {
            imageView.image = UIImage(contentsOfFile: imageToLoad)
        }
    }
}
