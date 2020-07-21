//
//  Petition.swift
//  Project7
//
//  Created by MacBook on 25/04/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import Foundation

struct Petition: Codable {
    var title: String
    var body: String
    var signatureCount: Int
}
