//
//  GameScene.swift
//  Project29
//
//  Created by MacBook on 26/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import SpriteKit

enum CollisionTypes: UInt32 {
    case banana = 1
    case building = 2
    case player = 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var buildings = [BuildingNode]()
   
    // We add a strong reference to the game scene inside the view controller, and a WEAK reference to the view controller inside the game scene:
    weak var viewController: GameViewController?
    
    var player1: SKSpriteNode!
    var player2: SKSpriteNode!
    var banana: SKSpriteNode!
    
    var currentPlayer = 1
    
    var cameraNode = SKCameraNode()
    
    override func didMove(to view: SKView) {
        cameraNode.position = CGPoint(x: (scene?.size.width)! / 2, y: (scene?.size.height)! / 2)
            
        scene?.addChild(cameraNode)
        scene?.camera = cameraNode
        
        backgroundColor = UIColor(hue: 0.669, saturation: 0.99, brightness: 0.67, alpha: 1)
        
        createBuildings()
        createPlayers()
        addWind()
                
        physicsWorld.contactDelegate = self
    }
    
    func createBuildings() {
        var currentX: CGFloat = -15
        
        while currentX < 1024 {
            let size = CGSize(width: Int.random(in: 2...4) * 40, height: Int.random(in: 300...600))
            currentX += size.width + 2
            
            let building = BuildingNode(color: .red, size: size)
            building.position = CGPoint(x: currentX - (size.width / 2), y: size.height / 2)
            building.setup()
           
            addChild(building)
            
            buildings.append(building)
        }
    }
        
    func launch(angle: Int, velocity: Int) {
        let speed = Double(velocity) / 10 // we set the speed by making a double version of velocity and dividing it by 10.
        let radians = deg2rad(degrees: angle) // because SpriteKit accepts radians, not degrees, we need to use the converting function here.
        
        // If by any chance banana IS present in the scene, destroy it - just to be safe.
        if banana != nil {
            banana.removeFromParent()
            banana = nil
        }
        
        banana = SKSpriteNode(imageNamed: "banana")
        banana.name = "banana"
        banana.physicsBody = SKPhysicsBody(circleOfRadius: banana.size.width / 2)
        banana.physicsBody?.categoryBitMask = CollisionTypes.banana.rawValue
        banana.physicsBody?.collisionBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue // the banana can hit building or players.
        banana.physicsBody?.contactTestBitMask = CollisionTypes.building.rawValue | CollisionTypes.player.rawValue
        banana.physicsBody?.usesPreciseCollisionDetection = true // because the banan is small and may be moving at a very fast speed, it's recommended to use precuse collision detection here. It's more taxing on the cpu, so be careful!
        addChild(banana)
        
        if currentPlayer == 1 {
            banana.position = CGPoint(x: player1.position.x - 30, y: player1.position.y + 40)
            banana.physicsBody?.angularVelocity = -20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player1Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player1.run(sequence)
            
            // Giving the banana right push with a mathematical formula:
            let impulse = CGVector(dx: cos(radians) * speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse) // "give this thing a push in that direction"
        } else {
            banana.position = CGPoint(x: player2.position.x + 30, y: player2.position.y + 40)
            banana.physicsBody?.angularVelocity = 20
            
            let raiseArm = SKAction.setTexture(SKTexture(imageNamed: "player2Throw"))
            let lowerArm = SKAction.setTexture(SKTexture(imageNamed: "player"))
            let pause = SKAction.wait(forDuration: 0.15)
            let sequence = SKAction.sequence([raiseArm, pause, lowerArm])
            player2.run(sequence)
            
            // Giving the banana right push with a mathematical formula. Here we give 'speed' a minus, so that the dx direction is opposite to the one of player's 1 banana:
            let impulse = CGVector(dx: cos(radians) * -speed, dy: sin(radians) * speed)
            banana.physicsBody?.applyImpulse(impulse) // "give this thing a push in that direction"
        }
    }
    
    func createPlayers() {
        player1 = SKSpriteNode(imageNamed: "player")
        player1.name = "player1"
        player1.physicsBody = SKPhysicsBody(circleOfRadius: player1.size.width / 2)
        player1.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player1.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player1.physicsBody?.isDynamic = false
        
        // placing the 1st player on top of the SECOND building:
        let player1Bulding = buildings[1]
        player1.position = CGPoint(x: player1Bulding.position.x, y: player1Bulding.position.y + ((player1Bulding.size.height + player1.size.height) / 2))
        addChild(player1)
        
        player2 = SKSpriteNode(imageNamed: "player")
        player2.name = "player2"
        player2.physicsBody = SKPhysicsBody(circleOfRadius: player2.size.width / 2)
        player2.physicsBody?.categoryBitMask = CollisionTypes.player.rawValue
        player2.physicsBody?.collisionBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
        player2.physicsBody?.isDynamic = false
        
        // placing the 2nd player on top of the SECOND building from the end of the bulding array:
        let player2Bulding = buildings[buildings.count - 2]
        player2.position = CGPoint(x: player2Bulding.position.x, y: player2Bulding.position.y + ((player2Bulding.size.height + player2.size.height) / 2))
        addChild(player2)
    }
    
