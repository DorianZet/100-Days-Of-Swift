//
//  ViewController.swift
//  Project12
//
//  Created by MacBook on 10/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        
        defaults.set(25, forKey: "Age")
        defaults.set(true, forKey: "UserFaceID")
        defaults.set(CGFloat.pi, forKey: "Pi")
        
        defaults.set("Paul Hudson", forKey: "Name")
        defaults.set(Date(), forKey: "LastRun")
        
        let array = ["Hello", "World"]
        defaults.set(array, forKey: "SavedArray")
        
        let dict = ["Name": "Paul", "Country": "UK"]
        defaults.set(dict, forKey: "SavedDictionary")
        
        let savedInteger = defaults.integer(forKey: "Age")
        let savedBoolean = defaults.bool(forKey: "UseFaceID")
        let savedCGFloat = defaults.float(forKey: "blabla")
        
        let savedArray = defaults.object(forKey: "SavedArray") as? [String] ?? [String]() // This means - if savedArray exists, it will be loaded and placed into the savedArray constant by writing 'as? [String]'. If it doesn't exist (or if it does exist and isn't a string array), the savedArray gets set to be a new string array - '?? [String]()'.
        
        let savedDictionary = defaults.object(forKey: "SavedDictionary") as? [String: String] ?? [String: String]()
        // Same method as above is applied here, but the difference is we use a dictionary array type instead of a string array type.
        
        let savedArray2 = defaults.array(forKey: <#T##String#>)
    }


}

