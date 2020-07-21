//
//  GameScene.swift
//  Project26
//
//  Created by MacBook on 17/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//
import CoreMotion
import SpriteKit

enum CollisionTypes: UInt32 {
    case player = 1
    case wall = 2
    case star = 4
    case vortex = 8
    case finish = 16
    case teleportOrange = 32
    case teleportBlue = 64
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode!
    var lastTouchPosition: CGPoint?
    
    var motionManager: CMMotionManager?
    var isGameOver = false
    
    var scoreLabel: SKLabelNode!
    
    var levelNumber = 1
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var isPortalActive = true
    

    override func didMove(to view: SKView) {
        createBackground()
        createScoreLabel()
        
        loadLevel()
        createPlayer()
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self // "tell us, when a collision happened". We need to set our class as a delegate to get the info about collisions.
        
        motionManager = CMMotionManager()
        motionManager?.startAccelerometerUpdates()
        }
    
    func loadLevel() {
        guard let levelURL = Bundle.main.url(forResource: "level\(levelNumber)", withExtension: "txt") else { fatalError("Could not find level\(levelNumber).txt in the app bundle.") }
        guard let levelString = try? String(contentsOf: levelURL) else { fatalError("Could not load level\(levelNumber).txt from the app bundle.") }
        
        let lines = levelString.components(separatedBy: "\n")
        
        // 'enumerated()' method loops over an array, extracting each item and its position in the array.
        // Each square in the game occupies a 64x64 space, so we can find its position by multiplying its row and column by 64. BUT: remember that SpriteKit calculates its positions from the center of the objects, so we need to add 32 to the X and Y coordinates in order to make everything line up on our screen.
        // SpriteKit uses and inverted Y axis to UIKit, which means for SpriteKit Y:0 is the bottom of the screen whereas for UIKit Y:0 is the top. When it comes to loading level rows, this means we need to read them in reverse so that the last row is created at the bottom of the screen and so on upwards.
        for (row, line) in lines.reversed().enumerated() {
            for (column, letter) in line.enumerated() {
                let position = CGPoint(x: (64 * column) + 32, y: (64 * row) + 32) // We need to add 32 to y and x of each position to center the placement of a node.
                
                if letter == "x" {
                    // load wall
                    createWall(position: position)
                } else if letter == "v" {
                    // load vortex
                    createVortex(position: position)
                } else if letter == "s" {
                    // load star
                    createStar(position: position)
                } else if letter == "f" {
                    // load the finish point
                    createFinish(position: position)
                } else if letter == "o" {
                    // create orange portal
                    createTeleportOrange(position: position)
                } else if letter == "p" {
                    // create blue portal
                    createTeleportBlue(position: position)
                } else if letter == " " {
                    // this is an empty space = do nothing!
                } else {
                    fatalError("Unknown level letter: \(letter).")
                }
            }
        }
        
    }
    
    func createBackground() {
        let background = SKSpriteNode(imageNamed: "background")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
    }
    
