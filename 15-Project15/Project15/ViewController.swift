//
//  ViewController.swift
//  Project15
//
//  Created by MacBook on 19/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var imageView: UIImageView!
    var currentAnimation = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView = UIImageView(image: UIImage(named: "penguin"))
        imageView.center = CGPoint(x: 512, y: 384)
        view.addSubview(imageView)
    }

    @IBAction func tapped(_ sender: UIButton) {
        sender.isHidden = true // We hide the button as soon as it's tapped
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 12, options: [], animations: {
            switch self.currentAnimation {
            case 0:
                self.imageView.transform = CGAffineTransform(scaleX: 2, y: 2) // scales the imageView x2.
                break
            case 1:
                self.imageView.transform = .identity // scales the imageView back to the original size.
            case 2:
                self.imageView.transform = CGAffineTransform(translationX: -256, y: -256) // moves the imageView.
            case 3:
                self.imageView.transform = .identity // brings the imageView back to its original place.
            case 4:
                self.imageView.transform = CGAffineTransform(rotationAngle: .pi) // rotate the imageView by 180 degrees.
            case 5:
                self.imageView.transform = .identity // rotates the imageView back to its original place.
            case 6:
                self.imageView.alpha = 0.1
                self.imageView.backgroundColor = .green
            case 7:
                self.imageView.alpha = 1
                self.imageView.backgroundColor = .clear
            default:
                break
            }
        }) { finished in
            sender.isHidden = false
        } // this is the completion closure
        
        currentAnimation += 1
        
        if currentAnimation > 7 {
            currentAnimation = 0
        }
    }
    
}

