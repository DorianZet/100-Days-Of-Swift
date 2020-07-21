//
//  ViewController.swift
//  Day 99. Milestone
//
//  Created by MacBook on 01/07/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var cardButtons = [UIButton]()
    var imagesArray = [String]()
    
    var activatedCards = [UIButton]()
    var guessedCards = [UIButton]()
    
    var timeLabel = UILabel()
    var buttonTapped = false
    
    var time = 91 {
        didSet {
            timeLabel.text = "Time left: \(time)"
        }
    }
    
    var gameTimer: Timer!
    var cardFlipTimer: Timer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesArray = ["cherry", "kiwi", "strawberry", "pineapple", "orange", "lemon", "lime", "peach", "banana", "apple", "cherry", "strawberry", "pineapple", "kiwi", "orange", "lemon", "apple", "lime", "peach", "banana"]
        imagesArray.shuffle()
        
        loadView()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerStarted), userInfo: nil, repeats: true)
        timerStarted()
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemIndigo
    
        let buttonsView = UIView()
        buttonsView.translatesAutoresizingMaskIntoConstraints = false
        buttonsView.layer.borderWidth = 2
        buttonsView.layer.borderColor = UIColor.systemIndigo.cgColor
        buttonsView.layer.backgroundColor = UIColor.systemIndigo.cgColor
        view.addSubview(buttonsView)
        
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textAlignment = .center
        timeLabel.font = .boldSystemFont(ofSize: 40)
        timeLabel.textColor = .white
        timeLabel.text = "Time left: 60"
        view.addSubview(timeLabel)
    
    NSLayoutConstraint.activate([
        timeLabel.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor, constant: 30),
        timeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                   
        buttonsView.widthAnchor.constraint(equalToConstant: 700),
        buttonsView.heightAnchor.constraint(equalToConstant: 800),
        buttonsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        buttonsView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
    ])
    //Now, counting from the TOP LEFT CORNER, we'll be calculating the x and y positions for a button by multiplying our fixed button width (150) by its column position. So, for column 0 that will give an X coordinate of 150x0, which is 0 - the button will appear in the top left corner), and for column 1 that will give an X coordinate of 150x1, which is 150 - the next button will appear right next to the previous one. Same rule applies to the Y coordinate here, which in total creates 20 buttons.
    let width = 140
    let height = 200
    
    for row in 0..<4 {
        for column in 0..<5 {
            let cardButton = UIButton(type: .custom)
            cardButton.adjustsImageWhenHighlighted = false
            cardButton.imageView?.contentMode = .scaleAspectFit

                if !imagesArray.isEmpty {
                    cardButton.setImage(UIImage(named: imagesArray[0]), for: .normal)
                    cardButton.setTitle(imagesArray[0], for: .normal)
                    cardButton.setImage(UIImage(named: "222662_playing-card-png"), for: .normal)
                    imagesArray.remove(at: 0)
                }
            
            cardButton.addTarget(self, action: #selector(buttonUp), for: .touchUpInside)
            cardButton.addTarget(self, action: #selector(buttonDown), for: .touchDown)
            cardButton.addTarget(self, action: #selector(buttonMovedOut), for: .touchDragExit)
            cardButton.addTarget(self, action: #selector(buttonMovedIn), for: .touchDragEnter)

            cardButton.layer.borderWidth = 3
            cardButton.layer.borderColor = UIColor.systemIndigo.cgColor
            cardButton.backgroundColor = .systemRed
            cardButton.layer.cornerRadius = 10
            cardButton.clipsToBounds = true
            cardButton.titleLabel?.font = UIFont.systemFont(ofSize: 36)
            cardButton.setTitleColor(.black, for: .normal)
            
            let frame = CGRect(x: column * width, y: row * height, width: width, height: height)
            cardButton.frame = frame
            
            buttonsView.addSubview(cardButton)
            cardButtons.append(cardButton)
            
            }
        }
    }
    
    @objc func buttonDown(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
    }
    
    @objc func buttonUp(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.001, y: 1)
            
        }, completion: { _ in
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                sender.setImage(UIImage(named: (sender.titleLabel?.text)!), for: .normal)
            }
        })
        
        UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
        sender.isUserInteractionEnabled = false
        activatedCards.append(sender)
        
        if activatedCards.count == 2 {
            for eachButton in cardButtons {
                eachButton.isUserInteractionEnabled = false
            }
            
            if activatedCards[0].title(for: .normal) == activatedCards[1].title(for: .normal) {
                print("+1 point")
                guessedCards.append(activatedCards[0])
                guessedCards.append(activatedCards[1])
                for eachButton in cardButtons {
                    eachButton.isUserInteractionEnabled = true
                }
                for eachCard in guessedCards {
                    UIView.animate(withDuration: 0.3, delay: 0.5, options: [], animations: {
                        eachCard.backgroundColor = .cyan
                    })
                    eachCard.isUserInteractionEnabled = false
                }
                activatedCards.removeAll()
            } else {
                for eachButton in cardButtons {
                    eachButton.isUserInteractionEnabled = true
                }
                for eachCard in guessedCards {
                    eachCard.isUserInteractionEnabled = false
                }
                cardsBackDown()
            }
        }
        
        if guessedCards.count == 20 {
            let ac = UIAlertController(title: "GOOD JOB!", message: "Congrats! Do you want to try again?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Sure!", style: .default, handler: newGame))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
            gameTimer.invalidate()
        }
    }
    
    @objc func buttonMovedOut(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
    }
    
    @objc func buttonMovedIn(_ sender: UIButton) {
        UIView.animate(withDuration: 0.2, delay: 0, options: [], animations: {
            sender.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        })
    }
    
    func cardsBackDown() {
        for each in activatedCards {
            UIView.animate(withDuration: 0.3, delay: 2, options: [], animations: {
                each.transform = CGAffineTransform(scaleX: 0.001, y: 1)
            }, completion: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    each.setImage(UIImage(named: "222662_playing-card-png"), for: .normal)
                }
            })
            
            UIView.animate(withDuration: 0.3, delay: 2.3, options: [], animations: {
                each.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.activatedCards.removeAll()
            })
        }
    }
    
    @objc func timerStarted() {
        time -= 1
        if time == 0 {
            gameTimer.invalidate()
            let ac = UIAlertController(title: "You're slower than my grandma!", message: "Do you want to try again?", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Sure!", style: .default, handler: newGame))
            ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(ac, animated: true)
        }
    }
    
    func newGame(action: UIAlertAction) {
        cardButtons.removeAll()
        imagesArray.removeAll()
        activatedCards.removeAll()
        guessedCards.removeAll()
        time = 91
        
        imagesArray = ["cherry", "kiwi", "strawberry", "pineapple", "orange", "lemon", "lime", "peach", "banana", "apple", "cherry", "strawberry", "pineapple", "kiwi", "orange", "lemon", "apple", "lime", "peach", "banana"]
        imagesArray.shuffle()
        
        loadView()
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerStarted), userInfo: nil, repeats: true)
        timerStarted()
    }
}

