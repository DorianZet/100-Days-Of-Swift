//
//  ViewController.swift
//  Project25
//
//  Created by MacBook on 15/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//
import MultipeerConnectivity // import this framework to make multipeer connectivity work.
import UIKit

class ViewController: UICollectionViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MCSessionDelegate, MCBrowserViewControllerDelegate {
    var images = [UIImage]()
    
    var peerID = MCPeerID(displayName: UIDevice.current.name) // "get the name of the current device"
    var mcSession: MCSession?
    var mcAdvertiserAssistant: MCAdvertiserAssistant?
    
    var isConnected = false
    var imageReceived = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Selfie Share"
        let connectedPeersButton = UIBarButtonItem(title: "Users", style: .plain, target: self, action: #selector(showConnectedPeers))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showConnectionPrompt))
        navigationItem.leftBarButtonItems = [addButton, connectedPeersButton]
        
        let importPictureButton = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(importPicture))
        let sendTextButton = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(sendText))
        
        navigationItem.rightBarButtonItems = [importPictureButton, sendTextButton]
        
        mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        mcSession?.delegate = self // "tell us when something has happened". We need to conform to MCSessionDelegate to make this work.
    }
    
    @objc func showConnectedPeers() {
        guard let mcSession = mcSession else { return }
        
        var usersList = ""
        for eachPeer in mcSession.connectedPeers {
            usersList += eachPeer.displayName + "\n"
        }
        if isConnected == true {
            let ac = UIAlertController(title: "Users in session", message: usersList, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            DispatchQueue.main.async { [weak self] in
                self?.present(ac, animated: true)
            }
        } else {
            let ac = UIAlertController(title: "Users in session", message: "No users available", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel))
            DispatchQueue.main.async { [weak self] in
                self?.present(ac, animated: true)
            }
        }
    }
    
    @objc func sendText() {
        let ac = UIAlertController(title: "Send message", message: nil, preferredStyle: .alert)
               ac.addTextField()
               
        let sendAction = UIAlertAction(title: "Send", style: .default) {
            [weak self, weak ac] _ in
                   
            guard let message = ac?.textFields?[0].text else { return }
            
            // Sending the image to the connected peers:
            guard let mcSession = self?.mcSession else { return } // if we haven't got a session - bail out at this line.
                   
            if mcSession.connectedPeers.count > 0 {
                let textData = Data(message.utf8)
                do {
                    try mcSession.send(textData, toPeers: mcSession.connectedPeers, with: .reliable)
                    print("Message sent.")
                } catch {
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(ac, animated: true)
                }
            }
        }
        ac.addAction(sendAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func sendReply(action: UIAlertAction) {
        let ac = UIAlertController(title: "Send message", message: nil, preferredStyle: .alert)
               ac.addTextField()
               
        let sendAction = UIAlertAction(title: "Send", style: .default) {
            [weak self, weak ac] _ in
                   
            guard let message = ac?.textFields?[0].text else { return }
            // Sending the image to the connected peers:
            guard let mcSession = self?.mcSession else { return } // if we haven't got a session - bail out at this line.
                   
            if mcSession.connectedPeers.count > 0 {
                let textData = Data(message.utf8)
                do {
                    try mcSession.send(textData, toPeers: mcSession.connectedPeers, with: .reliable)
                    print("Message sent.")
                } catch {
                let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(ac, animated: true)
                }
            }
        }
        ac.addAction(sendAction)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    
    func startHosting(action: UIAlertAction) {
        guard let mcSession = mcSession else { return } // making sure that the mcSession exists and is not optional.
        mcAdvertiserAssistant = MCAdvertiserAssistant(serviceType: "hws-project25", discoveryInfo: nil, session: mcSession)
        mcAdvertiserAssistant?.start() // start looking for connections for us to join .
    }
    
    func joinSession(action: UIAlertAction) {
        guard let mcSession = mcSession else { return } // same thing as in 'startHosting()' method.
        let mcBrowser = MCBrowserViewController(serviceType: "hws-project25", session: mcSession)
        mcBrowser.delegate = self // We need to conform to MCBrowserViewControllerDelegate to make this work.
        present(mcBrowser, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageView", for: indexPath)
        
        // All UIView subclasses have a method called viewWithTag(), which searches for any views inside itself (or indeed itself) with that tag number. We can find our image view just by using this method, although it's worth to use 'if let' and typecast 'as?' to be sure:
        if let imageView = cell.viewWithTag(1000) as? UIImageView {
            imageView.image = images[indexPath.item]
        }
        return cell
    }
    
    @objc func importPicture() {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return } // If we can't find an image in the 'info' dictionary - bail out immediately.
        dismiss(animated: true)
        
        images.insert(image, at: 0) // Inserts a picture on the top of the collection rather than at the end of it (we would use 'append' to do that).
        collectionView.reloadData()
        
        // Sending the image to the connected peers:
        guard let mcSession = mcSession else { return } // if we haven't got a session - bail out at this line.
        
        if mcSession.connectedPeers.count > 0 {
            if let imageData = image.pngData() {
                do {
                    try mcSession.send(imageData, toPeers: mcSession.connectedPeers, with: .reliable)
                } catch {
                    let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    present(ac, animated: true)
                }
            }
        }
    }
    
    @objc func showConnectionPrompt() {
        let ac = UIAlertController(title: "Connect to others", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Host a session", style: .default, handler: startHosting))
        ac.addAction(UIAlertAction(title: "Join a session", style: .default, handler: joinSession))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // although we have to CREATE this function to make the class delegate errors go away, we don't need to do anything here, we just ignore it.
    }

    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        // although we have to CREATE this function to make the class delegate errors go away, we don't need to do anything here, we just ignore it.
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        // although we have to CREATE this function to make the class delegate errors go away, we don't need to do anything here, we just ignore it.
    }
    
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        dismiss(animated: true)
    }
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        switch state {
        case .connected:
            print("Connected: \(peerID.displayName)") // print the name of the person that you connected to.
            isConnected = true
            
        case .connecting:
            print("Connecting: \(peerID.displayName)")
            
        case .notConnected:
            print("Not connected: \(peerID.displayName)")
            // Showing the alert controller if any of the users has disconnected:
            if isConnected == true {
                DispatchQueue.main.async { [weak self] in // WE !!!HAVE TO!!! PUSH THE UI WORK TO THE MAIN THREAD - JUST TO BE SAFE.
                let ac = UIAlertController(title: "User disconnected", message: "\(peerID.displayName) has disconnected.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(ac, animated: true)
                    self?.isConnected = false
                }
                let ac = UIAlertController(title: "User disconnected", message: "\(peerID.displayName) has disconnected.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                present(ac, animated: true)
                isConnected = false
            }
            
        @unknown default: // Used for unknown future cases that are not here right now, but Apple might introduce them some time later.
            print("Unknown state received: \(peerID.displayName)")
        }
    }
    
    // Receiving the image in a form of data:
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async { [weak self] in // WE !!!HAVE TO!!! PUSH THE UI WORK TO THE MAIN THREAD - JUST TO BE SAFE.
            self?.imageReceived = false
            if let image = UIImage(data: data) {
                self?.images.insert(image, at: 0)
                self?.collectionView.reloadData()
                self?.imageReceived = true
            }
            
            if self?.imageReceived == false { // the alert controller will appear only if the data received doesn't contain any image.
                let text = String(decoding: data, as: UTF8.self)
                let ac = UIAlertController(title: peerID.displayName, message: text, preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "Reply", style: .default, handler: self?.sendReply))
                ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                self?.present(ac, animated: true)
            }
        }
    }
}

