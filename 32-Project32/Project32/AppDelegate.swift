//
//  AppDelegate.swift
//  Project32
//
//  Created by MacBook on 07/07/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//
import CoreSpotlight
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle // I DELETED THE UISCENE MANIFEST AND CODE, SAME AS IN PROJECT 25, ONLY THEN THE CODE BELOW WILL WORK.
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if userActivity.activityType == CSSearchableItemActionType {
            if let uniqueIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
                if let navigationController = window?.rootViewController as? UINavigationController {
                    if let viewController = navigationController.topViewController as? ViewController {
                        viewController.showTutorial(Int(uniqueIdentifier)!)
                    }
                }
            }
        }
        return true
    }

}

