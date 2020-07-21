//
//  scriptSaved.swift
//  Extension
//
//  Created by MacBook on 01/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//


import Foundation

class ScriptsForSite: NSObject, Codable {
    var script: String?
    
    init (script: String) {
        self.script = script
    }
}
