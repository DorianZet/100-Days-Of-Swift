//
//  Picture.swift
//  Project1
//
//  Created by MacBook on 06/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class Picture: NSObject {
        var name: String
        var image: String
        
        init (name: String, image: String) {
            self.name = name
            self.image = image
        }
    }
