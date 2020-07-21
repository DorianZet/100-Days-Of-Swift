//
//  ActionViewController.swift
//  Extension
//
//  Created by MacBook on 30/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController, UINavigationControllerDelegate {
    @IBOutlet var script: UITextView!
    
    var pageTitle = ""
    var pageURL = ""
    
    var scriptsSaved = [scriptSaved]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadPreviousScripts()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        
        let loadPreviousScriptsButton = UIBarButtonItem(title: "Load previous scripts", style: .plain, target: self, action: #selector(loadPreviousScripts))
        
        navigationItem.rightBarButtonItems = [doneButton, loadPreviousScriptsButton]
        
        let chooseScriptButton = UIBarButtonItem(title: "Scripts", style: .plain, target: self, action: #selector(chooseScript))
        
        let showTableViewButton = UIBarButtonItem(title: "Table", style: .plain, target: self, action: #selector(showTableView))
        
        navigationItem.leftBarButtonItems = [chooseScriptButton, showTableViewButton]
        
        
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
        if let inputItem = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = inputItem.attachments?.first {
                itemProvider.loadItem(forTypeIdentifier: kUTTypePropertyList as String) { [weak self] (dict, error) in

                    guard let itemDictionary = dict as? NSDictionary else { return }
                    guard let javaScriptValues = itemDictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary else { return }

                    self?.pageTitle = javaScriptValues["title"] as? String ?? ""
                    self?.pageURL = javaScriptValues["URL"] as? String ?? ""

                    DispatchQueue.main.async {
                        self?.title = self?.pageTitle
                    }
                }
            }
        }
    }

    @IBAction func done() {
        
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": script.text]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
        
        let url = NSURL(string: self.pageURL)
        let savedScript = scriptSaved(script: script.text, website: (url?.host)!)
        scriptsSaved.append(savedScript)
        if script.text.count > 0 {
            save()
            print("Saving a script.")
        }
    }
    
    @IBAction func chooseScript() {
        let ac = UIAlertController(title: "Choose script:", message: "", preferredStyle: .actionSheet)
        ac.addAction(UIAlertAction(title: "Show title", style: .default, handler: scriptShowTitle))
        ac.addAction(UIAlertAction(title: "Sing a song", style: .default, handler: scriptSingSong))
        ac.addAction(UIAlertAction(title: "Blue background", style: .default, handler: scriptBlueBackground))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func scriptShowTitle(_ action: UIAlertAction) {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": "alert(document.title);"]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    func scriptSingSong(_ action: UIAlertAction) {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": "alert(\"Hello...\"); alert(\"Is it me you're looking for?\"); alert(\"I can see it in your eyes...\"); alert(\"I can see it in your smile...\");"]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
    }
    func scriptBlueBackground (_ action: UIAlertAction) {
        let item = NSExtensionItem()
        let argument: NSDictionary = ["customJavaScript": "document.body.style.background = \"lightblue\";"]
        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
        item.attachments = [customJavaScript]
        extensionContext?.completeRequest(returningItems: [item])
    }
    
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return } // Now we have NSValue (keyboard value) that tells us the size of the keyboard.
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue // Now we read the size of the keyboard.
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window) // Now we get back the converted frame/ the correct sized frame of the keyboard in our rotated screen space.
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            script.contentInset = .zero // don't push the text at all if the keyboard is hidden.
        } else {
            script.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0) // push the text so that its final line is where the keyboard top frame is. The reason why we did bottom like that is to compensate for the safe area existing with a home indicator on X, XR, XS etc. The safeAreaInsets.bottom for standard devices (like SE 2020) is 0, so it makes no difference here.
            script.scrollIndicatorInsets = script.contentInset // scrolling will always match the size of our text view.
            
            // Now we make our text view scroll down to show anything that the user has just tapped on:
            let selectedRange = script.selectedRange
            script.scrollRangeToVisible(selectedRange)
        }
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(scriptsSaved) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "scriptsSaved")
            print("Saved script successfully.")
        } else {
            print("Failed to save scripts.")
        }
    }
    
    
    
    @objc func loadPreviousScripts() { // this will actually load only the first script injected in a website, not the whole array of them.
        let defaults = UserDefaults.standard
        
        if let scriptsToLoad = defaults.object(forKey: "scriptsSaved") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                scriptsSaved = try jsonDecoder.decode([scriptSaved].self, from: scriptsToLoad)
                print("Scripts loaded succesfully.")
                
                for eachSavedScript in scriptsSaved {
                    print(eachSavedScript.script, eachSavedScript.website)
                }
                
                let url = NSURL(string: pageURL)
                print("The host is: \(url?.host)")
                for eachScript in scriptsSaved {
                    if url?.host == eachScript.website {
                        let item = NSExtensionItem()
                        let argument: NSDictionary = ["customJavaScript": eachScript.script]
                        let webDictionary: NSDictionary = [NSExtensionJavaScriptFinalizeArgumentKey: argument]
                        let customJavaScript = NSItemProvider(item: webDictionary, typeIdentifier: kUTTypePropertyList as String)
                        item.attachments = [customJavaScript]
                        extensionContext?.completeRequest(returningItems: [item])
                    }
                }
            } catch {
                print("Failed to load scripts")
            } // if 'do' line fails, the 'catch' method will be executed instead.
        }
    }
    
    @objc func showTableView() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ScriptTableView") as? ScriptTableViewController {
        navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    

}
