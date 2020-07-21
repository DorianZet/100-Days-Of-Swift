//
//  ViewController.swift
//  Project2
//
//  Created by MacBook on 11/04/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//
import UserNotifications // we have to import this framework to enable notifications.
import UIKit

class ViewController: UIViewController {
    @IBOutlet var button1: UIButton!
    @IBOutlet var button2: UIButton!
    @IBOutlet var button3: UIButton!
   
    let defaults = UserDefaults.standard
    
    var notificationRegistered = false
    
    var countries = [String]()
    var score = 0
    var correctAnswer = 0
    var questionNumber = 1
    
    var highScore = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if notificationRegistered == false {
            registerLocal() // asks for a notification permission when the app is launched for the first time.
            notificationRegistered = true
        }
        // The user will get notifications to get back into the game every 24 hours for the next 7 days after he launched the app"
        scheduleLocal1Day() // only the first schedule should removeAllPendingNotificationsRequests, because each of the next ones would cancel the ones before them. In result, if all of them had removed all pending requests, only scheduleLocal7Day() would work, because it would cancel all the 6 previous ones.
        scheduleLocal2Day()
        scheduleLocal3Day()
        scheduleLocal4Day()
        scheduleLocal5Day()
        scheduleLocal6Day()
        scheduleLocal7Day()
        
        let previousHighScore = defaults.integer(forKey: "highScore")
        highScore = previousHighScore
        
        countries += ["estonia", "france", "germany", "ireland", "italy", "monaco", "nigeria", "poland", "russia", "spain", "uk", "us"]

        print(defaults.integer(forKey: "highScore"))
    
        button1.layer.borderWidth = 1
        button2.layer.borderWidth = 1
        button3.layer.borderWidth = 1
        
