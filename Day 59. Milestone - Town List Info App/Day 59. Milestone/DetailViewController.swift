//
//  DetailViewController.swift
//  Day 59. Milestone
//
//  Created by MacBook on 21/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
 @IBOutlet var uiview: UIView!
 @IBOutlet var infoText: UILabel!
 @IBOutlet var wartoText: UILabel!
    
 var detailItem: Miasto?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        infoText.text = "Krótko o mieście: \n\(detailItem!.info)"
        wartoText.text = "Czy warto się tam wyprowadzić? \(detailItem!.warto)"
        infoText.alpha = 0
        wartoText.alpha = 0
        infoText.sizeToFit()
        wartoText.sizeToFit()
        
        navigationController?.navigationBar.prefersLargeTitles = true

        
        UIView.animate(withDuration: 3, delay: 1, options: [], animations: {
            self.infoText.alpha = 1
        })
        UIView.animate(withDuration: 3, delay: 5.5, options: [], animations: {
               self.wartoText.alpha = 1
       })
    }
    
    
    
    


}