    func createScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
    }
    
    func createGameOverLabel() {
        let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")
        gameOverLabel.text = "AWESOME!"
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.fontSize = 55
        gameOverLabel.zPosition = 2
        addChild(gameOverLabel)
    }
    
    func createWall(position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "block")
        node.position = position
        
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.categoryBitMask = CollisionTypes.wall.rawValue // we use .rawValue to extract the Int32 value from the enum (which, in this case, is "2".)
        node.physicsBody?.isDynamic = false
        
        addChild(node)
    }
    
    func createVortex(position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "vortex"
        node.position = position
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.vortex.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue // when the vortex touches the player, we want to be told about it.
        node.physicsBody?.collisionBitMask = 0 // it bounces of nothing, so the player will roll into it and get sucked into the vortex.
        
        addChild(node)
    }
    
    func createStar(position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "star")
        node.name = "star"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.star.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
    }
    
    func createFinish(position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "finish")
        node.name = "finish"
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.finish.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
    }
    
    func createTeleportOrange(position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "teleportOrange"
        node.color = .orange
        node.colorBlendFactor = 1000
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.teleportOrange.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
    }
    
    func createTeleportBlue(position: CGPoint) {
        let node = SKSpriteNode(imageNamed: "vortex")
        node.name = "teleportBlue"
        node.color = .blue
        node.colorBlendFactor = 1000
        node.physicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2)
        node.run(SKAction.repeatForever(SKAction.rotate(byAngle: .pi, duration: 1)))
        node.physicsBody?.isDynamic = false
        
        node.physicsBody?.categoryBitMask = CollisionTypes.teleportBlue.rawValue
        node.physicsBody?.contactTestBitMask = CollisionTypes.player.rawValue
        node.physicsBody?.collisionBitMask = 0
        node.position = position
        addChild(node)
    }
    
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x:96, y: 672)
        player.zPosition = 1
        player.setScale(0.01)
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue | CollisionTypes.teleportOrange.rawValue | CollisionTypes.teleportBlue.rawValue // the pipes here mean "combine this number with that number"
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        addChild(player)
        
        let scaleUp = SKAction.scale(to: 1.25, duration: 0.15)
        let scaleDown = SKAction.scale(to: 1, duration: 0.15)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        player.run(sequence)
    }
    
    func teleportPlayer(to position: CGPoint) {
        player = SKSpriteNode(imageNamed: "player")
        player.position = position
        player.zPosition = 1
        player.setScale(0.01)
        
        player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width / 2)
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 0.5
        
        player.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player.physicsBody?.contactTestBitMask = CollisionTypes.star.rawValue | CollisionTypes.vortex.rawValue | CollisionTypes.finish.rawValue | CollisionTypes.teleportOrange.rawValue | CollisionTypes.teleportBlue.rawValue // the pipes here mean "combine this number with that number"
        player.physicsBody?.collisionBitMask = CollisionTypes.wall.rawValue
        
        addChild(player)
        
        player.run(SKAction.scale(to: 1, duration: 0.25))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        lastTouchPosition = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        lastTouchPosition = nil
    }
    
    // A hack to change the gravity when moving a finger, so the touching simulates device rotation:
    override func update(_ currentTime: TimeInterval) {
        guard isGameOver == false else { return }
        
        #if targetEnvironment(simulator)
        if let lastTouchPosition = lastTouchPosition {
            let diff = CGPoint(x: lastTouchPosition.x - player.position.x, y: lastTouchPosition.y - player.position.y)
            physicsWorld.gravity = CGVector(dx: diff.x / 100, dy: diff.y / 100)
        }
        #else
        if let accelerometerData = motionManager?.accelerometerData {
            // Note that we passed accelerometer Y to CGVector's X and accelerometer X to CGVector's Y - THIS IS NOT A TYPO! Remember - our device is rotated to landscape right now, which means we also need to flip our corrdinates around.
            physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.y * -50, dy: accelerometerData.acceleration.x * 50)
        }
         #endif
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA == player {
            playerCollided(with: nodeB)
        } else if nodeB == player {
            playerCollided(with: nodeA)
        }
    }
    
    func playerCollided(with node: SKNode) {
        if node.name == "vortex" {
            player.physicsBody?.isDynamic = false
            isGameOver = true
            score -= 1
            
            let move = SKAction.move(to: node.position, duration: 0.25)
            let scale = SKAction.scale(by: 0.0001, duration: 0.25)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([move, scale, remove])
            
            player.run(sequence) { [weak self] in
                self?.createPlayer()
                self?.isGameOver = false
            }
        } else if node.name == "star" {
            node.removeFromParent()
            score += 1

        } else if node.name == "finish" {
            if levelNumber == 4 {
                // finish the game once the level 3 is completed:
                createGameOverLabel()
                physicsWorld.speed = 0
            } else {
                // go to the next level:
                scene?.removeAllChildren()
                
                levelNumber += 1
                
                createBackground()
                createScoreLabel()
                
                loadLevel()
                createPlayer()
            }
        } else if node.name == "teleportOrange" {
            // Teleport the ball to the blue portal and disable using portals for 3 seconds to avoid teleport loop:
            if let bluePortal = scene?.childNode(withName: "teleportBlue") {
                if isPortalActive == true {
                    player.physicsBody?.isDynamic = false

                    let move = SKAction.move(to: node.position, duration: 0.25)
                    let scale = SKAction.scale(by: 0.0001, duration: 0.25)
                    let remove = SKAction.removeFromParent()
                    let disablePortal = SKAction.run { [weak self] in
                            self?.isPortalActive = false
                    }
                    let teleportingSequence = SKAction.sequence([move, scale, remove, disablePortal])
                    
                    player.run(teleportingSequence) { [weak self] in
                        self?.teleportPlayer(to: bluePortal.position)
                        }
                    
                    let wait = SKAction.wait(forDuration: 3.5)
                    let enablePortal = SKAction.run { [weak self] in
                        self?.isPortalActive = true
                    }
                    let enablingPortalsequence = SKAction.sequence([wait, enablePortal])
                    
                    run(enablingPortalsequence)
                }
            }
        } else if node.name == "teleportBlue" {
            // Teleport the ball to the orange portal and disable using portals for 3 seconds to avoid teleport loop:
            if let orangePortal = scene?.childNode(withName: "teleportOrange") {
                if isPortalActive == true {
                    player.physicsBody?.isDynamic = false

                    let move = SKAction.move(to: node.position, duration: 0.25)
                    let scale = SKAction.scale(by: 0.0001, duration: 0.25)
                    let remove = SKAction.removeFromParent()
                    let disablePortal = SKAction.run { [weak self] in
                            self?.isPortalActive = false
                    }
                    let teleportingSequence = SKAction.sequence([move, scale, remove, disablePortal])
                    
                    player.run(teleportingSequence) { [weak self] in
                        self?.teleportPlayer(to: orangePortal.position)
                        }
                    
                    let wait = SKAction.wait(forDuration: 3)
                    let enablePortal = SKAction.run { [weak self] in
                        self?.isPortalActive = true
                    }
                    let enablingPortalsequence = SKAction.sequence([wait, enablePortal])
                    
                    run(enablingPortalsequence)
                }
            }
        }
    }
}
