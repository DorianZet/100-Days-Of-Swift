//
//  Board.swift
//  Project34
//
//  Created by Mateusz Zacharski on 14/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import GameplayKit
import UIKit

class Board: NSObject, GKGameModel {
    static var width = 7
    static var height = 6
    
    var slots = [ChipColor]()
    
    var currentPlayer: Player
    
    // Players property needed for the AI:
    var players: [GKGameModelPlayer]? {
        return Player.allPlayers
    }
    
    // Active player property needed for the AI:
    var activePlayer: GKGameModelPlayer? {
        return currentPlayer
    }

    override init() {
        currentPlayer = Player.allPlayers[0] // initializing the currentPlayer value with the first player value.
        
        // All the slots have no chip in them by default:
        for _ in 0 ..< Board.width * Board.height {
            slots.append(.none)
        }
        
        super.init()
    }
    
    // Read the chip color of a specific slot. To find the correct row/column, we multiply the column number by the height of the board, then add the row:
    func chip(inColumn column: Int, row: Int) -> ChipColor {
        return slots[row + column * Board.height]
    }
    
    // Set the chip color of a specific slot:
    func set(chip: ChipColor, in column: Int, row: Int) {
        slots[row + column * Board.height] = chip
    }
    
    // Determining whether a player can place a chip in a column. This method will return the first row number that contains no chips in a specific column. It works by counting up in a columm, from 0 up to the height of the board. For every slot, it calls 'chip(inColumn:row:)' to see what chip color is there already, and if it gets back '.none'' it means that row is good to use. If it gets to the end of the board without finding a '.none' it will return nil - this column has no free slots:
    func nextEmptySlot(in column: Int) -> Int? {
        for row in 0 ..< Board.height {
            if chip(inColumn: column, row: row) == .none {
                return row
            }
        }
        return nil
    }
    
    // Figuring out whether a player can play a particular column - we call 'nextEmptySlot(in:)' and check whether it returns nil or not:
    func canMove(in column: Int) -> Bool {
        return nextEmptySlot(in: column) != nil
    }
    
    // Find the next available slot in a column using nextEmptySlot(in:), and if the result is not nil then use 'set(chip:)' to change that slot's color.
    func add(chip: ChipColor, in column: Int) {
        if let row = nextEmptySlot(in: column) {
            set(chip: chip, in: column, row: row)
        }
    }
   
    // Determining whether the board is full (and therefore, determining that we can call a draw):
    func isFull() -> Bool {
        for column in 0 ..< Board.width {
            if canMove(in: column) {
                return false
            }
        }
        
        return true
    }
    
    func isWin(for player: GKGameModelPlayer) -> Bool {
        let chip = (player as! Player).chip
        
        for row in 0 ..< Board.height {
            for col in 0 ..< Board.width {
                if squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: 0) {
                    return true
                } else if squaresMatch(initialChip: chip, row: row, col: col, moveX: 0, moveY: 1) {
                    return true
                } else if squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: 1) {
                    return true
                } else if squaresMatch(initialChip: chip, row: row, col: col, moveX: 1, moveY: -1) {
                    return true
                }
            }
        }
        return false
    }
    
    // Determining if we have four squares in a row (horizontally or vertically):
    func squaresMatch(initialChip: ChipColor, row: Int, col: Int, moveX: Int, moveY: Int) -> Bool {
        // bail out early if we can't win from here:
        if row + (moveY * 3) < 0 { return false }
        if row + (moveY * 3) >= Board.height { return false }
        if col + (moveX * 3) < 0 { return false }
        if col + (moveX * 3) >= Board.width { return false }
        
        // if not bailed, check every square:
        if chip(inColumn: col, row: row) != initialChip { return false }
        if chip(inColumn: col + moveX, row: row + moveY) != initialChip { return false }
        if chip(inColumn: col + (moveX * 2), row: row + (moveY * 2)) != initialChip { return false }
        if chip(inColumn: col + (moveX * 3), row: row + (moveY * 3)) != initialChip { return false }

        // if we are still here in the method, that means that we went through all 4 squares and they have the same chip inside, therefore they can be marked as a match:
        return true
    }
    
    // Letting AI take a copy of the board and set a game model for it:
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Board()
        copy.setGameModel(self)
        return copy
    }
    
    // Setting a game model:
    func setGameModel(_ gameModel: GKGameModel) {
        if let board = gameModel as? Board {
            slots = board.slots
            currentPlayer = board.currentPlayer
        }
    }
    
    func gameModelUpdates(for player: GKGameModelPlayer) -> [GKGameModelUpdate]? {
        // We optionally downcast our GKGameModelPlayer parameter into a 'Player' object:
        if let playerObject = player as? Player {
            // If the player or their opponent has won, return 'nil' to signal no moves are available:
            if isWin(for: playerObject) || isWin(for: playerObject.opponent) {
                return nil
            }
            
            // Otherwise, create a new array that will hold 'Move' objects:
            var moves = [Move]()
            
            // Loop through every column in the board, asking whether the player can move in that column:
            for column in 0 ..< Board.width {
                if canMove(in: column) {
                    // If so, create a new 'Move' object for that column, and add it to the array:
                    moves.append(Move(column: column))
                }
            }
            
            // Finally, return the array to tell the AI all the possible moves it can make:
            return moves
        }
        
        return nil
    }
    
    // The next step for the AI is to try all those moves. GameplayKit will execute a method called apply() once for EVERY MOVE, and again this will get called on a copy of our game board that reflects the current state of play after its virtual moves.
    func apply(_ gameModelUpdate: GKGameModelUpdate) {
        if let move = gameModelUpdate as? Move {
            add(chip: currentPlayer.chip, in: move.column)
            currentPlayer = currentPlayer.opponent
        }
    }
    
    
    // GameplayKit will ask us to provide a player score after each virtual move has been made, and that score affects the way GameplayKit ranks each move. We pass a GKGameModelPlayer object that we need to evaluate. As our game doesn't have a meaningful score that can be passed back as this method's return value, we'll use a very lazy heuristic: if the player has won we'll return 1000, if their opponent has won we'll return -1000, otherwise we'll return 0.
    // Some words from me, Mateusz: I understand that the 'score(for player:)' method is the key to the AI's effective work - the more details we provide it (adding/taking away certain amounts of points in different cases), the more effective AI will be. For example - adding some points for 2 chips in row, 3 chips in row etc.
    func score(for player: GKGameModelPlayer) -> Int {
        if let playerObject = player as? Player {
            if isWin(for: playerObject) {
                return 1000
            } else if isWin(for: playerObject.opponent) {
                return -1000
            }
        }
        
        return 0
    }
    
}
