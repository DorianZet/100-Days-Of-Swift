//
//  Scripts for site.swift
//  Extension
//
//  Created by MacBook on 01/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import Foundation

class ScriptsForSite: NSObject, Codable {
    var scripts: [String] = []
    
    init (scripts: [String]) {
        self.scripts = scripts
    }
}
