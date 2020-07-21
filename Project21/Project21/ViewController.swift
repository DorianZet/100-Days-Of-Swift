//
//  ViewController.swift
//  Project21
//
//  Created by MacBook on 04/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//
import UserNotifications // we have to import this framework to enable notifications.
import UIKit

class ViewController: UIViewController, UNUserNotificationCenterDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Register", style: .plain, target: self, action: #selector(registerLocal))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Schedule", style: .plain, target: self, action: #selector(scheduleLocal))
    }

    @objc func registerLocal() {
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

    @objc func scheduleLocal() {
        registerCategories() // iOS knows immediately what "alarm" category identifier means.
        
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // cancel pending notifications, i.e. notifications you have scheduled that have yet to be delivered because their trigger hasn't been met
        
        // Defines what will be shown inside the alert:
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese"
        content.categoryIdentifier = "alarm" // we can attach custom actions by specifying the categoryIndentifier property.
        content.userInfo = ["customData": "fizzbuzz"] // to attach custom data to the notification, e.g. an internal ID, use the userInfo dictionary property.
        content.sound = .default // default notification sound.
        
        // Defines when to show the content. In this case - every day, at 10:30.
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
//        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // very nice thing for testing purposes (or just setting the exact moment of the notification) - it means that it will take 5 seconds after the 'Schedule' button is pressed to show the notification.
        
        // Creating a request for the notification, along with a unique string identifier for it:
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    func scheduleForNextDay() {
        registerCategories() // iOS knows immediately what "alarm" means.
            
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests() // cancel pending notifications, i.e. notifications you have scheduled that have yet to be delivered because their trigger hasn't been met
            
        // Defines what will be shown inside the alert:
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese"
        content.categoryIdentifier = "alarm" // we can attach custom actions by specifying the categoryIndentifier property.
        content.userInfo = ["customData": "fizzbuzz"] // to attach custom data to the notification, e.g. an internal ID, use the userInfo dictionary property.
        content.sound = .default // default notification sound.
            
        // Defines when to show the content. In this case - every day, at 10:30.
        var dateComponents = DateComponents()
        dateComponents.hour = 10
        dateComponents.minute = 30
    //  let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false) // very nice thing for testing purposes (or just setting the exact moment of the notification) - it means that it will take 5 seconds after the 'Schedule' button is pressed to show the notification.
            
        // Creating a request for the notification, along with a unique string identifier for it:
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
    
    // Swipe the notification to the right and press 'View' to see what the code below does:
    func registerCategories() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self // Any messages from the notifications get reported back to us.
        
        let show = UNNotificationAction(identifier: "show", title: "Tell me more...", options: .foreground) // foreground = 'when this button is tapped, launch the app immediately"
        let remind = UNNotificationAction(identifier: "remind", title: "Remind me later", options: .destructive)
        let category = UNNotificationCategory(identifier: "alarm", actions: [show, remind], intentIdentifiers: [], options: [])
        
        center.setNotificationCategories([category])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let customData = userInfo["customData"] as? String {
            print("Custom data received: \(customData)")
            // do something more based on the data we received
            
            switch response.actionIdentifier {
            // the user swiped to unlock / the user tapped 'Open':
            case UNNotificationDefaultActionIdentifier:
                let ac = UIAlertController(title: "Default Identifier", message: "The user swiped to unlock.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            // the user tapped "Tell me more..." in 'View':
            case "show":
                let ac = UIAlertController(title: "\"show\" Identifier", message: "The user tapped \"Tell me more...\".", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            // the user tapped "Remind me later" in 'View':
            case "remind":
                scheduleForNextDay()
                let ac = UIAlertController(title: "Notification set for later", message: "You will get notified tomorrow.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            default:
                break
            }
        }
        completionHandler()
    }
}

