//
//  GameScene.swift
//  Project11
//
//  Created by MacBook on 07/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//
import UIKit
import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var scoreLabel: SKLabelNode!
    var ballsLeftLabel: SKLabelNode!
    let balls = ["ballBlue", "ballCyan", "ballGrey", "ballGreen", "ballPurple", "ballRed", "ballYellow"]
    var ballsLeft = 5 {
        didSet {
            ballsLeftLabel.text = "Balls left: \(ballsLeft)"
        }
    }
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var boxesOnScene = 0
    
    var editLabel: SKLabelNode!
    
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLabel.text = "Done"
            } else {
                editLabel.text = "Edit"
            }
        }
    }
   
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384) // these x and y are the middle of our screen
        background.blendMode = .replace
        background.zPosition = -2 // .zPosition are the layers. 0 is the first one, -1 will be the slotGlow (to put it behind the slotBase, and -2 is the background.
        addChild(background)
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x:980, y: 700)
        addChild(scoreLabel)
        
        ballsLeftLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsLeftLabel.text = "Balls left: 5"
        ballsLeftLabel.horizontalAlignmentMode = .right
        ballsLeftLabel.position = CGPoint(x:980, y: 650)
        addChild(ballsLeftLabel)
        
        editLabel = SKLabelNode(fontNamed: "Chalkduster")
        editLabel.text = "Edit"
        editLabel.position = CGPoint(x: 80, y: 700)
        addChild(editLabel)
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame) // creates a physical frame from the screen frame
        physicsWorld.contactDelegate = self // We assign the current scene to be the 'physicsWorld.contactDelegate'.
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouncer(at: CGPoint(x: 0, y: 0))
        makeBouncer(at: CGPoint(x: 256, y: 0))
        makeBouncer(at: CGPoint(x: 512, y: 0))
        makeBouncer(at: CGPoint(x: 768, y: 0))
        makeBouncer(at: CGPoint(x: 1024, y: 0))
        
        addRandomBoxes()
        
        addSnow()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        var ballLocation = touch.location(in: self)
        ballLocation.y = 760 // We make sure that the ball will drop only from the top of the screen by setting it initial position to y=760.
        let objects = nodes(at: location) // objects will be all the nodes placed at the designated x/y location.
        
        if objects.contains(editLabel) {
            editingMode.toggle() // .toggle() method flips boolean from false to true, from true to false. the same thing would be: 'editingMode != editingMode'
        } else {
            if editingMode {
                //create a box
                let size = CGSize(width: Int.random(in: 16...128), height: 16)
                let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                box.zRotation = CGFloat.random(in: 0...3)
                box.position = location
                box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                box.physicsBody?.isDynamic = false
                box.name = "box"
                addChild(box)
                boxesOnScene += 1
            } else {
                let ball = SKSpriteNode(imageNamed: balls.randomElement()!) // Every time we tap, a random colour of a ball appears.
                ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0)
                ball.physicsBody?.restitution = 0.4
                ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                // '.collisionBitMask' tells us which nodes should I bump into. By default it's set to EVERYTHING, which is why our balls hit each other, other bouncers and the screen frame with no need of any code.
                // '.contactTestBitMask' means "Which collisions do you want to know about?" - by default it's set to NOTHING.
                // The above code means "I want to bounce off all the physics bodies, and also please inform us about those bounces as well". So, it detects the collisions of the balls.
                // We have nil coalescing here because 'ball' is an optional .physicsBody. We could force unwrap it - "ball.physicsBody!.collisionBitMask" and get rid of nil coalecing, because we are already sure that the ball IS a .physicsBody - because we created it two lines above.
                ball.position = ballLocation
                ball.name = "ball"
                addChild(ball)
            }
        }
    }
    
    func makeBouncer(at position: CGPoint) { // We make this function as to make placing bouncers easier. We can modify 'position' and therefore place multiple bouncers with little to no effort.
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0)
        bouncer.physicsBody?.isDynamic = false // if it's false - the object placed will stay in its place. When true - the physics laws will work upon it.
        addChild(bouncer)
    }
    
    func addSnow() {
        if let snowParticles = SKEmitterNode(fileNamed: "SnowParticles") {
        snowParticles.position = CGPoint(x: 512, y: 775)
        addChild(snowParticles)
        }
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode
        if isGood {
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        } else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        
        slotBase.position = position
        slotGlow.position = position
        
        slotGlow.zPosition = -1
        
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
       
        addChild(slotGlow)
        addChild(slotBase)
        
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10) // .pi = 180 degrees of rotation. The longer the "duration", the slower the rotation will be.
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever) // We apply an action to a node by using the command "thisIsYourNode.run(thisIsYourAction)"
    }
    
    func addRandomBoxes() {
        for _ in 1...30 {
            let size = CGSize(width: Int.random(in: 16...128), height: 16)
            let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
            box.zRotation = CGFloat.random(in: 0...3)
            box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
            box.physicsBody?.isDynamic = false
            box.name = "box"
            box.position = CGPoint(x: CGFloat.random(in: 10...1010), y: CGFloat.random(in: 150...700))
            addChild(box)
            boxesOnScene += 30
        }
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            score += 1
            destroy(ball: ball)
        } else if object.name == "bad" {
            score -= 1
            ballsLeft -= 1
            destroy(ball: ball)
        }
    } // Whether the ball contacts a good or bad slot base, it gets destroyed.
    
    func collisionBallBox(between box: SKNode, object: SKNode) {
        destroyBox(box: box) // The first 'box' is the SKNode from funcdestroyBox(box: SKNode), the second 'box' is the "box" child, added in editingMode.
    }
    
    func destroy(ball: SKNode) {
        if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
            fireParticles.position = ball.position
            addChild(fireParticles)
        }
        ball.removeFromParent()
        checkForGameOver()
    }
    
    func destroyBox(box: SKNode) {
        if let sparkParticles = SKEmitterNode(fileNamed: "MyParticle") {
        sparkParticles.position = box.position
        addChild(sparkParticles)
        }
        box.removeFromParent()
        boxesOnScene -= 1
        }
    
    func checkForGameOver() {
        if ballsLeft == 0 && boxesOnScene > 0 {
            let ac = UIAlertController(title: "GAME OVER", message: "", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default, handler: reloadScene))
            self.view?.window?.rootViewController?.present(ac, animated: true, completion: nil)
        }
    }
    
    func reloadScene(action: UIAlertAction) {
        score = 0
        ballsLeft = 5
        boxesOnScene = 0
        
        if let view = self.view {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFit

                // Present the scene
                view.presentScene(scene)
            }

            view.ignoresSiblingOrder = true

            view.showsFPS = true
            view.showsNodeCount = true
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        // The above guard let lines keep us safe, since sometimes Swift will read the code two times - for the ball as bodyA and for the ball as bodyB in the collision. The first time it runs is fine - the ball is just destroyed. But if it runs the second time, there is nothing to be destroyed, and because we assured that there WILL be a ball to destroy (node!), the game crashes. This lets us replace "contact.bodyA.node!" with just "nodeA" and "contact.bodyB.node!" with "nodeB", preventing the game from crashing.

        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        // If the first body (bodyA) is the ball, we will call the collision between two objects, using nodeA for the ball, and nodeB for the other object.
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        // If the second body (bodyB) is the ball, we will call the collision between two objects, using nodeB for the ball, and nodeA for the other object.
        }
        // Now we will view a game over alert, which will happen if there is no balls left and the scene does NOT have any boxes left.
        if nodeA.name == "box" {
            collisionBallBox(between: nodeA, object: nodeB)
        } else if nodeB.name == "box" {
            collisionBallBox(between: nodeB, object: nodeA)
        }
    }
    
}