    // Mathematical formula for converting between degrees and radians:
    func deg2rad(degrees: Int) -> Double {
        return Double(degrees) * .pi / 180
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Only with both nodes in place will we actually continue the collision detection:
        guard let firstNode = firstBody.node else { return }
        guard let secondNode = secondBody.node else { return }
        
        if firstNode.name == "banana" && secondNode.name == "building" {
            bananaHit(building: secondNode, atPoint: contact.contactPoint)
            shakeCamera(layer: cameraNode, duration: 0.2)
        }
        
        if firstNode.name == "banana" && secondNode.name == "player1" {
            if viewController!.player2Score < 2 {
                destroy(player: player1)
                shakeCamera(layer: cameraNode, duration: 0.2)
                viewController?.player2Score += 1
            } else {
                destroyWithoutTransition(player: player1)
                shakeCamera(layer: cameraNode, duration: 0.2)
                
                viewController?.gameOverLabel.isHidden = false
                viewController?.gameOverLabel.text = "PLAYER 2 WINS!"
                
                viewController?.playerNumber.isHidden = true
                physicsWorld.speed = 0
            }
            
        }
        
        if firstNode.name == "banana" && secondNode.name == "player2" {
            if viewController!.player1Score < 2 {
                destroy(player: player2)
                shakeCamera(layer: cameraNode, duration: 0.2)
                viewController?.player1Score += 1
            } else {
                destroyWithoutTransition(player: player2)
                shakeCamera(layer: cameraNode, duration: 0.2)
                
                viewController?.gameOverLabel.isHidden = false
                viewController?.gameOverLabel.text = "PLAYER 1 WINS!"
                
                viewController?.playerNumber.isHidden = true
                physicsWorld.speed = 0
            }

        }
    }
    
    func destroy(player: SKSpriteNode) {
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }
        
        player.removeFromParent()
        banana.removeFromParent()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let newGame = GameScene(size: self.size)
            newGame.viewController = self.viewController
            self.viewController?.currentGame = newGame
            
            self.changePlayer()
            newGame.currentPlayer = self.currentPlayer
            
            let transition = SKTransition.doorway(withDuration: 1.5)
            self.view?.presentScene(newGame, transition: transition)
        }
    }
    
    func destroyWithoutTransition(player: SKSpriteNode) {
        if let explosion = SKEmitterNode(fileNamed: "hitPlayer") {
            explosion.position = player.position
            addChild(explosion)
        }
        
        player.removeFromParent()
        banana.removeFromParent()
    }
    
    func bananaHit(building: SKNode, atPoint contactPoint: CGPoint) {
        guard let building = building as? BuildingNode else { return }
        let buildingLocation = convert(contactPoint, to: building)
        building.hit(at: buildingLocation)
        
        if let explosion = SKEmitterNode(fileNamed: "hitBuilding") {
            explosion.position = contactPoint
            addChild(explosion)
        }
        
        banana.name = ""
        banana.removeFromParent()
        banana = nil
        
        changePlayer()
    }
    
    func changePlayer() {
        if currentPlayer == 1 {
            currentPlayer = 2
        } else {
            currentPlayer = 1
        }
        
        viewController?.activatePlayer(number: currentPlayer)
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        guard banana != nil else { return }
        
        if abs(banana.position.y) > 1000 { // If 'y' is <1000 or >1000, it will always call the same code.
            banana.removeFromParent()
            banana = nil
            changePlayer()
        }
    }
    
    func shakeCamera(layer: SKCameraNode, duration:Float) {
        let amplitudeX:Float = 50;
        let amplitudeY:Float = 40;
        let numberOfShakes = duration / 0.04;
        var actionsArray:[SKAction] = [];
        for _ in 1...Int(numberOfShakes) {
            let moveX = Float(arc4random_uniform(UInt32(amplitudeX))) - amplitudeX / 2;
            let moveY = Float(arc4random_uniform(UInt32(amplitudeY))) - amplitudeY / 2;
            let shakeAction = SKAction.moveBy(x: CGFloat(moveX), y: CGFloat(moveY), duration: 0.02);
            shakeAction.timingMode = SKActionTimingMode.easeOut;
            actionsArray.append(shakeAction);
            actionsArray.append(shakeAction.reversed());
        }

        let actionSeq = SKAction.sequence(actionsArray);
        layer.run(actionSeq);
    }
    
    func addWind() {
        let randomDX = CGFloat.random(in: -5...5)
        physicsWorld.gravity.dx = randomDX
        
        addSnow(speed: randomDX * 20)
    }
    
    func addSnow(speed: CGFloat) {
        if let snow = SKEmitterNode(fileNamed: "snowParticle") {
            snow.position = CGPoint(x: 512, y: 768)
            snow.xAcceleration = speed
            addChild(snow)
        }
    }
    
    
}
