//
//  GameScene.swift
//  Day 66. Milestone
//
//  Created by MacBook on 27/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var gameOver = false
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var time = 60 {
        didSet {
            gameTime?.text = "Time left: \(time)"
        }
    }
    
    var shotsLeft = 6 {
        didSet {
            shotsLeftLabel?.text = "Shots left: \(shotsLeft)"
        }
    }
    
    var charArray = ["bellatrixBad", "hermioneGood", "harryGood", "malfoyBad", "ronGood", "siriusGood", "voldemortBad", "umbridgeBad"]
    
    var isEmptyMagazine = false
    
    var shotsAfterEmpty = 0
    
    var sprite1: SKSpriteNode!
    var sprite2: SKSpriteNode!
    var sprite3: SKSpriteNode!
    var reloadButton: SKSpriteNode!
    var background: SKSpriteNode!

    
    var isVisible1 = false
    var isVisible2 = false
    var isVisible3 = false
        
    var gameScore: SKLabelNode!
    var gameTime: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var shotsLeftLabel: SKLabelNode!
    var gameTimer: Timer?
    
    
    override func didMove(to view: SKView) {
        run(SKAction.playSoundFileNamed("Harry Potter Theme Song.mp3", waitForCompletion: false))
        
        background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384) // these x and y are the middle of our screen
        background.blendMode = .replace
        background.zPosition = -2
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Harry P")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x:12, y: 12) // game score is placed in the bottom left corner of our screen.
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 55
        gameScore.zPosition = 2
        addChild(gameScore)
        
        gameTime = SKLabelNode(fontNamed: "Harry P")
        gameTime.text = "Time left: 60"
        gameTime.fontColor = .black
        gameTime.position = CGPoint(x:512, y: 700)
        gameTime.horizontalAlignmentMode = .center
        gameTime.fontSize = 55
        gameTime.zPosition = 2
        addChild(gameTime)
        
        shotsLeftLabel = SKLabelNode(fontNamed: "Harry P")
        shotsLeftLabel.text = "Shots left: 6"
        shotsLeftLabel.position = CGPoint(x:512, y: 12) 
        shotsLeftLabel.horizontalAlignmentMode = .center
        shotsLeftLabel.fontSize = 55
        shotsLeftLabel.zPosition = 2
        addChild(shotsLeftLabel)
        
        reloadButton = SKSpriteNode(imageNamed: "reload")
        reloadButton.position = CGPoint(x:970, y: 60) // game score is placed in the bottom left corner of our screen.
        reloadButton.setScale(0.06)
        reloadButton.zPosition = 2
        addChild(reloadButton)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        
        runTarget1()
        runTarget2()
        runTarget3()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        let wiggle = SKAction.scale(to: 1.15, duration: 0.1)
        let wiggle2 = SKAction.scale(to: 1.0, duration: 0.1)
        let wait = SKAction.wait(forDuration: 0.5)
        let fade = SKAction.fadeAlpha(to: 0, duration: 0.3)
        let remove = SKAction.removeFromParent()
       
        let notVisible1 = SKAction.run { [weak self] in
            self?.isVisible1 = false
        }
        let notVisible2 = SKAction.run { [weak self] in
            self?.isVisible2 = false
        }
        let notVisible3 = SKAction.run { [weak self] in
            self?.isVisible3 = false
        }
        
        let hitSequence1 = SKAction.sequence([wiggle, wiggle2, wait, fade, remove, notVisible1])
        let hitSequence2 = SKAction.sequence([wiggle, wiggle2, wait, fade, remove, notVisible2])
        let hitSequence3 = SKAction.sequence([wiggle, wiggle2, wait, fade, remove, notVisible3])
        
        if gameOver == false {
            for node in tappedNodes {
                if (node == sprite1 || node == sprite2 || node == sprite3) && shotsLeft > 0 {
                    run(SKAction.playSoundFileNamed("pistolshot.mp3", waitForCompletion: false))
                    shotsLeft -= 1
                    if node.name == "bellatrixBad" {
                        score += 5
                    }
                    if node.name == "malfoyBad" {
                        score += 10
                    }
                    if node.name == "voldemortBad" {
                        score += 20
                    }
                    if node.name == "umbridgeBad" {
                        score += 5
                    }
                    if node.name == "harryGood" {
                        score -= 10
                    }
                    if node.name == "ronGood" {
                        score -= 10
                    }
                    if node.name == "hermioneGood" {
                        score -= 10
                    }
                    if node.name == "siriusGood" {
                        score -= 10
                    }
                
                    node.removeAllActions()
                    
                    if node == sprite1 {
                        node.run(hitSequence1)
                    }
                    if node == sprite2 {
                        node.run(hitSequence2)
                    }
                    if node == sprite3 {
                        node.run(hitSequence3)
                    }
                }
               
                
                if node == background && nodes(at: location).count == 1 {
                    score -= 1
                    shotsLeft -= 1
                }
                
                if shotsLeft >= 0 && nodes(at: location).count == 1 {
                    run(SKAction.playSoundFileNamed("pistolshot.mp3", waitForCompletion: false))
                }
                
                if node == reloadButton {
                    shotsLeft = 6
                    reloadButton.run(SKAction.rotate(byAngle: .pi * 2, duration: 0.5))
                    run(SKAction.playSoundFileNamed("reload.mp3", waitForCompletion: false))
                    isEmptyMagazine = false
                    shotsAfterEmpty = 0
                }
                
                if shotsLeft < 0 && node == background {
                    shotsLeft = 0
                    score += 1
                }
                
                if shotsLeft <= 0 {
                    shotsAfterEmpty += 1
                }
                
                if shotsAfterEmpty > 1 {
                    run(SKAction.playSoundFileNamed("quack.mp3", waitForCompletion: false))

                }
            }
            reloadPulse()
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {

    }

    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func runTarget1() {
        if isVisible1 == false && gameOver == false {
          guard let target = charArray.randomElement() else { return }
            
            sprite1 = SKSpriteNode(imageNamed: target)
            sprite1.position = CGPoint(x: 1100, y: 600)
            sprite1.size = CGSize(width: 120, height: 200)
            addChild(sprite1)
            
            if target == "bellatrixBad" {
                sprite1.name = "bellatrixBad"
            }
            if target == "malfoyBad" {
                sprite1.name = "malfoyBad"
            }
            if target == "voldemortBad" {
                sprite1.name = "voldemortBad"
            }
            if target == "umbridgeBad" {
                sprite1.name = "umbridgeBad"
            }
            if target == "harryGood" {
                sprite1.name = "harryGood"
            }
            if target == "ronGood" {
                sprite1.name = "ronGood"
            }
            if target == "hermioneGood" {
                sprite1.name = "hermioneGood"
            }
            if target == "siriusGood" {
                sprite1.name = "siriusGood"
            }
            
            isVisible1 = true
            
            let run = SKAction.moveBy(x: -1200, y: 0, duration: Double.random(in: 1.4...2.5))
            let remove = SKAction.removeFromParent()
            let notVisible = SKAction.run { [weak self] in
                self?.isVisible1 = false
            }
            let sequence = SKAction.sequence([run, remove, notVisible])
            sprite1.run(sequence)
        }
        
        let delay = Double.random(in: 0.0...1.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
        self?.runTarget1()
        }
    }
    
    func runTarget2() {
        if isVisible2 == false && gameOver == false {
          guard let target = charArray.randomElement() else { return }
            
            sprite2 = SKSpriteNode(imageNamed: target)
            sprite2.position = CGPoint(x: -100, y: 384)
            sprite2.size = CGSize(width: 120, height: 200)
            addChild(sprite2)
            
            if target == "bellatrixBad" {
                sprite2.name = "bellatrixBad"
            }
            if target == "malfoyBad" {
                sprite2.name = "malfoyBad"
            }
            if target == "voldemortBad" {
                sprite2.name = "voldemortBad"
            }
            if target == "umbridgeBad" {
                sprite2.name = "umbridgeBad"
            }
            if target == "harryGood" {
                sprite2.name = "harryGood"
            }
            if target == "ronGood" {
                sprite2.name = "ronGood"
            }
            if target == "hermioneGood" {
                sprite2.name = "hermioneGood"
            }
            if target == "siriusGood" {
                sprite2.name = "siriusGood"
            }
            
            isVisible2 = true
            
            let run = SKAction.moveBy(x: 1200, y: 0, duration: Double.random(in: 1.4...2.5))
            let remove = SKAction.removeFromParent()
            let notVisible = SKAction.run { [weak self] in
                self?.isVisible2 = false
            }
            let sequence = SKAction.sequence([run, remove, notVisible])
            sprite2.run(sequence)
        }
        
        let delay = Double.random(in: 0.0...1.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
        self?.runTarget2()
        }
    }
    
    func runTarget3() {
        if isVisible3 == false && gameOver == false {
          guard let target = charArray.randomElement() else { return }
            
            sprite3 = SKSpriteNode(imageNamed: target)
            sprite3.position = CGPoint(x: 1100, y: 150)
            sprite3.size = CGSize(width: 120, height: 200)
            addChild(sprite3)
            
            if target == "bellatrixBad" {
                sprite3.name = "bellatrixBad"
            }
            if target == "malfoyBad" {
                sprite3.name = "malfoyBad"
            }
            if target == "voldemortBad" {
                sprite3.name = "voldemortBad"
            }
            if target == "umbridgeBad" {
                sprite3.name = "umbridgeBad"
            }
            if target == "harryGood" {
                sprite3.name = "harryGood"
            }
            if target == "ronGood" {
                sprite3.name = "ronGood"
            }
            if target == "hermioneGood" {
                sprite3.name = "hermioneGood"
            }
            if target == "siriusGood" {
                sprite3.name = "siriusGood"
            }
            
            isVisible3 = true
            
            let run = SKAction.moveBy(x: -1200, y: 0, duration: Double.random(in: 1.4...2.5))
            let remove = SKAction.removeFromParent()
            let notVisible = SKAction.run { [weak self] in
                self?.isVisible3 = false
            }
            let sequence = SKAction.sequence([run, remove, notVisible])
            sprite3.run(sequence)
        }
        
        let delay = Double.random(in: 0.0...1.1)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
        self?.runTarget3()
        }
    }
    
    @objc func countDown() {
        time -= 1
        if time == 0 {
            gameTimer?.invalidate()
            sprite1.removeFromParent()
            sprite2.removeFromParent()
            sprite3.removeFromParent()
            
            gameOverLabel = SKLabelNode(fontNamed: "Harry P")
            gameOverLabel.text = "GAME OVER"
            gameOverLabel.fontColor = .black
            gameOverLabel.position = CGPoint(x:512, y: 384)
            gameOverLabel.horizontalAlignmentMode = .center
            gameOverLabel.fontSize = 60
            addChild(gameOverLabel)
    
            gameOver = true
        }
    }
    
    func reloadPulse() {
        let pulseUp = SKAction.scale(to: 0.08, duration: 0.1)
        let pulseDown = SKAction.scale(to: 0.06, duration: 0.3)
        let sequence = SKAction.sequence([pulseUp, pulseDown])
        
        if shotsLeft == 0 {
            reloadButton.run(sequence)
        }
    }
}
            
    
            

    


