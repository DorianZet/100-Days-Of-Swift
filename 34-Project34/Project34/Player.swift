//
//  Player.swift
//  Project34
//
//  Created by Mateusz Zacharski on 14/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import GameplayKit
import UIKit

class Player: NSObject, GKGameModelPlayer {
    var chip: ChipColor
    var color: UIColor
    var name: String
    var playerId: Int
    
    static var allPlayers = [Player(chip: .red), Player(chip: .black)]
    
    // Returning the opponent of a specific player:
    var opponent: Player {
        if chip == .red {
            return Player.allPlayers[1]
        } else {
            return Player.allPlayers[0]
        }
    }
    
    // We've declared four properties non-optional and haven't given them any values, so we need to create a custom initializer:
    init(chip: ChipColor) {
        self.chip = chip
        self.playerId = chip.rawValue
        
        if chip == .red {
            color = .red
            name = "Red"
        } else {
            color = .black
            name = "Black"
        }
        
        super.init()
    }
    
}
