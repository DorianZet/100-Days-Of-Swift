//
//  GameScene.swift
//  Project17
//
//  Created by MacBook on 24/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var hintLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var newGameLabel: SKSpriteNode!
    var sprite: SKSpriteNode!
    
    
    var possibleEnemies = ["ball", "hammer", "tv"]
    var gameTimer: Timer?
    var isGameOver = false
    var isTouched = false
    var enemiesCreated = 0
    var spawnInterval = 0.35
    var buttonActivated = false
    var wasContact = false
    var debrisStarted = false
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        starfield = SKEmitterNode(fileNamed: "starfield")! // if starfield file is missing from the bundle for some reason, the game is hideously corrupt, and therefore shouldn't be able to run - hence the force unwrapping.
        starfield.position = CGPoint(x: 1024, y: 384) // The starts start flying from the right edge, right in the middle of y.
        starfield.advanceSimulationTime(10) // Create 10sec and move 10sec worth of particles NOW.
        addChild(starfield)
        starfield.zPosition = -1
        
        createPlayer()

        scoreLabel = SKLabelNode(fontNamed: "Pixel Emulator")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        scoreLabel.zPosition = 2
        
        score = 0
        
        physicsWorld.gravity = .zero // We turn off the gravity.
        physicsWorld.contactDelegate = self // Sets our current game scene to be the contact delegate of the physics world. In other words: "Please tell me when contacts in the game scene happen".
        
        // Setting the debris to fly after 2.5sec in the game scene.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) { [weak self] in
            self?.gameTimer = Timer.scheduledTimer(timeInterval: self!.spawnInterval, target: self!, selector: #selector(self?.createEnemy), userInfo: nil, repeats: true) // the function 'createEnemy()' will be called every 0.35sec.
            
            self?.debrisStarted = true
            
            // a hint appears when the debris start to fly:
            self?.hintLabel = SKLabelNode(fontNamed: "Pixel Emulator")
            self?.hintLabel.text = "GRAB THE SHIP AND AVOID THE DEBRIS!"
            self?.hintLabel.position = CGPoint(x: 512, y: 140)
            self?.hintLabel.horizontalAlignmentMode = .center
            self?.hintLabel.fontSize = 30
            self!.addChild(self!.hintLabel)
            self?.hintLabel.zPosition = 2
        }
        
        // the hint fades away after 2.5sec:
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.2) { [weak self] in
            self?.hintLabel.run(SKAction.fadeAlpha(to: 0, duration: 2))
        }
    }
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
            
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1200, y: Int.random(in: 50...736)) // The debris will be created on a random y, safely off the right edge of the screen.
        sprite.setScale(0.5)
        addChild(sprite)
        enemiesCreated += 1
            
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -430, dy: 0) // Speed of the debris - move very fast to the left, at a constant rate.
        sprite.physicsBody?.angularVelocity = 5 // Give it a constant spin.
        sprite.physicsBody?.linearDamping = 0 // linearDamping controls how fast things slow down over time. If we gave the debris a push of velocity -500, 'linearDamping = 0' means that it will never slow down.
        sprite.physicsBody?.angularDamping = 0 // Analogically to linearDamping, angularDamping works in the same way.
        sprite.name = "sprite"
            // Upping the difficulty every 20 enemies created:
        if enemiesCreated > 0 && enemiesCreated % 20 == 0 {
            gameTimer?.invalidate()
            gameTimer = Timer.scheduledTimer(timeInterval: spawnInterval - 0.1, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
            print("invalidating old timer, difficulty goes up")
        }
    }
        
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        if !isGameOver && debrisStarted == true {
            score += 1
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)

        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        if isTouched == true && debrisStarted == true {
            player.position = location
        }
    }
    
    // Checking if ship was touched first (the game won't initialise moving code until we touch the ship):
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            if node == player {
                isTouched = true
            }
            
            if node == newGameLabel {
                buttonActivated = true
                node.run(SKAction.scale(by: 0.8, duration: 0.1))
            }
        }
    }
    
    // Checks if we stopped touching the screen. The 'isTouched' property is important, as we use it between touchesBegan, touchesMoved and touchesEnded methods.
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            if node == player {
                isTouched = false
                print("lifted finger from player")
            }
        }
        
        
        // Lifting up the finger when the newGameLabel is pressed causes the view to fade to black, then fade back to 'alpha = 1' and reload the scene, causing the new game to start.
        if buttonActivated == true {
            newGameLabel?.run(SKAction.scale(to: 0.5, duration: 0.1)) // scaling the button back to the original size (we set newGameLabel's scale = 0.5 at the beginning).
            UIView.animate(withDuration: 1, delay: 0, options: [], animations: {
                    self.view?.alpha = 0
            })
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                UIView.animate(withDuration: 1, delay: 0.5, options: [], animations: {
                        self?.view?.alpha = 1
                })
                self?.reloadScene()
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // We put everything in 'if wasContact == false' and then mark 'wasContact = true' at the end of the call, so that we don't have any repetitions of the code (pixel perfect physics contact may create multiple contacts, which causes the code to be called more than once.
        if wasContact == false {
            player.removeFromParent()
            let explosion = SKEmitterNode(fileNamed: "explosion")!
            explosion.position = player.position
            addChild(explosion)
            
            isGameOver = true
            gameTimer?.invalidate() // stop creating debris when the game is over.
            
            gameOverLabel = SKLabelNode(fontNamed: "Pixel Emulator")
            gameOverLabel.text = "GAME OVER"
            gameOverLabel.position = CGPoint(x: 512, y: 384)
            gameOverLabel.horizontalAlignmentMode = .center
            gameOverLabel.fontSize = 48
            addChild(gameOverLabel)
            gameOverLabel.zPosition = 2
            
            newGameLabel = SKSpriteNode(imageNamed: "newGameBtn")
            newGameLabel.position = CGPoint(x: 512, y: 340)
            newGameLabel.setScale(0.5)
            addChild(newGameLabel)
            newGameLabel.zPosition = 2
            wasContact = true
        }
            
    }
    
    
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size) // this will create the physics body by drawing around the player's texture at their current size.
        player.physicsBody?.contactTestBitMask = 1 // This number matches the category bit mask we will set for space debris later on, and it means that we'll be notified when the player collides with debris.
        player.setScale(0.9)
        player.name = "player"
        addChild(player)
    }
    
    func reloadScene() {
        if let view = self.view {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
}

