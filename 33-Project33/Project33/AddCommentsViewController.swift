//
//  AddCommentsViewController.swift
//  Project33
//
//  Created by MacBook on 08/07/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class AddCommentsViewController: UIViewController, UITextViewDelegate {
    var genre: String!
    
    var comments: UITextView!
    let placeholder = "If you have any additional comments that might help identify your tune, enter them here."
   
    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        comments = UITextView()
        comments.translatesAutoresizingMaskIntoConstraints = false
        comments.delegate = self
        comments.font = UIFont.preferredFont(forTextStyle: .body)
        comments.textColor = .lightGray
        view.addSubview(comments)
        
        comments.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        comments.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        comments.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        comments.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Comments"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Submit", style: .plain, target: self, action: #selector(submitTapped))
        comments.text = placeholder
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func submitTapped() {
        let vc = SubmitViewController()
        vc.genre = genre
        
        if comments.text == placeholder {
            vc.comments = ""
        } else {
            vc.comments = comments.text
        }
        
        // If there are more than 1 line breaks, show alert:
        let lines = comments.text.components(separatedBy: "\n")
        if lines.count > 2 {
            let ac = UIAlertController(title: "Too many lines!", message: "The maximum number of lines is 2.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            navigationController?.pushViewController(vc, animated: true)
        }

    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placeholder {
            textView.text = ""
            textView.textColor = .black
        }
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return } // Now we have NSValue (keyboard value) that tells us the size of the keyboard.
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue // Now we read the size of the keyboard.
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window) // Now we get back the converted frame/ the correct sized frame of the keyboard in our rotated screen space.
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            comments.contentInset = .zero // don't push the text at all if the keyboard is hidden.
        } else {
            comments.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0) // push the text so that its final line is where the keyboard top frame is. The reason why we did bottom like that is to compensate for the safe area existing with a home indicator on X, XR, XS etc. The safeAreaInsets.bottom for standard devices (like SE 2020) is 0, so it makes no difference here.
            comments.scrollIndicatorInsets = comments.contentInset // scrolling will always match the size of our text view.
            
            // Now we make our text view scroll down to show anything that the user has just tapped on:
            let selectedRange = comments.selectedRange
            comments.scrollRangeToVisible(selectedRange)
        }
    }
}
