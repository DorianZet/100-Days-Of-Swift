//
//  DetailViewController.swift
//  Day 74. Milestone
//
//  Created by MacBook on 06/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextViewDelegate {
    @IBOutlet var noteName: UITextView!
    @IBOutlet var noteText: UITextView!
    @IBOutlet var line1px: UIImageView!
    
    
    var notes = [Note]()
    var nameToLoad = ""
    var textToLoad = ""
    var rowNumber: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
       navigationItem.largeTitleDisplayMode = .never

        noteName.delegate = self
        noteText.delegate = self
        
        view.backgroundColor = .systemYellow
        
        noteName.backgroundColor = .clear
        noteName.font = .systemFont(ofSize: 38, weight: .bold)
        noteName.textColor = UIColor.brown
        noteName.alpha = 0.5
        noteName.text = "Title"
        
        noteText.backgroundColor = .clear
        noteText.font = .systemFont(ofSize: 21)
        noteText.textColor = UIColor.brown
        noteText.alpha = 0.5
        noteText.text = "Enter your note here"
        
        line1px.alpha = 0.19
        
       
        loadNotes()
        
        if rowNumber != nil {
            noteName.text = nameToLoad
            noteText.text = textToLoad
            noteName.textColor = UIColor.black
            noteName.alpha = 1
            noteText.textColor = UIColor.black
            noteText.alpha = 1
        }
        
        
        let shareNoteButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareNote))
        let addNoteButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(addNote))
        let deleteNoteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNote))
        navigationItem.rightBarButtonItems = [addNoteButton, deleteNoteButton, shareNoteButton]
        
        self.navigationController?.navigationBar.tintColor = .brown
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    
    @IBAction func addNote() {
        if rowNumber == nil {
            addNewNote()
        } else {
            saveExistingNote()
        }
    }
    
    @objc func deleteNote() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "TableID") as? ViewController {
            navigationController?.popToRootViewController(animated: true)
            loadNotes()
            vc.tableView.reloadData()
            if let rowToDelete = rowNumber {
                vc.notes.remove(at: rowToDelete)
                vc.tableView.reloadData()
                vc.save()
            }
        }
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        
        if let savedData = try? jsonEncoder.encode(notes) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "notes")
        } else {
            print("Failed to save notes.")
        }
    }
    
    func loadNotes() {
        let defaults = UserDefaults.standard
        
        if let notesToLoad = defaults.object(forKey: "notes") as? Data {
            let jsonDecoder = JSONDecoder()
            
            do {
                notes = try jsonDecoder.decode([Note].self, from: notesToLoad)
                print("Notes loaded to detail view successfully.")
            } catch {
                print("Failed to load notes.")
            }
        }
    }
    
    @objc func shareNote() {
        if noteText.text != "" && noteName.textColor != UIColor.brown {
            if let sharedName = noteName.text {
                if let sharedText = noteText.text {
                    if noteName.text == "" {
                        let sharedNote = sharedText
                        let vc = UIActivityViewController(activityItems: [sharedNote], applicationActivities: [])
                        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
                        present(vc, animated: true)
                    } else {
                        let sharedNote = "\(sharedName):\n\(sharedText)"
                        let vc = UIActivityViewController(activityItems: [sharedNote], applicationActivities: [])
                        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
                        present(vc, animated: true)
                    }
                }
            }
        } else {
            let ac = UIAlertController(title: "Nothing to share!", message: "Create your note first!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if noteName.textColor == UIColor.brown {
            noteName.text = nil
            noteName.textColor = UIColor.black
            noteName.alpha = 1
        }
        
        if noteText.textColor == UIColor.brown {
            noteText.text = nil
            noteText.textColor = UIColor.black
            noteText.alpha = 1
        }
    }
    
    // Worth noting: adjustForKeyboard() started to work again after I changed constraint bottomMargin = Note Text.bottom from -34 to 0.
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return } // Now we have NSValue (keyboard value) that tells us the size of the keyboard.
           
        let keyboardScreenEndFrame = keyboardValue.cgRectValue // Now we read the size of the keyboard.
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window) // Now we get back the converted frame/ the correct sized frame of the keyboard in our rotated screen space.
           
        if notification.name == UIResponder.keyboardWillHideNotification {
            noteText.contentInset = .zero // don't push the text at all if the keyboard is hidden.
        } else {
            noteText.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0) // push the text so that its final line is where the keyboard top frame is. The reason why we did bottom like that is to compensate for the safe area existing with a home indicator on X, XR, XS etc. The safeAreaInsets.bottom for standard devices (like SE 2020) is 0, so it makes no difference here.
            noteText.scrollIndicatorInsets = noteText.contentInset // scrolling will always match the size of our text view.
               
            // Now we make our text view scroll down to show anything that the user has just tapped on:
            let selectedRange = noteText.selectedRange
            noteText.scrollRangeToVisible(selectedRange)
        }
    }
    
    func addNewNote() {
        if noteText.text != "" && (noteText.textColor != UIColor.brown || noteName.textColor != UIColor.brown) {
            let savedNote = Note(noteName: noteName.text, noteText: noteText.text)
            notes.append(savedNote)
            save()
            print("Note saved.")
            navigationController?.popToRootViewController(animated: true)
        } else {
            let ac = UIAlertController(title: "Note empty", message: "Write your note first!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func saveExistingNote() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "TableID") as? ViewController {
            if noteText.text != "" {
                assert(noteText.text != "")
                if let rowToDelete = rowNumber {
                    let savedNote = Note(noteName: noteName.text, noteText: noteText.text)
                    notes.remove(at: rowToDelete)
                    notes.insert(savedNote, at: rowToDelete)
                    save()
                    navigationController?.popToRootViewController(animated: true)
                    loadNotes()
                    vc.tableView.reloadData()
                }
            } else {
                let ac = UIAlertController(title: "Note empty", message: "Write your note first!", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
            }
        }
    }
    
}
