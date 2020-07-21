//
//  GameViewController.swift
//  Project29
//
//  Created by MacBook on 26/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    var currentGame: GameScene?
    
    var player1Score = 0 {
        didSet {
            player1ScoreLabel.text = "PLAYER 1 SCORE: \(player1Score)"
        }
    }
    var player2Score = 0 {
        didSet {
            player2ScoreLabel.text = "PLAYER 2 SCORE: \(player2Score)"
        }
    }
    
    @IBOutlet var angleSlider: UISlider!
    @IBOutlet var angleLabel: UILabel!
    @IBOutlet var velocitySlider: UISlider!
    @IBOutlet var velocityLabel: UILabel!
    @IBOutlet var launchButton: UIButton!
    @IBOutlet var playerNumber: UILabel!
    @IBOutlet var player1ScoreLabel: UILabel!
    @IBOutlet var player2ScoreLabel: UILabel!
    @IBOutlet var gameOverLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
                
                currentGame = scene as? GameScene // setting the property to the initial game scene so that we can start using it.
                currentGame?.viewController = self // making sure so that the scene knows about the view controller.
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        // initializing sliders:
        angleChanged(self)
        velocityChanged(self)
        
        player1ScoreLabel.text = "PLAYER 1 SCORE: \(player1Score)"
        player2ScoreLabel.text = "PLAYER 2 SCORE: \(player2Score)"
        
        gameOverLabel.layer.cornerRadius = 10
        gameOverLabel.clipsToBounds = true
        gameOverLabel.textAlignment = .center
        gameOverLabel.isHidden = true
        
        angleLabel.textColor = .white
        velocityLabel.textColor = .white
        playerNumber.textColor = .white
        player1ScoreLabel.textColor = .white
        player2ScoreLabel.textColor = .white
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBAction func angleChanged(_ sender: Any) {
        angleLabel.text = "Angle: \(Int(angleSlider.value))°"
    }
    
    @IBAction func velocityChanged(_ sender: Any) {
        velocityLabel.text = "Velocity: \(Int(velocitySlider.value))"
    }
    
    @IBAction func launch(_ sender: Any) {
        angleSlider.isHidden = true
        angleLabel.isHidden = true
        
        velocitySlider.isHidden = true
        velocityLabel.isHidden = true
        
        launchButton.isHidden = true
        
        player1ScoreLabel.isHidden = true
        player2ScoreLabel.isHidden = true
        
        currentGame?.launch(angle: Int(angleSlider.value), velocity: Int(velocitySlider.value))
    }
    
    func activatePlayer(number: Int) {
        if number == 1 {
            playerNumber.text = "<<< PLAYER ONE"
        } else {
            playerNumber.text = "PLAYER TWO >>>"
        }
        
        angleSlider.isHidden = false
        angleLabel.isHidden = false
        
        velocitySlider.isHidden = false
        velocityLabel.isHidden = false
        
        launchButton.isHidden = false
        
        player1ScoreLabel.isHidden = false
        player2ScoreLabel.isHidden = false
    }
    
}
