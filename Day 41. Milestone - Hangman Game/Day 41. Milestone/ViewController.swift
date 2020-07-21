//
//  ViewController.swift
//  Day 41. Milestone
//
//  Created by MacBook on 03/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class ViewController: UITableViewController {

    var currentAnswer: UILabel!
    var scoreLabel: UILabel!
    var attemptsLeftLabel: UILabel!
    var letters = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    var lettersIndex = 0
    var usedLetters = [String]()
    var activatedButtons = [UIButton]()
    var currentWord: String = ""
    var word: String = ""
    var promptWord: String = ""
    
    var score = 0 {
        didSet {
        scoreLabel.text = "Score: \(score)"
        }
    }
    var attemptsLeft = 7 {
        didSet {
        attemptsLeftLabel.text = "Attempts left: \(attemptsLeft)"
        }
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        scoreLabel.font = UIFont.systemFont(ofSize: 25)
        view.addSubview(scoreLabel)
        
        attemptsLeftLabel = UILabel()
        attemptsLeftLabel.translatesAutoresizingMaskIntoConstraints = false
        attemptsLeftLabel.textAlignment = .right
        attemptsLeftLabel.text = "Attempts left: 7"
        attemptsLeftLabel.font = UIFont.systemFont(ofSize: 25)
        view.addSubview(attemptsLeftLabel)
        
        currentAnswer = UILabel()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        view.addSubview(currentAnswer)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.layer.borderWidth = 2
        buttonsView.layer.borderColor = UIColor.lightGray.cgColor
        buttonsView.layer.backgroundColor = UIColor.lightGray.cgColor
        view.addSubview(buttonsView)
        
        NSLayoutConstraint.activate([
        scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
        scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        
        attemptsLeftLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
        attemptsLeftLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        
        currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        currentAnswer.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100),
        currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),

        buttonsView.widthAnchor.constraint(equalToConstant: 715),
        buttonsView.heightAnchor.constraint(equalToConstant: 180),
        buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        buttonsView.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor, constant: 40),
        ])
        
        let width = 55
        let height = 90
        
        for row in 0..<2 {
            for column in 0..<13 {
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                letterButton.setTitle(letters[lettersIndex].uppercased(), for: .normal)
                lettersIndex += 1
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                letterButton.layer.borderWidth = 1
                letterButton.layer.borderColor = UIColor.lightGray.cgColor
                letterButton.backgroundColor = .white
                
                let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                buttonsView.addSubview(letterButton)
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadLevel()
    }
    
    func newGame(action: UIAlertAction! = nil) {
        score = 0
        attemptsLeft = 7
        promptWord = ""
        usedLetters.removeAll()
        loadLevel()
        for button in activatedButtons {
            button.isHidden = false
        }
    }
    
    func nextLevel(action: UIAlertAction! = nil) {
        attemptsLeft = 7
        promptWord = ""
        usedLetters.removeAll()
        loadLevel()
        for button in activatedButtons {
            button.isHidden = false
        }
    }

    @objc func letterTapped(_ sender: UIButton) {
        usedLetters.append(sender.titleLabel!.text!)
        sender.isHidden = true //Hides the button, so we make sure it won't be clicked again.
        activatedButtons.append(sender)
        
        for letter in word {
            let strLetter = String(letter)
            if usedLetters.contains(strLetter) {
                if let position = word.firstIndex(of: letter) {
                    word.remove(at: position)
                    word.insert("?", at: position)
                    promptWord.remove(at: position)
                    promptWord.insert(letter, at: position)
                }
            }
        }
        currentAnswer.text = promptWord

        if !currentWord.contains(sender.titleLabel!.text!) {
            attemptsLeft -= 1
        }
        
        let nextLevelAlert = UIAlertController(title: "Woohoo!", message: "You managed to avoid the hanging! Ready for the next level?", preferredStyle: .alert)
        nextLevelAlert.addAction(UIAlertAction(title: "Let's do this!", style: .default, handler: nextLevel))
        if promptWord == currentWord {
            score += 1
            present(nextLevelAlert, animated: true)
        }
        
        
        let gameOverAlert = UIAlertController(title: "GAME OVER!", message: "Your final score is \(score).", preferredStyle: .alert)
        gameOverAlert.addAction(UIAlertAction(title: "New Game", style: .default, handler: newGame))
        
        if attemptsLeft == 0 && promptWord != currentWord {
            present(gameOverAlert, animated: true)
        }
    }
        
    func loadLevel() {
        if let wordListFileURL = Bundle.main.url(forResource: "wordList", withExtension: "txt") {
        if let wordListContents = try? String(contentsOf: wordListFileURL) {
            var lines = wordListContents.components(separatedBy: "\n")
                   lines.shuffle()
            currentWord = lines[0]
            word = lines[0]
            for letter in currentWord {
                let strLetter = String(letter)
                if usedLetters.contains(strLetter) {
                    promptWord += strLetter
                } else {
                    promptWord += "?"
                }
            }
            currentAnswer.text = promptWord
            }
        }
    }

}
