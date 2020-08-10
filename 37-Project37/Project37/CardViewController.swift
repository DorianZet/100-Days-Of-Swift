//
//  CardViewController.swift
//  Project37
//
//  Created by Mateusz Zacharski on 23/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit

class CardViewController: UIViewController {
    weak var delegate: ViewController!
    
    var front: UIImageView!
    var back: UIImageView!
    
    var isCorrect = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.bounds = CGRect(x: 0, y: 0, width: 100, height: 140)
        front = UIImageView(image: UIImage(named: "cardBack")) // if you create an image view using UIImage, the image view gets set to the size of that image automatically.
        back = UIImageView(image: UIImage(named: "cardBack"))
        
        view.addSubview(front)
        view.addSubview(back)
        
        front.isHidden = true
        back.alpha = 0
        
        UIView.animate(withDuration: 0.2) {
            self.back.alpha = 1
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped)) // We handle the card tap detection by using a UITapGestureRecognizer.
        back.isUserInteractionEnabled = true
        back.addGestureRecognizer(tap)
        
        // wiggle the card at random (the frequency of wiggling is in the 'wiggle()' function, look into it):
        perform(#selector(wiggle), with: nil, with: 1)
    }
    
    @objc func cardTapped() {
        delegate.cardTapped(self) // when a card is tapped, push all the work to the ViewController class.
    }
    
    // for all the cards that weren't tapped, zoom the card down and fade away over 0.7s.
    @objc func wasntTapped() {
        UIView.animate(withDuration: 0.7) {
            self.view.transform = CGAffineTransform(scaleX: 0.00001, y: 0.00001)
            self.view.alpha = 0
        }
    }
    
    // If a card was tapped, animate a 3D flip effect from the card back to the card front. This takes a view to operate on as its first parameter. If the 'Always Win Mode' is enabled in ViewController, change the tapped card image to "cardStar".
    func wasTapped() {
        if delegate.isWinModeEnabled == true {
            self.front.image = UIImage(named: "cardStar")
            isCorrect = true
        }
        
        UIView.transition(with: view, duration: 0.7, options: [.transitionFlipFromRight], animations: { [unowned self] in
            self.back.isHidden = true
            self.front.isHidden = false
        })
    }
    
    @objc func wiggle() {
        if Int.random(in: 0...3) == 1 {
            UIView.animate(withDuration: 0.2, delay: 0, options: .allowUserInteraction, animations: {
                self.back.transform = CGAffineTransform(scaleX: 1.01, y: 1.01)
            }) { _ in
                self.back.transform = CGAffineTransform.identity // once the animation ends, animate the card back to its original size
            }
            
            perform(#selector(wiggle), with: nil, afterDelay: 8)
        } else {
            perform(#selector(wiggle), with: nil, afterDelay: 2)
        }
    }

}
