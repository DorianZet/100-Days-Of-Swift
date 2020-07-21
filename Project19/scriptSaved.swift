//
//  scriptSaved.swift
//  Extension
//
//  Created by MacBook on 01/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.

import Foundation

class scriptSaved: NSObject, Codable {
    var script: String?
    var website: String?
    
    init (script: String, website: String) {
        self.script = script
        self.website = website
    }
}
