//
//  Picture.swift
//  Day 50. Milestone
//
//  Created by MacBook on 12/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class Picture: NSObject, Codable {
        var name: String
        var image: String
        
        init (name: String, image: String) {
            self.name = name
            self.image = image
        }
}
