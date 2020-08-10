//
//  GameScene.swift
//  Project36
//
//  Created by Mateusz Zacharski on 21/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//
import GameplayKit
import AVFoundation // required to operate with the audio engine
import SpriteKit

enum GameState {
    case showingLogo
    case playing
    case dead
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    var backgroundMusic: SKAudioNode!
    
    var score = 0 {
        didSet {
            scoreLabel.text = "SCORE: \(score)"
        }
    }
    var logo: SKSpriteNode!
    var gameOver: SKSpriteNode!
    
    var gameState = GameState.showingLogo
    
    var wasContact = false
    
    // preloading textures and their physics to avoid freezing every time a new obstacle is created:
    let rockTexture = SKTexture(imageNamed: "rock")
    var rockPhysics: SKPhysicsBody!
    let bottleTexture = SKTexture(imageNamed: "bottle")
    var bottlePhysics: SKPhysicsBody!
    let headTexture = SKTexture(imageNamed: "head")
    var headPhysics: SKPhysicsBody!
    
    let explosion = SKEmitterNode(fileNamed: "PlayerExplosion") // this property won't be used in the game, however creating it forces SpriteKit to preload the texture and keep it on memory, so it's already there when it's really needed. In short: preloading the data to avoid freezing.
    let coinSound = SKAction.playSoundFileNamed("coin.wav", waitForCompletion: false) // preloading the data to avoid freezing.
    let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false) // preloading the data to avoid freezing.
    
    override func didMove(to view: SKView) {
        do {
         try scene?.audioEngine.start()
        } catch {
            print("audio engine error")
        }
        
        createPlayer()
        createSky()
        createBackground()
        createGround()
        createScore()
        createLogos()
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -5.0)
        physicsWorld.contactDelegate = self
        
        // Playing background music (as an SKAudioNode, it will loop indenifitely):
        if let musicURL = Bundle.main.url(forResource: "music", withExtension: "m4a") {
            backgroundMusic = SKAudioNode(url: musicURL)
            let wait = SKAction.wait(forDuration: 1.5)
            let playMusic = SKAction.run { [unowned self] in
                self.addChild(self.backgroundMusic)
            }
            let sequence = SKAction.sequence([wait, playMusic])
            run(sequence)
        }
        
        rockPhysics = SKPhysicsBody(texture: rockTexture, size: rockTexture.size()) // create an SKPhysicsBody from our rock texture and store it in that rockPhysics property for later on. Then it can be copied so as not to create a new physics body every time a new rock appears.
        bottlePhysics = SKPhysicsBody(texture: bottleTexture, size: bottleTexture.size()) // same thing as above, but for bottles.
        headPhysics = SKPhysicsBody(texture: headTexture, size: headTexture.size())
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .showingLogo:
            gameState = .playing
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            let wait = SKAction.wait(forDuration: 0.5)
            let activatePlayer = SKAction.run { [unowned self] in
                self.player.physicsBody?.isDynamic = true
                self.startObstacles()
            }
            
            let sequence = SKAction.sequence([fadeOut, wait, activatePlayer, remove])
            logo.run(sequence)
            
        case .playing:
            player.physicsBody?.velocity = CGVector(dx: 0, dy: 0) // neutralizes any existing upward velocity the player has before applying the new movement.
            player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20)) // give the player a push upwards every time the player taps the screen.
        
        case .dead: // create a fresh GameScene scene, give it the same 'aspectFill' resizing as our original game scene, then make it transition with a smile animation:
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                let transition = SKTransition.moveIn(with: SKTransitionDirection.right, duration: 1)
                view?.presentScene(scene, transition: transition)
            }
        }
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        // When player collides with scoreDetect rectangle:
        if contact.bodyA.node?.name == "scoreDetect" || contact.bodyB.node?.name == "scoreDetect" {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
            } else {
                contact.bodyA.node?.removeFromParent()
            }
            
            run(coinSound)
            
            score += 1
            
            return // We added the 'return' here because if the player collides with anything else we want to destroy them. This just means "you hit something safe - don't continue this method".
        }
        
        // When player collides with a coin:
        if contact.bodyA.node?.name == "coin" || contact.bodyB.node?.name == "coin" {
            if contact.bodyA.node == player {
                contact.bodyB.node?.removeFromParent()
            } else {
                contact.bodyA.node?.removeFromParent()
            }
            
            run(coinSound)
            
            score += 1
            
            return // We added the 'return' here because if the player collides with anything else we want to destroy them. This just means "you hit something safe - don't continue this method".
        }
        
        guard contact.bodyA.node != nil && contact.bodyB.node != nil else { return } // By adding this line, we avoid a common problem. When the player hits a "scoreDetect" or "coin" node it's possible TWO collisions are triggered: "player hit score detect (or coin)" and "score detect (or coin) hit player" The first time our code works, but the second time the "scoreDetect"/"coin" node has been removed so the game considers the player destroyed. The guard avoids that by skipping any collisions where either node has become nil.
        
        // When player collides with anything else than scoreDetect rectangle or a coin:
        // We put everything in 'if wasContact == false' and then mark 'wasContact = true' at the end of the call, so that we don't have any repetitions of the code (pixel perfect physics contact may create multiple contacts, which causes the code to be called more than once).
        if wasContact == false {
            if contact.bodyA.node == player || contact.bodyB.node == player {
                if let explosion = SKEmitterNode(fileNamed: "PlayerExplosion") {
                    explosion.position = player.position
                    addChild(explosion)
                }
                
                run(explosionSound)
                print("boom")
                gameOver.alpha = 1 // show the game over logo
                gameState = .dead // change the game state to .dead
                backgroundMusic.run(SKAction.stop()) // cut the music off.
                
                player.removeFromParent()
                speed = 0
                
                wasContact = true
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        guard player != nil else { return } // if the update method is called before the player is created (and it can be!) then Swift will try to adjust the rotation of a nil property because the player hasn't been created yet, which will make our game crash. This line means "ensure that player is not nil, otherise exit the method".
        
        let value = player.physicsBody!.velocity.dy * 0.001
        let rotate = SKAction.rotate(toAngle: value, duration: 0.1)
        
        player.run(rotate) // When the player is moving upwards the plane tilts up a little, and when the player is falling the plane tilts down.
    }
    
    func createPlayer() {
        let playerTexture = SKTexture(imageNamed: "player-1")
        player = SKSpriteNode(texture: playerTexture)
        player.zPosition = 10
        // The app is fully compatible with both iPads and iPhones. First of all, we set the  we need to set the scene scale mode to .aspectFill. Then, in GameScene.sks we set the scene width to be wider - I put it at 500. Then we adjust the position of the player depending on the device, as normally on an iPhone the player will be shifted to the left, so we have to put them further to the right:
        if UIDevice.current.userInterfaceIdiom == .phone {
            player.position = CGPoint(x: frame.width / 3.9, y: frame.height * 0.75) // we don't use the exact x and y numbers because of different iPhone screen sizes and resolutions.
        } else {
            player.position = CGPoint(x: frame.width / 6.5, y: frame.height * 0.75) // we don't use the exact x and y numbers because of different iPhone screen sizes and resolutions.
        }
        
        addChild(player)
        
        player.physicsBody = SKPhysicsBody(texture: playerTexture, size: playerTexture.size()) // setting up pixel-perfect physics using the sprite of the plane.
        player.physicsBody!.contactTestBitMask = player.physicsBody!.collisionBitMask // tell us whenever the player collides with anything.
        player.physicsBody?.isDynamic = false // make the plane not respond to physics until the player is ready to start the game.
        player.physicsBody?.collisionBitMask = 0 // make the plane bounce off nothing.
        
        let frame2 = SKTexture(imageNamed: "player-2")
        let frame3 = SKTexture(imageNamed: "player-3")
        let animation = SKAction.animate(with: [playerTexture, frame2, frame3, frame2], timePerFrame: 0.01)
        let runForever = SKAction.repeatForever(animation)
        
        player.run(runForever)
    }
    
    func createSky() {
        let topSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.14, brightness: 0.97, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.67)) // the node takes 67% of the screen.
        topSky.anchorPoint = CGPoint(x: 0.5, y: 1) // node's anchor point is at the top center for easier placement
        
        let bottomSky = SKSpriteNode(color: UIColor(hue: 0.55, saturation: 0.16, brightness: 0.96, alpha: 1), size: CGSize(width: frame.width, height: frame.height * 0.33)) // the node takes 33% of the screen.
        bottomSky.anchorPoint = CGPoint(x: 0.5, y: 1) // node's anchor point is at the top center for easier placement
        
        topSky.position = CGPoint(x: frame.midX, y: frame.height)
        bottomSky.position = CGPoint(x: frame.midX, y: bottomSky.frame.height)
        
        addChild(topSky)
        addChild(bottomSky)
        
        bottomSky.zPosition = -40
        topSky.zPosition = -40
    }
    
    func createBackground() {
        let backgroundTexture = SKTexture(imageNamed: "background")
        
        for i in 0 ... 1 {
            let background = SKSpriteNode(texture: backgroundTexture)
            background.zPosition = -30
            background.anchorPoint = CGPoint.zero // makes the background texture position itself from the left edge. This is helpful because it means we know exactly when each mountain is fully off the screen, because its X position will be equal to 0 minuts its width.
            background.position = CGPoint(x: (backgroundTexture.size().width * CGFloat(i)) - CGFloat(1 * i), y: 100) // We calculate the X position like that: this is inside a loop that counts from 0 to 1, so the first time the loop goes around X will be 0, and the second time the loop goes around X will be the width of the texture minus 1 to avoid any tiny little gaps in the mountains.
            addChild(background)
            
            let moveLeft = SKAction.moveBy(x: -backgroundTexture.size().width, y: 0, duration: 20)
            let moveReset = SKAction.moveBy(x: backgroundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            background.run(moveForever) // each mountain will move to the left a distance equal to its width, then jump back another distance equal to its width. This repeats in a sequence forever, so the mountains loop indenifitely.
        }
    }
    
    func createGround() {
        let groundTexture = SKTexture(imageNamed: "ground")
        
        for i in 0 ... 1 {
            let ground = SKSpriteNode(texture: groundTexture)
            ground.zPosition = -10
            ground.position = CGPoint(x: (groundTexture.size().width / 2.0 + (groundTexture.size().width * CGFloat(i))), y: groundTexture.size().height / 2) // we can't adjust the anchor pount of the sprite because it causes problems with physics, oe woe need to do some maths juggling.
            
            ground.physicsBody = SKPhysicsBody(texture: ground.texture!, size: ground.texture!.size())
            ground.physicsBody?.isDynamic = false
            
            addChild(ground)
            
            let moveLeft = SKAction.moveBy(x: -groundTexture.size().width, y: 0, duration: 5)
            let moveReset = SKAction.moveBy(x: groundTexture.size().width, y: 0, duration: 0)
            let moveLoop = SKAction.sequence([moveLeft, moveReset])
            let moveForever = SKAction.repeatForever(moveLoop)
            
            ground.run(moveForever)
        }
    }
    
    func createObstacles() {
        let d6 = GKRandomDistribution.d6()
        let diceThrow = d6.nextInt()
        print(diceThrow)
        if diceThrow <= 2 {
            createRocks()
        } else if diceThrow > 2 && diceThrow <= 4 {
            createBottles()
        } else {
            createHeads()
        }
    }
    
    func startObstacles() {
        let create = SKAction.run { [unowned self] in
            self.createObstacles()
        }
        
        let wait = SKAction.wait(forDuration: 3)
        let sequence = SKAction.sequence([create, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        run(repeatForever)
    }
    
    func createRocks() {
        // 1
        let rockTexture = SKTexture(imageNamed: "rock")
        
        let topRock = SKSpriteNode(texture: rockTexture)
        topRock.physicsBody = rockPhysics.copy() as? SKPhysicsBody // use the copy of already created physics body to avoid game freeze during a new rock creation.
        topRock.physicsBody?.isDynamic = false
        topRock.zRotation = .pi
        topRock.xScale = -1.0 // causes the flip effect - it stretches the sprite by -100% inverting it.
        
        let bottomRock = SKSpriteNode(texture: rockTexture)
        bottomRock.physicsBody = rockPhysics.copy() as? SKPhysicsBody // use the copy of already created physics body to avoid game freeze during a new rock creation.
        bottomRock.physicsBody?.isDynamic = false
        
        topRock.zPosition = -20
        bottomRock.zPosition = -20
        
        //2
        let rockCollision = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 32, height: frame.height)) // we make the rectangles invisible by using 'UIColor.clear'.
        rockCollision.name = "scoreDetect"
        rockCollision.physicsBody = SKPhysicsBody(rectangleOf: rockCollision.size)
        rockCollision.physicsBody?.isDynamic = false
        
        let coin = SKShapeNode(circleOfRadius: 10)
        coin.name = "coin"
        coin.strokeColor = UIColor.black
        coin.fillColor = UIColor.systemYellow
        coin.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        coin.physicsBody?.isDynamic = false
        
        
        addChild(topRock)
        addChild(bottomRock)
        addChild(rockCollision)
        addChild(coin)
        
        // 3
        let xPosition = frame.width + topRock.frame.width
        
        let max = CGFloat(frame.height / 3)
        let yPosition = CGFloat.random(in: -50...max)
        
        // this next value affects the width of the gap between rocks.
        // you can make it smaller to make the game harder:
        let rockDistance: CGFloat = 70
        
        // 4
        topRock.position = CGPoint(x: xPosition, y: yPosition + topRock.size.height + rockDistance)
        bottomRock.position = CGPoint(x: xPosition, y: yPosition - rockDistance)
        rockCollision.position = CGPoint(x: xPosition + (rockCollision.size.width * 2), y: frame.midY)
        coin.position = CGPoint(x: rockCollision.position.x + (rockCollision.size.width * 4) + CGFloat(Int.random(in: -30...30)), y: frame.midY + CGFloat(Int.random(in: -200...200)))
        
        let endPosition = frame.width + (topRock.frame.width * 2) + 100 // adding 100 to compensate for the coin radius (without it, the coin doesn't go beyond the screen and just dissappears in front of us, which looks odd)
        
        let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 6.2)
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        topRock.run(moveSequence)
        bottomRock.run(moveSequence)
        rockCollision.run(moveSequence)
        coin.run(moveSequence)
    }
    
    func createBottles() {
        // 1
        let bottleTexture = SKTexture(imageNamed: "bottle")
        
        let topBottle = SKSpriteNode(texture: bottleTexture)
        topBottle.physicsBody = bottlePhysics.copy() as? SKPhysicsBody // use the copy of already created physics body to avoid game freeze during a new bottle creation.
        topBottle.physicsBody?.isDynamic = false
        topBottle.zRotation = .pi
        
        let bottomBottle = SKSpriteNode(texture: bottleTexture)
        bottomBottle.physicsBody = bottlePhysics.copy() as? SKPhysicsBody // use the copy of already created physics body to avoid game freeze during a new rock creation.
        bottomBottle.physicsBody?.isDynamic = false
        
        topBottle.zPosition = -20
        bottomBottle.zPosition = -20
        
        //2
        let rockCollision = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 32, height: frame.height)) // we make the rectangles invisible by using 'UIColor.clear'.
        rockCollision.name = "scoreDetect"
        rockCollision.physicsBody = SKPhysicsBody(rectangleOf: rockCollision.size)
        rockCollision.physicsBody?.isDynamic = false
        
        let coin = SKShapeNode(circleOfRadius: 10)
        coin.name = "coin"
        coin.strokeColor = UIColor.black
        coin.fillColor = UIColor.systemYellow
        coin.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        coin.physicsBody?.isDynamic = false
        
        addChild(topBottle)
        addChild(bottomBottle)
        addChild(rockCollision)
        addChild(coin)
        
        // 3
        let xPosition = frame.width + topBottle.frame.width
        
        let max = CGFloat(frame.height / 3)
        let yPosition = CGFloat.random(in: -50...max)
        
        // this next value affects the width of the gap between bottles.
        // you can make it smaller to make the game harder:
        let bottleDistance: CGFloat = 70
        
        // 4
        topBottle.position = CGPoint(x: xPosition, y: yPosition + topBottle.size.height + bottleDistance)
        bottomBottle.position = CGPoint(x: xPosition, y: yPosition - bottleDistance)
        rockCollision.position = CGPoint(x: xPosition + (rockCollision.size.width * 2), y: frame.midY)
        coin.position = CGPoint(x: rockCollision.position.x + (rockCollision.size.width * 4) + CGFloat(Int.random(in: -30...30)), y: frame.midY + CGFloat(Int.random(in: -200...200)))
        
        let endPosition = frame.width + (topBottle.frame.width * 2) + 100 // adding 100 to compensate for the coin radius (without it, the coin doesn't go beyond the screen and just dissappears in front of us, which looks odd)
        
        let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 6.2)
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        topBottle.run(moveSequence)
        bottomBottle.run(moveSequence)
        rockCollision.run(moveSequence)
        coin.run(moveSequence)
    }
    
    func createHeads() {
        // 1
        let headTexture = SKTexture(imageNamed: "head")
        
        let topHead = SKSpriteNode(texture: headTexture)
        topHead.physicsBody = headPhysics.copy() as? SKPhysicsBody // use the copy of already created physics body to avoid game freeze during a new bottle creation.
        topHead.physicsBody?.isDynamic = false
        topHead.zRotation = .pi
        topHead.setScale(0.5) // making the head smaller, as the original texture size is huge.
        
        let bottomHead = SKSpriteNode(texture: headTexture)
        bottomHead.physicsBody = headPhysics.copy() as? SKPhysicsBody // use the copy of already created physics body to avoid game freeze during a new rock creation.
        bottomHead.physicsBody?.isDynamic = false
        bottomHead.setScale(0.5) // making the head smaller, as the original texture size is huge.
        
        topHead.zPosition = -20
        bottomHead.zPosition = -20
        
        //2
        let rockCollision = SKSpriteNode(color: UIColor.clear, size: CGSize(width: 32, height: frame.height)) // we make the rectangles invisible by using 'UIColor.clear'.
        rockCollision.name = "scoreDetect"
        rockCollision.physicsBody = SKPhysicsBody(rectangleOf: rockCollision.size)
        rockCollision.physicsBody?.isDynamic = false
        
        let coin = SKShapeNode(circleOfRadius: 10)
        coin.name = "coin"
        coin.strokeColor = UIColor.black
        coin.fillColor = UIColor.systemYellow
        coin.physicsBody = SKPhysicsBody(circleOfRadius: 10)
        coin.physicsBody?.isDynamic = false
        
        addChild(topHead)
        addChild(bottomHead)
        addChild(rockCollision)
        addChild(coin)
        
        // 3
        let xPosition = frame.width + topHead.frame.width
        
        let max = CGFloat(frame.height / 3)
        let yPosition = CGFloat.random(in: -50...max)
        
        // this next value affects the width of the gap between bottles.
        // you can make it smaller to make the game harder:
        let headDistance: CGFloat = 70
        
        // 4
        topHead.position = CGPoint(x: xPosition, y: yPosition + topHead.size.height + headDistance)
        bottomHead.position = CGPoint(x: xPosition, y: yPosition - headDistance)
        rockCollision.position = CGPoint(x: xPosition + (rockCollision.size.width * 2), y: frame.midY)
        coin.position = CGPoint(x: rockCollision.position.x + (rockCollision.size.width * 4) + CGFloat(Int.random(in: -30...30)), y: frame.midY + CGFloat(Int.random(in: -200...200)))
        
        let endPosition = frame.width + (topHead.frame.width * 2) + 100 // adding 100 to compensate for the coin radius (without it, the coin doesn't go beyond the screen and just dissappears in front of us, which looks odd)
        let moveAction = SKAction.moveBy(x: -endPosition, y: 0, duration: 8.0)
        let moveSequence = SKAction.sequence([moveAction, SKAction.removeFromParent()])
        topHead.run(moveSequence)
        bottomHead.run(moveSequence)
        rockCollision.run(moveSequence)
        coin.run(moveSequence)
    }
    
    func createScore() {
        scoreLabel = SKLabelNode(fontNamed: "Optima-ExtraBlack")
        scoreLabel.fontSize = 24
        
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.maxY - 60)
        scoreLabel.text = "SCORE: 0"
        scoreLabel.fontColor = UIColor.black
        
        addChild(scoreLabel)
    }
    
    func createLogos() {
        logo = SKSpriteNode(imageNamed: "logo")
        logo.position = CGPoint(x: frame.midX, y: frame.midY) // place the logo in the center
        addChild(logo)
        
        gameOver = SKSpriteNode(imageNamed: "gameover")
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOver.alpha = 0
        addChild(gameOver)
    }
    
}