        button1.layer.borderColor = UIColor.lightGray.cgColor
        button2.layer.borderColor = UIColor.lightGray.cgColor
        button3.layer.borderColor = UIColor.lightGray.cgColor
        // In buttonTapped method, we have the animation for the button going up:
        button1.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button2.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        button3.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        // In buttonDown method, we have the animation for the button going down:
        button1.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        button2.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        button3.addTarget(self, action: #selector(buttonDown), for: .touchDown)
        // In buttonCancel method, we have the animation for dragging the finger away from the pressed button:
        button1.addTarget(self, action: #selector(buttonCancel), for: .touchDragExit)
        button2.addTarget(self, action: #selector(buttonCancel), for: .touchDragExit)
        button3.addTarget(self, action: #selector(buttonCancel), for: .touchDragExit)

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareScore))
        
        askQuestion()
    }
    
    func registerLocal() {
        let center = UNUserNotificationCenter.current()
        // trailing closure syntax:
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Yay!")
            } else {
                print("D'oh!")
            }
        }
    }
    
    func scheduleLocal1Day() {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // cancel pending notifications, i.e. notifications you have scheduled that have yet to be delivered because their trigger hasn't been met
            
        // Defines what will be shown inside the alert:
        let content = UNMutableNotificationContent()
        content.title = "It's time to play \"Guess The Flag\"!"
        content.body = "Are you up for some guessing today? Test your knowledge!"
        content.categoryIdentifier = "alarm" // we can attach custom actions by specifying the categoryIndentifier property.
        content.userInfo = ["customData": "fizzbuzz"] // to attach custom data to the notification, e.g. an internal ID, use the userInfo dictionary property.
        content.sound = .default // default notification sound.
            
            // Defines when to show the content.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false)
            
            // Creating a request for the notification, along with a unique string identifier for it:
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
    }
    
    func scheduleLocal2Day() {
        let center = UNUserNotificationCenter.current()
            
        // Defines what will be shown inside the alert:
        let content = UNMutableNotificationContent()
        content.title = "It's time to play \"Guess The Flag\"!"
        content.body = "Are you up for some guessing today? Test your knowledge!"
        content.categoryIdentifier = "alarm" // we can attach custom actions by specifying the categoryIndentifier property.
        content.userInfo = ["customData": "fizzbuzz"] // to attach custom data to the notification, e.g. an internal ID, use the userInfo dictionary property.
        content.sound = .default // default notification sound.
            
            // Defines when to show the content.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 172800, repeats: false)
            
            // Creating a request for the notification, along with a unique string identifier for it:
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
    }
    
    func scheduleLocal3Day() {
        let center = UNUserNotificationCenter.current()

        // Defines what will be shown inside the alert:
        let content = UNMutableNotificationContent()
        content.title = "It's time to play \"Guess The Flag\"!"
        content.body = "Are you up for some guessing today? Test your knowledge!"
        content.categoryIdentifier = "alarm" // we can attach custom actions by specifying the categoryIndentifier property.
        content.userInfo = ["customData": "fizzbuzz"] // to attach custom data to the notification, e.g. an internal ID, use the userInfo dictionary property.
        content.sound = .default // default notification sound.
            
            // Defines when to show the content.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 259200, repeats: false)
            
            // Creating a request for the notification, along with a unique string identifier for it:
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
    }
    
    func scheduleLocal4Day() {
        let center = UNUserNotificationCenter.current()
            
        // Defines what will be shown inside the alert:
        let content = UNMutableNotificationContent()
        content.title = "It's time to play \"Guess The Flag\"!"
        content.body = "Are you up for some guessing today? Test your knowledge!"
        content.categoryIdentifier = "alarm" // we can attach custom actions by specifying the categoryIndentifier property.
        content.userInfo = ["customData": "fizzbuzz"] // to attach custom data to the notification, e.g. an internal ID, use the userInfo dictionary property.
        content.sound = .default // default notification sound.
            
            // Defines when to show the content.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 345600, repeats: false)
            
            // Creating a request for the notification, along with a unique string identifier for it:
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
    }
    
    func scheduleLocal5Day() {
        let center = UNUserNotificationCenter.current()
            
        // Defines what will be shown inside the alert:
        let content = UNMutableNotificationContent()
        content.title = "It's time to play \"Guess The Flag\"!"
        content.body = "Are you up for some guessing today? Test your knowledge!"
        content.categoryIdentifier = "alarm" // we can attach custom actions by specifying the categoryIndentifier property.
        content.userInfo = ["customData": "fizzbuzz"] // to attach custom data to the notification, e.g. an internal ID, use the userInfo dictionary property.
        content.sound = .default // default notification sound.
            
            // Defines when to show the content.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 432000, repeats: false)
            
            // Creating a request for the notification, along with a unique string identifier for it:
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
    }
    
    func scheduleLocal6Day() {
        let center = UNUserNotificationCenter.current()
            
        // Defines what will be shown inside the alert:
        let content = UNMutableNotificationContent()
        content.title = "It's time to play \"Guess The Flag\"!"
        content.body = "Are you up for some guessing today? Test your knowledge!"
        content.categoryIdentifier = "alarm" // we can attach custom actions by specifying the categoryIndentifier property.
        content.userInfo = ["customData": "fizzbuzz"] // to attach custom data to the notification, e.g. an internal ID, use the userInfo dictionary property.
        content.sound = .default // default notification sound.
            
            // Defines when to show the content.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 518400, repeats: false)
            
            // Creating a request for the notification, along with a unique string identifier for it:
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
    }
    
    func scheduleLocal7Day() {
        let center = UNUserNotificationCenter.current()
        
        // Defines what will be shown inside the alert:
        let content = UNMutableNotificationContent()
        content.title = "It's time to play \"Guess The Flag\"!"
        content.body = "Are you up for some guessing today? Test your knowledge!"
        content.categoryIdentifier = "alarm" // we can attach custom actions by specifying the categoryIndentifier property.
        content.userInfo = ["customData": "fizzbuzz"] // to attach custom data to the notification, e.g. an internal ID, use the userInfo dictionary property.
        content.sound = .default // default notification sound.
            
            // Defines when to show the content.
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 604800, repeats: false)
            
            // Creating a request for the notification, along with a unique string identifier for it:
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
    }
    
    func askQuestion(action: UIAlertAction! = nil) {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)

        button1.setImage(UIImage(named: countries[0]), for: .normal)
        button2.setImage(UIImage(named: countries[1]), for: .normal)
        button3.setImage(UIImage(named: countries[2]), for: .normal)
        
        title = "QUESTION \(questionNumber): "
        title?.append(countries[correctAnswer].uppercased())
        title?.append(" | S: \(score) | HS: \(highScore)")
    }
    
    @IBAction func buttonTapped(_ sender: UIButton) {
        var title: String
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 30, options: [], animations: {
            self.button1.transform = .identity
            self.button2.transform = .identity
            self.button3.transform = .identity
        })
        
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

        let highScoreAlert = UIAlertController(title: "Game over! High score!", message: "Your high score is \(score)!", preferredStyle: .alert)
        highScoreAlert.addAction(UIAlertAction(title: "Start again", style: .default, handler: askQuestion))
        
        if questionNumber <= 10 {
        present(ac, animated: true)
        }
        
        // Setting the high score alerts:
        if questionNumber > 10 {
            if highScore == 0 && score > 0 {
                highScore = score
                defaults.set(highScore, forKey: "highScore")
                present(highScoreAlert, animated: true)
            } else if score > highScore {
                highScore = score
                defaults.set(highScore, forKey: "highScore")
                present(highScoreAlert, animated: true)
            }
            else {
                present(finalAlert, animated: true)
            }
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
    
    @objc func buttonDown(_ sender: UIButton) {
       UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 30, options: [], animations: {
        sender.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
       })
    }
    
    @objc func buttonCancel(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 30, options: [], animations: {
            sender.transform = .identity
        })
    }
    
    


}
