//
//  Person.swift
//  Project10
//
//  Created by MacBook on 05/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class Person: NSObject, Codable {
    var name: String
    var image: String
    
    init (name: String, image: String) {
        self.name = name
        self.image = image
    }
}
