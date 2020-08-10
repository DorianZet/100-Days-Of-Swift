//
//  Project.swift
//  Project32
//
//  Created by MacBook on 07/07/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class Project: NSObject, Codable {
    var title: String
    var subtitle: String
    
    init (title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
}
