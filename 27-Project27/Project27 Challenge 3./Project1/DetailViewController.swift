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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
        
        if let imageToLoad = selectedImage {
            imageView.image = UIImage(named: imageToLoad)
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
    
    @objc func shareTapped() {
        // Implementing a date into the attributed string:
        // get the current date and time
        let currentDateTime = Date()
        // initialize the date formatter and set the style
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .long
        // get the date time String from the date object
        let dateAndTime = formatter.string(from: currentDateTime)
        
        let imageSize = imageView.image?.size
        if let imageSize = imageSize {
            let renderer = UIGraphicsImageRenderer(size: imageSize)
            
            let image = renderer.image { ctx in
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .left
            
                let attrs: [NSAttributedString.Key: Any] = [
                    .font: UIFont.italicSystemFont(ofSize: 20),
                    .paragraphStyle: paragraphStyle,
                    .foregroundColor: UIColor(white: 0, alpha: 0.4)
                ]
            
                let string = "From \"Storm Viewer\"\n\(dateAndTime)"
            
                let attributedString = NSAttributedString(string: string, attributes: attrs)
            
                let imageToDraw = imageView.image
                imageToDraw?.draw(at: CGPoint(x: 0, y: 0))
                
                attributedString.draw(with: CGRect(x: 5, y: 0, width: 300, height: 200), options: .usesLineFragmentOrigin, context: nil)
            }
            
            let vc = UIActivityViewController(activityItems: [image, selectedImage!], applicationActivities: [])
            vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
            present(vc, animated: true)
        }
    }
}
