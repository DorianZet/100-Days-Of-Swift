//
//  SubmitViewController.swift
//  Project33
//
//  Created by MacBook on 08/07/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import CloudKit
import UIKit

class SubmitViewController: UIViewController {
    var genre: String!
    var comments: String!
    
    var stackView: UIStackView!
    var status: UILabel!
    var spinner: UIActivityIndicatorView!
    
    var newWhistle = Whistle()
    var whistles = [Whistle]()
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.gray
        
        stackView = UIStackView()
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = UIStackView.Distribution.fillEqually
        stackView.alignment = .center
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        status = UILabel()
        status.translatesAutoresizingMaskIntoConstraints = false
        status.text = "Submitting..."
        status.textColor = UIColor.white
        status.font = UIFont.preferredFont(forTextStyle: .title1)
        status.numberOfLines = 0
        status.textAlignment = .center
        
        spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        spinner.startAnimating()
        
        stackView.addArrangedSubview(status)
        stackView.addArrangedSubview(spinner)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "You're all set!"
        navigationItem.hidesBackButton = true
        
        loadWhistlesLocal()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        doSubmission()
    }
    
    func doSubmission() {
        let whistleRecord = CKRecord(recordType: "Whistles")
        // Swift doesn't automatically convert strings to CKRecordValue, so we use 'as' typecast here:
        whistleRecord["genre"] = genre as CKRecordValue
        whistleRecord["comments"] = comments as CKRecordValue
        
        let audioURL = RecordWhistleViewController.getWhistleURL()
        let whistleAsset = CKAsset(fileURL: audioURL)
        whistleRecord["audio"] = whistleAsset
        
        CKContainer.default().publicCloudDatabase.save(whistleRecord) { [unowned self] record, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.status.text = "Error: \(error.localizedDescription)\nMake sure you have turned iCloud services on in your iOS Settings."
                    self.spinner.stopAnimating()
                } else {
                    self.view.backgroundColor = UIColor(red: 0, green: 0.6, blue: 0, alpha: 1)
                    self.status.text = "Done"
                    self.spinner.stopAnimating()
                   
                    // Making a new whistle, appending it to the whistles array and saving them locally:
                    self.newWhistle = Whistle(recordID: whistleRecord.recordID, genre: self.genre, comments: self.comments, audio: audioURL)
                    self.whistles.append(self.newWhistle)
                    self.saveWhistlesToLocal()
                    // done
                    
                    ViewController.isDirty = true
                }
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.doneTapped))
            }
        }
    }
    
    @objc func doneTapped() {
        navigationController?.popToRootViewController(animated: true) // calling this method pops off all the view controllers on a navigation controller's stack, returning us to the original view controller - in our case, that's the "What's that Whistle?" screen with the '+' button.
    }
    
    func loadWhistlesLocal() {
        // Reading the saved data:
        let defaults = UserDefaults.standard
        if let savedWhistles = defaults.object(forKey: "whistles") as? Data {
            if let decodedWhistles = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedWhistles) as? [Whistle] {
                   whistles = decodedWhistles
            }
        }
    }
    
    func saveWhistlesToLocal() {
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: whistles, requiringSecureCoding: false) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "whistles")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
