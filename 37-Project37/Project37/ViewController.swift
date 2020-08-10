//
//  ViewController.swift
//  Project37
//
//  Created by Mateusz Zacharski on 23/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import WatchConnectivity // framework responsilbe for connectivity between iOS apps and watchOS apps.
import AVFoundation // required to play sounds.
import UIKit

class ViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet var cardContainer: UIView!
    @IBOutlet var gradientView: GradientView!
    
    var allCards = [CardViewController]()
    
    var music: AVAudioPlayer!
    var bonk: AVAudioPlayer!
    
    var lastMessage: CFAbsoluteTime = 0
    
    var isWinModeEnabled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        createParticles()
        loadCards()
        playMusic()

        // Animate the background color so it changes repeatedly. We use '.allowUserInteraction' because the user can tap cards, '.autoreverse' because we want to make the view go back to its original color and '.repeat' because we want to make the animation loop back and forth forever:
        view.backgroundColor = UIColor.red
        
        UIView.animateKeyframes(withDuration: 20, delay: 0, options: [.allowUserInteraction, .autoreverse, .repeat], animations: {
            self.view.backgroundColor = UIColor.blue
        })
        
        // Setting up a session between our phone and our watch:
        if (WCSession.isSupported()) {
            let session = WCSession.default
            session.delegate = self // we can't call 'activate()' on a session without a delegate. We don't actually use any of the delegate methods, but we still need to assign a delegate.
            session.activate()
        }
    }
    
    // We put the instructions inside viewDidAppear() rather than viewDidLoad() because it presents an alert view controller:
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let instructions = "Please ensure your Apple Watch is configured correctly. On your iPhone, launch Apple's 'Watch' configuration app then choose General > Wake Screen. On that screen, please disable Wake Screen On Wrist Raise, then select Wake for 70 seconds. On your Apple Watch, please swipe up on your watch face and enable Silent Mode. Done!"
        let ac = UIAlertController(title: "Adjust your settings", message: instructions, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "I'm ready!", style: .default))
        present(ac, animated: true)
    }
    
    @objc func loadCards() {
        // As loadCards() is called every time after the user taps a card, we need to re-enable user interaction (as tapping the card disables it):
        view.isUserInteractionEnabled = true
        
        // remove any existing cards. This will allow us to call loadCards() repeatedly:
        for card in allCards {
            card.view.removeFromSuperview()
            card.removeFromParent()
        }
        
        allCards.removeAll(keepingCapacity: true)
        
        // create an array of card positions:
        let positions = [
        CGPoint(x: 75, y: 85),
        CGPoint(x: 185, y: 85),
        CGPoint(x: 295, y: 85),
        CGPoint(x: 405, y: 85),
        CGPoint(x: 75, y: 235),
        CGPoint(x: 185, y: 235),
        CGPoint(x: 295, y: 235),
        CGPoint(x: 405, y: 235)
        ]
        
        // load and unwrap our Zener card images:
        let circle = UIImage(named: "cardCircle")!
        let cross = UIImage(named: "cardCross")!
        let lines = UIImage(named: "cardLines")!
        let square = UIImage(named: "cardSquare")!
        let star = UIImage(named: "cardStar")!
        
        // create an array of the images, one for each card, then shuffle it:
        var images = [circle, circle, cross, cross, lines, lines, square, star]
        images.shuffle()
        
        for (index, position) in positions.enumerated() {
            // loop over each card position and create a new card view controller:
            let card = CardViewController()
            card.delegate = self
            
            // use view controller containment and also add the card's view to our cardContainer view:
            addChild(card)
            cardContainer.addSubview(card.view)
            card.didMove(toParent: self)
            
            // position the card appropriately, then give it an image from our array
            card.view.center = position
            card.front.image = images[index]
            
            // if we just gave the new card the star image, mark this as the correct answer:
            if card.front.image == star {
                card.isCorrect = true
            }
            
            // add the new card view controller to our array for easier tracking:
            allCards.append(card)
        }
    }
    
    func cardTapped(_ tapped: CardViewController) {
        guard view.isUserInteractionEnabled == true else { return }
        view.isUserInteractionEnabled = false // These 2 lines stop users tapping two cards at once.
        
        for card in allCards {
            if card == tapped {
                card.wasTapped() // flip the tapped card.
                card.perform(#selector(card.wasntTapped), with: nil, afterDelay: 1) // after 1 second, zoom it down.
            } else {
                card.wasntTapped() // zoom down the untapped cards immediately.
            }
        }
        
        perform(#selector(loadCards), with: nil, afterDelay: 2)
    }
    
    func createParticles() {
        let particleEmitter = CAEmitterLayer() // we use it to create particles (like in SpriteKit).
        
        particleEmitter.emitterPosition = CGPoint(x: view.frame.width / 2.0, y: -50) // position it at the horizontal center of our view and just off the top.
        particleEmitter.emitterShape = .line // shape it like a line so that particles are created across the width of the view
        particleEmitter.emitterSize = CGSize(width: view.frame.width, height: 1) // make it as wide as the view but only one point high.
        particleEmitter.renderMode = .additive // .additive rendering means that overlapping particles will get brighter.
        
        let cell = CAEmitterCell() // define a particle by using CAEmitterCell().
        cell.birthRate = 2
        cell.lifetime = 5.0
        cell.velocity = 100
        cell.velocityRange = 50
        cell.emissionLongitude = .pi
        cell.spinRange = 5
        cell.scale = 0.5
        cell.scaleRange = 0.25
        cell.color = UIColor(white: 1, alpha: 0.1).cgColor
        cell.alphaSpeed = -0.025
        cell.contents = UIImage(named: "particle")?.cgImage
        particleEmitter.emitterCells = [cell]
        
        gradientView.layer.addSublayer(particleEmitter) // we add the particle emitter as a sublayer of the 'gradientView' view, because it ensures the stars always go behind the cards.
    }
    
    func playMusic() {
        if let musicURL = Bundle.main.url(forResource: "PhantomFromSpace", withExtension: "mp3") {
            if let audioPlayer = try? AVAudioPlayer(contentsOf: musicURL) {
                music = audioPlayer
                music.numberOfLoops = -1 // loop the music indefinitely
                music.play()
            }
        }
    }
    
    func playBonkSound() {
        if let bonkURL = Bundle.main.url(forResource: "bonk", withExtension: "mp3") {
            if let audioPlayer = try? AVAudioPlayer(contentsOf: bonkURL) {
                bonk = audioPlayer
                bonk.play()
            }
        }
    }
    
    // Hard-pressing on a card (using a device with 3D Touch) will always change its image to "cardStar":
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: cardContainer) // the UIKit version of the location(in:) from SpriteKit.
        
        for card in allCards {
            if card.view.frame.contains(location) { // returns true if a point is inside the rectangle. Our point is the location of the current touch, and our rectangle is the frame of each card. So, this method returns true if the user's finger is over a particular card.
                if view.traitCollection.forceTouchCapability == .available { // we read the current trait collection for the view and check whether its forceTouchCapability (3D touch) is set to '.available'.
                    if touch.force == touch.maximumPossibleForce {
                        card.front.image = UIImage(named: "cardStar")
                        card.isCorrect = true
                    }
                }
                // moving our finger over a correct card will send a message to our Apple Watch:
                if card.isCorrect {
                    sendWatchMessage()
                }
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        // this method is needed to satisfy WCSessionDelegate protocol, we can leave it empty here.
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        // this method is needed to satisfy WCSessionDelegate protocol, we can leave it empty here.
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // this method is needed to satisfy WCSessionDelegate protocol, we can leave it empty here.
    }
    
    // Play a bonk sound when the watch goes to sleep to warn the user to wake it:
    func sessionWatchStateDidChange(_ session: WCSession) {
        playBonkSound()
    }
    
    // Pressing an invisible button on our watch sends a message to our phone, which executes a code to enable/disable the 'Always Win Mode':
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        isWinModeEnabled.toggle()
        
        if isWinModeEnabled == true {
            print("Win mode enabled!")
        } else {
            print("Win mode disabled!")
        }
    }
    
    func sendWatchMessage() {
        let currentTime = CFAbsoluteTimeGetCurrent()

        // if less than half a second has passed, bail out:
        if currentTime < lastMessage + 0.5 {
            return
        }
        
        // send a message to the watch if it's reachable:
        if (WCSession.default.isReachable) {
            // this is a meaningless message, but it's enough for our purposes:
            let message = ["Message": "Hello"]
            WCSession.default.sendMessage(message, replyHandler: nil)
        }
        
        // update our rate limiting property
        lastMessage = CFAbsoluteTimeGetCurrent()
    }
}

