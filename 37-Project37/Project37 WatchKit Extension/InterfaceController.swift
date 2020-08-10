//
//  InterfaceController.swift
//  Project37 WatchKit Extension
//
//  Created by Mateusz Zacharski on 23/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import WatchConnectivity
import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet var welcomeText: WKInterfaceLabel!
    @IBOutlet var hideButton: WKInterfaceButton!
    @IBOutlet var alwaysWinButton: WKInterfaceButton!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func hideWelcomeText() {
        welcomeText.setHidden(true) // not that we need to use 'setHidden()' rather than just changing a 'isHidden' property as we would in UIKit.
        hideButton.setHidden(true)
        alwaysWinButton.setHidden(false)
    }
    
    // To hide the button, change its font and background colors to "clear" in the storyboard:
    @IBAction func toggleAlwaysWinMode() {
        if (WCSession.default.isReachable) {
            // this is a meaningless message, but it's enough for our purposes. Once the message is received on the phone, 'Always Win Mode' will be toggled:
            let message = ["WinMode": "WinMode"]
            WCSession.default.sendMessage(message, replyHandler: nil)
        }
    }
    
    
    
    // When the watch receives a message, play a haptic effect:
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        WKInterfaceDevice().play(.click)
        print("That's the right card!")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // this method is needed to satisfy WCSessionDelegate protocol, we can leave it empty here.
    }
    
}
