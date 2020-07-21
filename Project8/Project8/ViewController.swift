//
//  ViewController.swift
//  Project8
//
//  Created by MacBook on 28/04/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var cluesLabel: UILabel!
    var answersLabel: UILabel!
    var currentAnswer: UITextField!
    var scoreLabel: UILabel!
    var letterButtons = [UIButton]()
    
    var activatedButtons = [UIButton]()
    var solutions = [String]()
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        } // didSet is a property observer, which lets you execute code whenever a property has changed. In our case, we want to add a property observer to our score property so that we update the score whenever the score value has changed.
    }
    var level = 1
    var matchedItems = 0
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        scoreLabel = UILabel()
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false
        scoreLabel.textAlignment = .right
        scoreLabel.text = "Score: 0"
        view.addSubview(scoreLabel)

        cluesLabel = UILabel()
        cluesLabel.translatesAutoresizingMaskIntoConstraints = false
        cluesLabel.font = UIFont.systemFont(ofSize: 20)
        cluesLabel.text = "CLUES"
        cluesLabel.numberOfLines = 0 // This means that a clue will be wrapped in as many lines as needed.
        cluesLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical) // 1 is the LOWEST priority of keeping the label in the shape we wanted it at first, which means that it will be the first one to change to resolve any of the auto-layout issues.
        view.addSubview(cluesLabel)
        
        answersLabel = UILabel()
        answersLabel.translatesAutoresizingMaskIntoConstraints = false
        answersLabel.font = UIFont.systemFont(ofSize: 20)
        answersLabel.text = "ANSWERS"
        answersLabel.numberOfLines = 0
        answersLabel.textAlignment = .right
        answersLabel.setContentHuggingPriority(UILayoutPriority(1), for: .vertical)
        view.addSubview(answersLabel)
        
        currentAnswer = UITextField()
        currentAnswer.translatesAutoresizingMaskIntoConstraints = false
        currentAnswer.placeholder = "Tap letters to guess"
        currentAnswer.textAlignment = .center
        currentAnswer.font = UIFont.systemFont(ofSize: 44)
        currentAnswer.isUserInteractionEnabled = false // This command stops the user from activating the text field and typing into it.
        view.addSubview(currentAnswer)
        
        let submit = UIButton(type: .system)
        submit.translatesAutoresizingMaskIntoConstraints = false
        submit.setTitle("SUBMIT", for: .normal)
        submit.addTarget(self, action: #selector(submitTapped), for: .touchUpInside) // .touchUpInside - way of saying that the user pressed down on the button and lifted their touch while it was still inside.
        view.addSubview(submit)
        
        let clear = UIButton(type: .system)
        clear.translatesAutoresizingMaskIntoConstraints = false
        clear.setTitle("CLEAR", for: .normal)
        clear.addTarget(self, action: #selector(clearTapped), for: .touchUpInside)
        view.addSubview(clear)
        
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.layer.borderWidth = 2
        buttonsView.layer.borderColor = UIColor.lightGray.cgColor
        buttonsView.layer.backgroundColor = UIColor.lightGray.cgColor
        view.addSubview(buttonsView)
        
        NSLayoutConstraint.activate([
            scoreLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            scoreLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            cluesLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            cluesLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor, constant: 100),
            cluesLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.6, constant: -100),
            
            answersLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor),
            answersLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor, constant: -100),
            answersLabel.widthAnchor.constraint(equalTo: view.layoutMarginsGuide.widthAnchor, multiplier: 0.4, constant: -100),
            answersLabel.heightAnchor.constraint(equalTo: cluesLabel.heightAnchor),
            
            currentAnswer.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            currentAnswer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.5),
            currentAnswer.topAnchor.constraint(equalTo: cluesLabel.bottomAnchor, constant: 20),
            
            submit.topAnchor.constraint(equalTo: currentAnswer.bottomAnchor),
            submit.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            submit.heightAnchor.constraint(equalToConstant: 44),
            
            clear.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 100),
            clear.centerYAnchor.constraint(equalTo: submit.centerYAnchor),
            clear.heightAnchor.constraint(equalToConstant: 44),
            
            buttonsView.widthAnchor.constraint(equalToConstant: 750),
            buttonsView.heightAnchor.constraint(equalToConstant: 320),
            buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            buttonsView.topAnchor.constraint(equalTo: submit.bottomAnchor, constant: 20),
            buttonsView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -20)
            ])
        
        //Now, counting from the TOP LEFT CORNER, we'll be calculating the x and y positions for a button by multiplying our fixed button width (150) by its column position. So, for column 0 that will give an X coordinate of 150x0, which is 0 - the button will appear in the top left corner), and for column 1 that will give an X coordinate of 150x1, which is 150 - the next button will appear right next to the previous one. Same rule applies to the Y coordinate here, which in total creates 20 buttons.
        let width = 150
        let height = 80
        
        for row in 0..<4 {
            for column in 0..<5 {
                let letterButton = UIButton(type: .system)
                letterButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
                letterButton.setTitle("WWW", for: .normal)
                letterButton.addTarget(self, action: #selector(letterTapped), for: .touchUpInside)
                letterButton.layer.borderWidth = 1
                letterButton.layer.borderColor = UIColor.lightGray.cgColor
                letterButton.backgroundColor = .white
                
                let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
                letterButton.frame = frame
                
                buttonsView.addSubview(letterButton)
                letterButtons.append(letterButton)
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadLevel()
    }

    @objc func letterTapped(_ sender: UIButton) {
        guard let buttonTitle = sender.titleLabel?.text else { return } //guard let adds a safety check to read the title from the tapped button, or exit if it didn't have one for some reason.
        currentAnswer.text = currentAnswer.text?.appending(buttonTitle) //appends the button title to the player's current answer.
        activatedButtons.append(sender) //Appends the button to the activated buttons array so we know it has been tapped.
        
        UIView.animate(withDuration: 0.8, delay: 0, options: [], animations: {
            sender.alpha = 0 // Fades the button away in 0.8sec.
        }) { finished in
            sender.isHidden = true //Hides the button, so we make sure it won't be clicked again.
        }
         
    }
    
    @objc func submitTapped(_ sender: UIButton) {
        guard let answerText = currentAnswer.text else { return }
        
        //If the user gets an answer correct, we're going to change the answers label so that rather than saying "7 LETTERS" it says "HAUNTED", so they know which ones they have solved already. firstIndex(of:) will tell us which solution matched their word, then we can use that position to find the matching clue next. All we need to do is split the answer label text up by \n, replace the line at the solution position with the solution itself, then re-join the answers label back together.
        if let solutionPosition = solutions.firstIndex(of: answerText) {
            activatedButtons.removeAll()
            
            var splitAnswers = answersLabel.text?.components(separatedBy: "\n") //We create a property, where the text of answersLabel is separated by \n. First component is splitAnswers[0], 2nd - splitAnswers[1] and so on.
            splitAnswers?[solutionPosition] = answerText //answerText is placed in the right line, replacing what's been before ("x letters").
            answersLabel?.text = splitAnswers?.joined(separator: "\n") //We edit the answersLabel.text, so that now it's a set of splitAnswers, with shown answers in the lines which numbers accord to solutionPosition.
            
            currentAnswer.text = ""
            score += 1
            matchedItems += 1
            
            if matchedItems % 7 == 0 {
                let ac = UIAlertController(title: "Well done!", message: "Are you ready for the next level?", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Let's go!", style: .default, handler: levelUp))
                present(ac, animated: true)
            }
        } else {
            let ac = UIAlertController(title: "Wrong answer, try again!", message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: clearAfterOK))
            present(ac, animated: true)
            score -= 1
        }
    }
    
    func clearAfterOK(action: UIAlertAction) {
        currentAnswer.text = ""
    
        for button in activatedButtons {
        button.isHidden = false
        button.alpha = 1
        } //Re-show every button that has been tapped (because all the tapped buttons are added to activatedButtons array earlier).
    
        activatedButtons.removeAll()
    }
    
    func levelUp(action: UIAlertAction) {
        level += 1
        
        solutions.removeAll(keepingCapacity: true)
        loadLevel()
        
        for button in letterButtons {
            button.isHidden = false
        }
    }
    
    @objc func clearTapped (_ sender: UIButton) {
        currentAnswer.text = "" //Clears the answer field.
        
        for button in activatedButtons {
            button.isHidden = false
            button.alpha = 1
        } //Re-show every button that has been tapped (because all the tapped buttons are added to activatedButtons array earlier).
        activatedButtons.removeAll()
    }
    
    func loadLevel() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            var clueString = ""
            var solutionsString = ""
            var letterBits = [String]()
                   
            if let levelFileURL = Bundle.main.url(forResource: "level\(self!.level)", withExtension: "txt") {
                if let levelContents = try? String(contentsOf: levelFileURL) {
                    var lines = levelContents.components(separatedBy: "\n")
                           lines.shuffle()
                           
                    for (index, line) in lines.enumerated() {
                        let parts = line.components(separatedBy: ": ")
                        let answer = parts[0]
                        let clue = parts[1]
                               
                        clueString += "\(index + 1). \(clue)\n"
                               
                        let solutionWord = answer.replacingOccurrences(of: "|", with: "")
                        solutionsString += "\(solutionWord.count) letters\n"
                        self?.solutions.append(solutionWord)
                               
                        let bits = answer.components(separatedBy: "|")
                        letterBits += bits
                    }
                }
            }
            
            // .trimmingCharacters method removes any letters you specify from the start and end of a string. We need that here because our clue string and solutions string will both end up with an extra line break. To put it simple: 'clueString' is a collection of all \(clue). The last \(clue) also has a line break, which we don't want in the clues view. The same thing applies to the 'solutionsString'. These line breaks need to be trimmed:
            DispatchQueue.main.async { [weak self] in
                self?.cluesLabel.text = clueString.trimmingCharacters(in: .whitespacesAndNewlines)
                self?.answersLabel.text = solutionsString.trimmingCharacters(in: .whitespacesAndNewlines)
                self?.letterButtons.shuffle()
                
                if self?.letterButtons.count == letterBits.count { // letterButtons.count will always be the same as letterBits.count, but we are just making sure.
                    for i in 0..<self!.letterButtons.count {
                        self!.letterButtons[i].setTitle(letterBits[i], for: .normal)
                    }
                }
            }
        }
    }
}
