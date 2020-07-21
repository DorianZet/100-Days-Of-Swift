//
//  Person.swift
//  Project10
//
//  Created by MacBook on 05/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class Person: NSObject, NSCoding {
    var name: String
    var image: String
    
    init (name: String, image: String) {
        self.name = name
        self.image = image
    }
    
    // Reading the thing from disk:
    required init?(coder aDecoder: NSCoder) {
        self.name = aDecoder.decodeObject(forKey: "name") as? String ?? ""
        self.image = aDecoder.decodeObject(forKey: "image") as? String ?? ""

    }
    // Writing the thing to disk:
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(image, forKey: "image")
    }
    

}
