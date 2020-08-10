//
//  ViewController.swift
//  Project34
//
//  Created by Mateusz Zacharski on 14/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import GameplayKit
import UIKit

enum ChipColor: Int {
    // This enum will be used to store the current state of each slot. We give 'none' a raw value of 0, therefore Swift will assign the following values an auto-incremented number, which means Red will be 1 and Black will be 2.
    case none = 0
    case red
    case black
}

class ViewController: UIViewController {
    @IBOutlet var columnButtons: [UIButton]!
    
    var placedChips = [[UIView]]()
    var board: Board!
    
    var strategist: GKMinmaxStrategist! // Gameplay strategy that tries to MINimize losses while MAXimizing gains.
    
    var gameType = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for _ in 0 ..< Board.width {
            placedChips.append([UIView]())
        }
        
        strategist = GKMinmaxStrategist()
        strategist.maxLookAheadDepth = 7 // Calculating 7 moves ahead.
        strategist.randomSource = nil // Nil here serves as a tie-breaker: if two moves result in the same advantage for the AI, setting it to nil means "just return the first best move", but if we wanted to have the AI take a RANDOM best move we could do this: 'strategist.randomSource = GKARC4RandomSource()'.
        
        chooseOpponent()
    }
    
    
    
    func resetBoard() {
        board = Board()
        strategist.gameModel = board // The AI understand the state of play, and stands ready to look for good moves.
        
        updateUI()
        
        for i in 0 ..< placedChips.count {
            for chip in placedChips[i] {
                chip.removeFromSuperview()
            }
            
            placedChips[i].removeAll(keepingCapacity: true)
        }
    }

    func chooseOpponent() {
        let ac = UIAlertController(title: "Choose your opponent:", message: "", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Human", style: .default, handler: newGameHuman))
        ac.addAction(UIAlertAction(title: "A.I.", style: .default, handler: newGameAI))
        present(ac, animated: true)
    }
    
    func addChip(inColumn column: Int, row: Int, color: UIColor) {
        let button = columnButtons[column]
        let size = min(button.frame.width, button.frame.height / 6)
        let rect = CGRect(x: 0, y: 0, width: size, height: size)
        
        if (placedChips[column].count < row + 1) {
            let newChip = UIView()
            newChip.frame = rect
            newChip.isUserInteractionEnabled = false // Because user interaction is disabled, tapping a chip will go as tapping a column in which the chip is.
            newChip.backgroundColor = color
            newChip.layer.cornerRadius = size / 2 // Make a circle out of a squared button.
            newChip.center = positionForChip(inColumn: column, row: row)
            newChip.transform = CGAffineTransform(translationX: 0, y: -800)
            view.addSubview(newChip)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseIn, animations: {
                newChip.transform = CGAffineTransform.identity
            })
            
            placedChips[column].append(newChip)
        }
    }
    
    func positionForChip(inColumn column: Int, row: Int) -> CGPoint {
        let button = columnButtons[column]
        let size = min(button.frame.width, button.frame.height / 6)
        
        let xOffset = button.frame.midX // getting the horizontal center of the column button.
        var yOffset = button.frame.maxY - size / 2 // Getting the bottom of the column button, then substracting half the chip size because we're working with the center of the chip.
        yOffset -= size * CGFloat(row) // Multiply the row by the size of each chip to figure out how far to offset the new chip, and substract that from the 'yOffset'.
        return CGPoint(x: xOffset, y: yOffset)
    }
    
    // Using a button tag to figure out which column the player wants to use. We then use that column as the input for 'nextEmptySlot(in:)' to figure out which row to play, then call 'add(chip:)' on the board model and 'addChip(inColumn:row:)' to create the chip's UIView.
    @IBAction func makeMove(_ sender: UIButton) {
        let column = sender.tag
        
        if let row = board.nextEmptySlot(in: column) {
            board.add(chip: board.currentPlayer.chip, in: column)
            addChip(inColumn: column, row: row, color: board.currentPlayer.color)
            continueGame() // Control automatically flips between players after each move.
        }
    }
    
    func updateUI() {
        title = "\(board.currentPlayer.name)'s Turn"
        
        // AI starts its work when it's black's turn:
        if board.currentPlayer.chip == .black {
            if gameType == "AI" {
                startAIMove()
            }
        }
    }
    
    // Method called after every move:
    func continueGame() {
        // We create a gameOverTitle optional string set to nil:
        var gameOverTitle: String? = nil
        
        // If the game is over or the board if full, gameOverTitle is updated to include the relevant status message:
        if board.isWin(for: board.currentPlayer) {
            gameOverTitle = "\(board.currentPlayer.name) Wins!"
        } else if board.isFull() {
            gameOverTitle = "Draw!"
        }
        
        // If 'gameOverTitle' is not nil (i.e., the game is won or drawn), show an alert controller that resets the board when dismissed:
        if gameOverTitle != nil {
            let alert = UIAlertController(title: gameOverTitle, message: nil, preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Play Again", style: .default) { [unowned self] (action) in
                self.chooseOpponent()
            }
            
            alert.addAction(alertAction)
            present(alert, animated: true)
            
            return
        }
        
        // Otherwise, change the current player of the game, then call updateUI() to set the navigation bar title:
        board.currentPlayer = board.currentPlayer.opponent
        updateUI()
    }
    
    // This method will return an optional integer: either the best column for a move, or nil to mean "no move found".
    func columnForAIMove() -> Int? {
        if let aiMove = strategist.bestMove(for: board.currentPlayer) as? Move {
            return aiMove.column
        }
        
        return nil
    }
    
    
    // This method will find the next available slot for the selected column, then use add(chip:) to make the move on the model, and addChip(inColumn:) to make the move in the view.
    func makeAIMove(in column: Int) {
        columnButtons.forEach { $0.isEnabled = true } // enable all buttons after the AI move.
        navigationItem.leftBarButtonItem = nil // spinner disappears after the AI move.
        
        if let row = board.nextEmptySlot(in: column) {
            board.add(chip: board.currentPlayer.chip, in: column)
            addChip(inColumn: column, row: row, color: board.currentPlayer.color)
            
            continueGame() // Once the AI move has been made, we'll call continueGame() to check for a win or draw, then flip rurns so the player is in control:
        }
    }
    
    // Putting all the needed things for AI to make a move into one function:
    func startAIMove() {
        columnButtons.forEach { $0.isEnabled = false } // 'forEach' is a way of quickly looping through an array, executing some code on every item in that array. In our case, $0 means "each button in the loop" and in this way all the buttons get disabled.
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.startAnimating()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: spinner)
        
        DispatchQueue.global().async { [unowned self] in
            let strategistTime = CFAbsoluteTimeGetCurrent() // Get the current time.
            guard let column = self.columnForAIMove() else { return }
            let delta = CFAbsoluteTimeGetCurrent() - strategistTime // Get the current time again and compare the difference.
            
            let aiTimeCeiling = 1.0
            let delay = aiTimeCeiling - delta // Substract the time difference from 1 second to form a delay value.
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.makeAIMove(in: column)
            }
        }
    }
    
    func newGameHuman(action: UIAlertAction) {
        gameType = ""
        resetBoard()
    }
    
    func newGameAI(action: UIAlertAction) {
        gameType = "AI"
        resetBoard()
    }
}

