//
//  Saved Words.swift
//  Project5
//
//  Created by MacBook on 11/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class Saved_Words: NSObject, Codable {
    var word: String
    var subword: String
    
    init (word: String, subword: String) {
        self.word = word
        self.subword = subword
    }
}
