//
//  Note.swift
//  Day 74. Milestone
//
//  Created by MacBook on 06/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import Foundation

class Note: NSObject, Codable {
    var noteName: String
    var noteText: String
    
    init (noteName: String, noteText: String) {
        self.noteName = noteName
        self.noteText = noteText
    }
}
