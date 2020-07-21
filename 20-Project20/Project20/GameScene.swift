//
//  GameScene.swift
//  Project20
//
//  Created by MacBook on 02/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    var gameTimer: Timer?
    var fireworks = [SKNode]()
    
    var isGameOver = false
    var isGameOverLabel = false
    
    var scoreLabel: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var comboLabel: SKLabelNode!
    
    let leftEdge = -22
    let bottomEdge = -22
    let rightEdge = 1024 + 22
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var comboNumber = 0
    var numberOfLaunches = 0
    
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Pixel Emulator")
        scoreLabel.text = "SCORE: 0"
        scoreLabel.position = CGPoint(x: 12, y: 12)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontSize = 48
        addChild(scoreLabel)
        scoreLabel.zPosition = 1
        
        gameTimer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(launchFireworks), userInfo: nil, repeats: true)
    }
    
    
    func createFirework(xMovement: CGFloat, x: Int, y: Int) {
        let node = SKNode()
        node.position = CGPoint(x: x, y: y)
        
        let firework = SKSpriteNode(imageNamed: "rocket")
        firework.colorBlendFactor = 1 // make the fireworks FULLY (1) covered by the color of our choice.
        firework.name = "firework"
        node.addChild(firework)
        
        switch Int.random(in: 0...2) {
        case 0: // if Int=0:
            firework.color = .cyan
        case 1: // if Int=1:
            firework.color = .green
        default: // if Int = any of all other values (which is only 2):
            firework.color = .red
        }
        
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: xMovement, y: 1000))
        
        let move = SKAction.follow(path.cgPath, asOffset: true, orientToPath: true, speed: 200)
        
        node.run(move) // start following that path now.
        
        let emitter = SKEmitterNode(fileNamed: "fuse")!
        emitter.position = CGPoint(x: 0, y: -22)
        node.addChild(emitter)
        
        fireworks.append(node)
        addChild(node)
    }
    
    @objc func launchFireworks() {
        let movementAmount: CGFloat = 1800
        
        numberOfLaunches += 1
        
        switch Int.random(in: 0...3) {
        case 0:
            //fire five, straight up
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 0, x: 512 + 200, y: bottomEdge)

        case 1:
            //fire five, in a fan
            createFirework(xMovement: 0, x: 512, y: bottomEdge)
            createFirework(xMovement: -200, x: 512 - 200, y: bottomEdge)
            createFirework(xMovement: -100, x: 512 - 100, y: bottomEdge)
            createFirework(xMovement: 100, x: 512 + 100, y: bottomEdge)
            createFirework(xMovement: 200, x: 512 + 200, y: bottomEdge)

        case 2:
            //fire five, from the left to the right
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 400)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 300)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 200)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge + 100)
            createFirework(xMovement: movementAmount, x: leftEdge, y: bottomEdge)

        case 3:
            //fire five, from the right to the left
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 400)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 300)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 200)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge + 100)
            createFirework(xMovement: -movementAmount, x: rightEdge, y: bottomEdge)

        default:
            break // to be filled later with different kinds of firework layouts
        }
    }
    
    func checkTouches (_ touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)
       
        // we create a new constant ('let node') which will be a sprite node ('as SKSpriteNode') only if that condition is true ('case') and then run a loop for that item. now we have guaranteed 'node' as SKSpriteNode, just as a regular SKNode.
        for case let node as SKSpriteNode in nodesAtPoint {
            guard node.name == "firework" else { continue } // bail out immediately if we're dealing with any other node than a firework (like the background, for example)
            
            // The loop below is responsible for choosing the next rocket. If a tapped rocket has the same colour of the rocket that was tapped before, both of them will be marked white. If the first one was, say, green, and the next one is red, the previous rocket is reset to a green colour, and the red one becomes white.
            // node = tapped rocket
            // firework = the rockets that were tapped before
            for parent in fireworks {
                guard let firework = parent.children.first as? SKSpriteNode else { continue } // exit the loop immediately if we can't find the sprite node inside the parent node.
                
                if firework.name == "selected" && firework.color != node.color {
                    firework.name = "firework"
                    firework.colorBlendFactor = 1
                } // if 1 or more rockets were already tapped and doesn't match the colour of the currenty tapped rocket (node.color), revert their name to the default one ("firework") and revert them to their default colours.
            }
            node.name = "selected"
            node.colorBlendFactor = 0 // selected node becomes plain white.
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        checkTouches(touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        checkTouches(touches) // it will pass on the touches we have given onto the checkTouches() method.
    }
    
    override func update(_ currentTime: TimeInterval) {
        for (index, firework) in fireworks.enumerated().reversed() {
            if firework.position.y > 900 {
                fireworks.remove(at: index)
                firework.removeFromParent()
            }
        }
        // after 10 launches and all fireworks removed from the screen (whether by exploding them or themselves removing from the scene after going beyond the frame), the game is over:
        if isGameOverLabel == false && numberOfLaunches == 2 && fireworks.count == 0 {
            gameTimer?.invalidate()
            createGameOverLabel()
            isGameOverLabel = true // By that we prevent the label from appearing 60 times every second after the game is over. Now it appears just once.
        }
    }
    
    func explode(firework: SKNode) {
        if let emitter = SKEmitterNode(fileNamed: "explode") {
            emitter.position = firework.position
            addChild(emitter)
        // We wait for the explosion to disappear by itself, then we remove the explosion node after 1 second:
            let wait = SKAction.wait(forDuration: 1)
            let remove = SKAction.removeFromParent()
            let removingSequence = SKAction.sequence([wait, remove])
            
            emitter.run(removingSequence)
        }
        firework.removeFromParent()
    }
    
    func explodeFireworks() {
        var numExploded = 0
        
        for (index, fireworkContainer) in fireworks.enumerated().reversed() {
            guard let firework = fireworkContainer.children.first as? SKSpriteNode else { continue }
            
            if firework.name == "selected" {
                explode(firework: fireworkContainer)
                fireworks.remove(at: index)
                numExploded += 1
            }
        }
        
        switch numExploded {
        case 0:
            break // no points for no fireworks exploded!
        case 1:
            score += 200
            comboNumber = 1
            createComboLabel()
        case 2:
            score += 500
            comboNumber = 2
            createComboLabel()
        case 3:
            score += 1500
            comboNumber = 3
            createComboLabel()
        case 4:
            score += 2500
            comboNumber = 4
            createComboLabel()
        default:
            score += 4000
            comboNumber = 5
            createComboLabel()
        }
    }
    
    func createGameOverLabel() {
        gameOverLabel = SKLabelNode(fontNamed: "Pixel Emulator")
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.fontSize = 65
        gameOverLabel.zPosition = 1
        addChild(gameOverLabel)
    }
    
    func createComboLabel() {
        comboLabel = SKLabelNode(fontNamed: "Pixel Emulator")
        comboLabel.text = "x\(comboNumber)"
        comboLabel.position = CGPoint(x: 512, y: 100)
        comboLabel.horizontalAlignmentMode = .center
        comboLabel.fontSize = 65
        comboLabel.zPosition = 1
        addChild(comboLabel)
        
        let move = SKAction.moveBy(x: 0, y: 70, duration: 0.4)
        let fade = SKAction.fadeAlpha(to: 0, duration: 0.5)
        let wait = SKAction.wait(forDuration: 0.8)
        let remove = SKAction.removeFromParent()
        let waitForRemovalSequence = SKAction.sequence([wait, remove])
        comboLabel.run(move)
        comboLabel.run(fade)
        comboLabel.run(waitForRemovalSequence)
    }
}
