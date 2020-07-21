//
//  ViewController.swift
//  Project28
//
//  Created by MacBook on 24/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import LocalAuthentication // lets us use touchID and faceID.
import UIKit

class ViewController: UIViewController {
    @IBOutlet var secret: UITextView!
    
    var currentPassword: String?
    
    var isPasswordSet: Bool?
    var timesTried = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Nothing to see here"
        
        // Loading app settings:
        let defaults = UserDefaults.standard
        let savedBoolean = defaults.bool(forKey: "isPasswordSet")
        let timesTriedSaved = defaults.integer(forKey: "timesTried")
        
        isPasswordSet = savedBoolean
        timesTried = timesTriedSaved
        
        print(timesTried)

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        // The app automatically saves any text and hide it when the app is moving to a background state:
        notificationCenter.addObserver(self, selector: #selector(saveSecretMessage), name: UIApplication.willResignActiveNotification, object: nil)
        
        if isPasswordSet == false {
            let ac = UIAlertController(title: "Set your password:", message: nil, preferredStyle: .alert)
            ac.addTextField()
            ac.textFields![0].isSecureTextEntry = true

            ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
                guard let password = ac?.textFields![0].text else { return }
                
                self?.currentPassword = password
                self?.isPasswordSet = true
                
                self?.savePassword(password: password)
                // Saving the boolean for isPasswordSet, so that the prompt for setting a password doesn't appear every time we launch the app:
                defaults.set(true, forKey: "isPasswordSet")
            })
            present(ac, animated: true)
        }
    }

    @IBAction func authenticateTapped(_ sender: Any) {
        let context = LAContext()
        var error: NSError?
        // FaceID or touchID identification will work only of we tried less than 3 times; otherwise we need to provide the password.
        if timesTried <= 2 {
            // '&error' means: "Don't pass the error itself, pass in WHERE that value is in RAM, so it can be overwritten with a new value if something goes wrong.
            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Identify yourself!" // will be shown to the touchID users, NOT faceID. To make it work with faceID, we need to add "Privacy - Face ID Usage Description" row in the Info.plist.
                
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    // The reason we are doing a closure here is because it takes time - user looks at the screen and focus their eyes on the screen or press the finger on the touchID sensor. So, because it takes time, we don't want to block the main thread while that's happening, so it's a closure that runs asynchronously somewhere else.
                    [weak self] success, autenthicationError in
                    DispatchQueue.main.async {
                        if success {
                            self?.unlockSecretMessage()
                            self?.timesTried = 0
                            self?.saveTimesTried(timesTried: self!.timesTried)
                        } else {
                            self?.timesTried += 1
                            self?.saveTimesTried(timesTried: self!.timesTried)

                            if self!.timesTried > 2 {
                                
                                let ac = UIAlertController(title: "Enter the password:", message: nil, preferredStyle: .alert)
                                ac.addTextField()
                                ac.textFields![0].isSecureTextEntry = true

                                
                                ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
                                    guard let enteredPassword = ac?.textFields![0].text else { return }
                                    
                                    if let setPassword = KeychainWrapper.standard.string(forKey: "Password") {
                                        if enteredPassword == setPassword {
                                            self?.unlockSecretMessage()
                                            self?.timesTried = 0
                                            self?.saveTimesTried(timesTried: self!.timesTried)
                                        } else {
                                            // If we enter a wrong password, new ac appears, with a different title:
                                            let ac1 = UIAlertController(title: "Wrong password! Try again:", message: nil, preferredStyle: .alert)
                                            ac1.addTextField()
                                            ac1.textFields![0].isSecureTextEntry = true

                                            ac1.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac1] _ in
                                                guard let enteredPassword = ac1?.textFields![0].text else { return }
                                                
                                                if let setPassword = KeychainWrapper.standard.string(forKey: "Password") {
                                                    if enteredPassword == setPassword {
                                                        self?.unlockSecretMessage()
                                                        self?.timesTried = 0
                                                        self?.saveTimesTried(timesTried: self!.timesTried)
                                                    } else {
                                                        // If the password is wrong, the ac appears again:
                                                        self?.present(ac1!, animated: true)
                                                    }
                                                }
                                            })
                                            self?.present(ac1, animated: true)
                                        }
                                    }
                                })
                                self?.present(ac, animated: true)
                            }
                        }
                    }
                }
            } else {
                let ac = UIAlertController(title: "Biometry unavailable", message: "Your device is not configured for biometric authentication.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
            // If we tap the authentification button, but have tried more than 2 times before and failed, a prompt for a password will appear:
        } else {
            let ac = UIAlertController(title: "Enter the password:", message: nil, preferredStyle: .alert)
            ac.addTextField()
            ac.textFields![0].isSecureTextEntry = true

            ac.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac] _ in
                guard let enteredPassword = ac?.textFields![0].text else { return }
                
                if let setPassword = KeychainWrapper.standard.string(forKey: "Password") {
                    if enteredPassword == setPassword {
                        self?.unlockSecretMessage()
                        self?.timesTried = 0
                        self?.saveTimesTried(timesTried: self!.timesTried)
                    } else {
                        // If we enter a wrong password, new ac appears, with a different title:
                        let ac1 = UIAlertController(title: "Wrong password! Try again:", message: nil, preferredStyle: .alert)
                        ac1.addTextField()
                        ac1.textFields![0].isSecureTextEntry = true

                        ac1.addAction(UIAlertAction(title: "OK", style: .default) { [weak self, weak ac1] _ in
                            guard let enteredPassword = ac1?.textFields![0].text else { return }
                            
                            if let setPassword = KeychainWrapper.standard.string(forKey: "Password") {
                                if enteredPassword == setPassword {
                                    self?.unlockSecretMessage()
                                    self?.timesTried = 0
                                    self?.saveTimesTried(timesTried: self!.timesTried)
                                } else {
                                    self?.present(ac1!, animated: true)
                                }
                            }
                        })
                        self?.present(ac1, animated: true)
                    }
                }
            })
            self.present(ac, animated: true)
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEnd = keyboardValue.cgRectValue // size of the keyboard relative to the screen, not relative to the view.
        let keyboardViewEndFrame = view.convert(keyboardScreenEnd, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            secret.contentInset = .zero
        } else {
            secret.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
        }
        
        secret.scrollIndicatorInsets = secret.contentInset // scroll matches the size of the textView.
        
        let selectedRange = secret.selectedRange
        secret.scrollRangeToVisible(selectedRange)
    }
    
    func unlockSecretMessage() {
        secret.isHidden = false
        title = "Secret stuff!"
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(saveSecretMessage))
        navigationItem.rightBarButtonItems = [doneButton]
        
        if let text = KeychainWrapper.standard.string(forKey: "SecretMessage") {
            secret.text = text
        }

//        OR:
//        secret.text = KeychainWrapper.standard.string(forKey: "SecretMessage") ?? ""
//        THIS MEANS: "Try to read that key from the keychain, otherwise provide the empty string."
    }
    
    @objc func saveSecretMessage() {
        guard secret.isHidden == false else { return }
        
        KeychainWrapper.standard.set(secret.text, forKey: "SecretMessage")
        secret.resignFirstResponder() // stop being active on the screen right now. "We're finished editing text view, so the keyboard can be hidden".
        secret.isHidden = true
        title = "Nothing to see here"
        
        navigationItem.rightBarButtonItems = nil
    }
    
    func savePassword(password: String) {
        KeychainWrapper.standard.set(password, forKey: "Password")
    }
    
    func saveTimesTried(timesTried: Int) {
        let defaults = UserDefaults.standard
        defaults.set(timesTried, forKey: "timesTried")
    }
}

