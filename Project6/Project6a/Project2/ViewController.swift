//
//  ViewController.swift
//  Project2
//
//  Created by MacBook on 11/04/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var questionNumber = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]

        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareScore))
        
        askQuestion()
    }

    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)

        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        title = "QUESTION \(questionNumber): "
        title?.append(countries[correctAnswer].uppercased())
        title?.append(" [YOUR SCORE: \(score)]")
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        
        if sender.tag == correctAnswer {
            title = "Correct"
            score += 1
            questionNumber += 1
        } else {
            title = "Wrong! That's the flag of \(countries[sender.tag].capitalized)."
            if countries[sender.tag] == "uk" || countries[sender.tag] == "us" {
                title = "Wrong! That's the flag of \(countries[sender.tag].uppercased())."
            }
            score -= 1
            questionNumber += 1
        }
        
        let ac = UIAlertController(title: title, message: "Your score is \(score)", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Continue", style: .default, handler: askQuestion))
        let finalAlert = UIAlertController(title: "GAME OVER", message: "Your final score is \(score)", preferredStyle: .alert)
        finalAlert.addAction(UIAlertAction(title: "Start again", style: .default, handler: askQuestion))
        
        if questionNumber <= 10 {
        present(ac, animated: true)
        }
        
        if questionNumber > 10 {
            present(finalAlert, animated: true)
            score = 0
            questionNumber = 1
        }
    }
    
    @objc func shareScore() {
        let scoreShare = ["My score is \(score)!"]
        let vc = UIActivityViewController(activityItems: scoreShare, applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
}
