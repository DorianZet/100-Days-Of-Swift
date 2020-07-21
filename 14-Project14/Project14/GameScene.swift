//
//  GameScene.swift
//  Project14
//
//  Created by MacBook on 17/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {
    var slots = [WhackSlot]()
    var gameScore: SKLabelNode!
    var finalScore: SKLabelNode!
    
    var popupTime = 0.85
    var numRounds = 0
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    var backgroundMusic: AVAudioPlayer?
    
    override func didMove(to view: SKView) {
        let path = Bundle.main.path(forResource: "myszojeleń.mp3", ofType: nil)!
        let url = URL(fileURLWithPath: path)

        do {
            backgroundMusic = try AVAudioPlayer(contentsOf: url)
            backgroundMusic?.play()
        } catch {
           print("error: couldn't load myszojeleń.mp3 file")
        }
        
        let background = SKSpriteNode(imageNamed: "whackBackground")
        background.position = CGPoint(x: 512, y: 384) // background is set in the middle of our view.
        background.blendMode = .replace // we draw the background on top of whatever was there beforehand, without taking into account alpha.
        background.zPosition = -1
        addChild(background)
        
        gameScore = SKLabelNode(fontNamed: "Chalkduster")
        gameScore.text = "Score: 0"
        gameScore.position = CGPoint(x:8, y: 8) // game score is placed in the bottom left corner of our screen.
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        // We place hole nodes on the scene using loops:
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 410)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 320)) }
        for i in 0..<5 { createSlot(at: CGPoint(x: 100 + (i * 170), y: 230)) }
        for i in 0..<4 { createSlot(at: CGPoint(x: 180 + (i * 170), y: 140)) }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.createEnemy()
        } // The game will wait exactly ONE SECOND before it starts to create the first enemy.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let tappedNodes = nodes(at: location)
        
        for node in tappedNodes {
            guard let whackSlot = node.parent?.parent as? WhackSlot else { continue } // we are trying to read the grandparent of the thing that was tapped. If we can read that - we will try to typecast it as a WhackSlot and if that works - we will do our check in the code below. But if it fails, then we will just ignore that one and go to the next node at the tapped location instead. 'node' here will be the penguin, because it's grandparent ('node.parent?.parent') is WhackSlot itself.
            
            if !whackSlot.isVisible { continue } // if the penguin is hidden, bail out and go to the next penguin. IN OTHER WORDS: DO NOTHING, IF THEY AREN'T VISIBLE
            if whackSlot.isHit { continue } // if the penguin has already been hit, don't let it hit again and again - hit it just once, and continue. IN OTHER WORDS: DO NOTHING IF THEY HAVE BEEN HIT
            whackSlot.hit() // if we are still here, mark this thing as being hit
           
            if let smokeParticles = SKEmitterNode(fileNamed: "SmokeParticle") {
                 smokeParticles.position = touch.location(in: self)
                 addChild(smokeParticles)
            }
           
            if node.name == "charFriend" {
                // they shouldn't have whacked this penguin
                run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false)) // we don't want to wait for the completion of the animation, play the sound immediately
                
                score -= 5
            } else if node.name == "charEnemy" {
                // they should have whacked this penguin
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
                
                score += 1
                whackSlot.charNode.xScale = 0.85
                whackSlot.charNode.yScale = 0.85
            }
        }
    }
    
    func createSlot (at position: CGPoint) {
        let slot = WhackSlot()
        slot.configure(at: position)
        addChild(slot)
        slots.append(slot)
    }
    
    func createEnemy() {
        numRounds += 1
        if numRounds >= 40 {
            for slot in slots {
                slot.hide()
            }
            
            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.position = CGPoint(x: 512, y: 384)
            gameOver.zPosition = 1
            addChild(gameOver)
            
            finalScore = SKLabelNode(fontNamed: "Chalkduster")
            finalScore.text = "Final score: \(score)"
            finalScore.position = CGPoint(x:512, y: 295) // game score is placed in the bottom left corner of our screen.
            finalScore.horizontalAlignmentMode = .center
            finalScore.fontSize = 60
            finalScore.zPosition = 1
            addChild(finalScore)
            gameScore.removeFromParent() // final score is shown in the center, so we don't need the score label from the corner, hence we remove it.
            
            backgroundMusic?.stop()
            run(SKAction.playSoundFileNamed("gameover.caf", waitForCompletion: false))
            return // this 'return' is important, because without that, it would call creatEnemy() again after the delay has been reached.
        }
        popupTime *= 0.991 // This line makes penguins appear faster each time the method is called. In other words, each time the penguin is called, the delay is shortened by 0,09%. This makes the game harder/faster the longer we play.
        
        slots.shuffle()
        slots[0].show(hideTime: popupTime)

        if Int.random(in: 0...12) > 4 { slots[1].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 8 { slots[2].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 10 { slots[3].show(hideTime: popupTime) }
        if Int.random(in: 0...12) > 11 { slots[4].show(hideTime: popupTime) }
        
        let minDelay = popupTime / 2.0
        let maxDelay = popupTime * 2
        let delay = Double.random(in: minDelay...maxDelay)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
            self?.createEnemy()
        } // This means - createEnemy() calls itself. Because createEnemy() calls itself, all we have to do is to call it once inside didMove(to view: SKView) method after a brief delay. Then the creating enemy will call itself again and again - first time with 1 second delay, and after that - 'delay' delay.
    }
}
