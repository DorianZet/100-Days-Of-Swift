//
//  Move.swift
//  Project34
//
//  Created by Mateusz Zacharski on 15/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import GameplayKit
import UIKit

// To simulate a move, GameplayKit takes copies of our board state, finds all possible moves that can happen, and applies them all on different copies.
class Move: NSObject, GKGameModelUpdate {
    var value: Int = 0
    var column: Int
    
    init(column: Int) {
        self.column = column
    }
}
