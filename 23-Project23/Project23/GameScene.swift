//
//  GameScene.swift
//  Project23
//
//  Created by MacBook on 09/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//
import AVFoundation
import SpriteKit

enum ForceBomb {
    case never, always, random
}

enum SequenceType: CaseIterable {
    case oneNoBomb, one, twoWithOneBomb, two, three, four, chain, fastChain
}

class GameScene: SKScene {
    var gameScore: SKLabelNode!
    var gameOverLabel: SKLabelNode!
    var nodeHitLabel: SKLabelNode!
    var newGameButton: SKSpriteNode!
    
    var score = 0 {
        didSet {
            gameScore.text = "Score: \(score)"
        }
    }
    
    var livesImages = [SKSpriteNode]()
    var lives = 3
    
    var activeSliceBG: SKShapeNode!
    var activeSliceFG: SKShapeNode!
    
    var activeSlicePoints = [CGPoint]()
    var isSwooshSoundActive = false
    var activeEnemies = [SKSpriteNode]()
    var bombSoundEffect: AVAudioPlayer?
    
    var popupTime = 0.9
    var sequence = [SequenceType]()
    var sequencePosition = 0
    var chainDelay = 3.0
    var nextSequenceQueued = true
    
    var isGameEnded = false
    var buttonActivated = false
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "sliceBackground")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -1
        addChild(background)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: -6) // earth default is dy: -9.8. so here the gravity will be a little weaker.
        physicsWorld.speed = 0.85
        
        createScore()
        createLives()
        createSlices()
        
        sequence = [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain] // starting sequence of the game, so that the player gets a warm-up.
        
        // Creating an enum conforming to CaseIterable automatically gets us an allCases property that contains each case in the enum in the order it was defined. So, to generate lots of random sequence types we can use SequenceType.all.cases.randomElement() again and again.
        for _ in 0...1000 {
            if let nextSequence = SequenceType.allCases.randomElement() {
                sequence.append(nextSequence)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.tossEnemies()
        }
    }
    
    func createScore() {
        gameScore = SKLabelNode(fontNamed: "Pixel Emulator")
        gameScore.horizontalAlignmentMode = .left
        gameScore.fontSize = 48
        addChild(gameScore)
        
        gameScore.position = CGPoint(x: 8, y: 8)
        score = 0
    }
    
    func createLives() {
        for i in 0 ..< 3 {
            let spriteNode = SKSpriteNode(imageNamed: "sliceLife")
            spriteNode.position = CGPoint(x: CGFloat(834 + (i * 70)), y: 720)
            addChild(spriteNode)
            livesImages.append(spriteNode)
        }
    }
    
    func createSlices() {
        activeSliceBG = SKShapeNode()
        activeSliceBG.zPosition = 2
        
        activeSliceFG = SKShapeNode()
        activeSliceFG.zPosition = 3
        
        activeSliceBG.strokeColor = UIColor(red: 1, green: 0.9, blue: 0, alpha: 1)
        activeSliceBG.lineWidth = 9
        
        activeSliceFG.strokeColor = UIColor.white
        activeSliceFG.lineWidth = 5
        
        addChild(activeSliceBG)
        addChild(activeSliceFG)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameEnded == false else { return }

        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        redrawActiveSlice()
        
        if !isSwooshSoundActive {
            playSwooshSound()
        }
        
        let nodesAtPoint = nodes(at: location)
        
        for case let node as SKSpriteNode in nodesAtPoint {
            if node.name == "enemy" {
                //destroy the penguin
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                    
                    let wait = SKAction.wait(forDuration: 1)
                    let remove = SKAction.removeFromParent()
                    let emitterSeq = SKAction.sequence([wait, remove])
                    
                    emitter.run(emitterSeq)
                }
                
                let penguinHitLabelPlacement = CGPoint(x: node.position.x + 20, y: node.position.y + 20)
                nodeHitLabel(hitPosition: penguinHitLabelPlacement, text: "+1")
                
                node.name = ""
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut]) // both actions will happen at the same time.
                
                let seq = SKAction.sequence([group, .removeFromParent()]) // scale out, fade out and remove the penguin from parent.
                node.run(seq)
            
                score += 1
                
                // This is how we remove a certain object from the array:
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false))
            } else if node.name == "enemyPokeball" {
                //destroy the pokeball
                if let emitter = SKEmitterNode(fileNamed: "sliceHitEnemy") {
                    emitter.position = node.position
                    addChild(emitter)
                    
                    let wait = SKAction.wait(forDuration: 1)
                    let remove = SKAction.removeFromParent()
                    let emitterSeq = SKAction.sequence([wait, remove])
                    
                    emitter.run(emitterSeq)
                }
                
                let pokeballHitLabelPlacement = CGPoint(x: node.position.x + 20, y: node.position.y + 20)
                nodeHitLabel(hitPosition: pokeballHitLabelPlacement, text: "+3")
                
                node.name = ""
                node.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut]) // both actions will happen at the same time.
                
                let seq = SKAction.sequence([group, .removeFromParent()]) // scale out, fade out and remove the penguin from parent.
                node.run(seq)
                
                score += 3
                
                // This is how we remove a certain object from the array:
                if let index = activeEnemies.firstIndex(of: node) {
                    activeEnemies.remove(at: index)
                }
                let whackSound = SKAction.playSoundFileNamed("whack.caf", waitForCompletion: false)
                let pokeballSound = SKAction.playSoundFileNamed("pokesound.mp3", waitForCompletion: false)
                let pokeballHitSoundGroup = SKAction.group([whackSound, pokeballSound])
                node.run(pokeballHitSoundGroup)
                
            } else if node.name == "bomb" {
                    //destroy the bomb
                guard let bombContainer = node.parent as? SKSpriteNode else { continue } // if we can't read the node parent as a SpriteNode, go to the next node under our finger immediately.
                if let emitter = SKEmitterNode(fileNamed: "sliceHitBomb") {
                    emitter.position = bombContainer.position
                    addChild(emitter)
                    
                    let wait = SKAction.wait(forDuration: 1)
                    let remove = SKAction.removeFromParent()
                    let emitterSeq = SKAction.sequence([wait, remove])
                    
                    emitter.run(emitterSeq)
                }
                
                node.name = ""
                bombContainer.physicsBody?.isDynamic = false
                
                let scaleOut = SKAction.scale(to: 0.001, duration: 0.2)
                let fadeOut = SKAction.fadeOut(withDuration: 0.2)
                let group = SKAction.group([scaleOut, fadeOut]) // both actions will happen at the same time.
                              
                let seq = SKAction.sequence([group, .removeFromParent()])
                bombContainer.run(seq)
                
                if let index = activeEnemies.firstIndex(of: bombContainer) {
                    activeEnemies.remove(at: index)
                }
                
                run(SKAction.playSoundFileNamed("explosion.caf", waitForCompletion: false))
                endGame(triggeredByBomb: true)
            }
        }
    }
    
    func endGame(triggeredByBomb: Bool) {
        guard isGameEnded == false else { return }
        
        isGameEnded = true
        physicsWorld.speed = 0
        
        bombSoundEffect?.stop()
        bombSoundEffect = nil
        
        if triggeredByBomb {
            livesImages[0].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[1].texture = SKTexture(imageNamed: "sliceLifeGone")
            livesImages[2].texture = SKTexture(imageNamed: "sliceLifeGone")
        }
        
        gameOverLabel = SKLabelNode(fontNamed: "Pixel Emulator")
        gameOverLabel.text = "xDDDDDDD"
        gameOverLabel.position = CGPoint(x: 512, y: 384)
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverLabel.fontSize = 48
        gameOverLabel.zPosition = 2
        addChild(gameOverLabel)
        run(SKAction.playSoundFileNamed("gameOver.mp3", waitForCompletion: false))
        
        newGameButton = SKSpriteNode(imageNamed: "newGameBtn")
        newGameButton.position = CGPoint(x: 512, y: 340)
        newGameButton.setScale(0.5)
        addChild(newGameButton)
        newGameButton.zPosition = 2
    }
    
    func playSwooshSound() {
        isSwooshSoundActive = true
        
        let randomNumber = Int.random(in: 1...3)
        let soundName = "swoosh\(randomNumber).caf"
        
        let swooshSound = SKAction.playSoundFileNamed(soundName, waitForCompletion: true)
        
        // Completion closure, after the swooshSound is played, so as to make isSwooshSoundActive = false, which allows the swoosh sound to be played on the next touch:
        run(swooshSound) { [weak self] in
            self?.isSwooshSoundActive = false
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        activeSliceBG.run(SKAction.fadeOut(withDuration: 0.25))
        activeSliceFG.run(SKAction.fadeOut(withDuration: 0.25))
        
        if buttonActivated == true {
            newGameButton?.run(SKAction.scale(to: 0.5, duration: 0.1)) // scaling the button back to the original size (we set newGameLabel's scale = 0.5 at the beginning).
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        activeSlicePoints.removeAll(keepingCapacity: true)
        
        let location = touch.location(in: self)
        activeSlicePoints.append(location)
        
        redrawActiveSlice()
        
        // When we lift our finger, a fade-out action is executed for 0.25s. During that time, we are also able to make a new touch, which would interfere with the fade-out animation, so what we want to do, is to say: "in case I touch screen in less than 0.25s after I lifted up my finger before, cancel the fade-out animation of the previous trail and just let it disappear momentarily.
        activeSliceBG.removeAllActions()
        activeSliceFG.removeAllActions()
        
        activeSliceBG.alpha = 1
        activeSliceFG.alpha = 1
        
        let tappedNodes = nodes(at: location)
        for node in tappedNodes {
            if node == newGameButton {
                buttonActivated = true
                node.run(SKAction.scale(by: 0.8, duration: 0.1))
            }
        }
        
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
    
    func redrawActiveSlice() {
        if activeSlicePoints.count < 2 {
            activeSliceBG.path = nil
            activeSliceFG.path = nil
            return
        }
        // While we move our finger, the trail is cut at the end each time we move our finger (like in "Snake" game):
        if activeSlicePoints.count > 12 {
            activeSlicePoints.removeFirst(activeSlicePoints.count - 12)
        }
        
        // Let activeSliceBG and activeSliceFG appear where we drag our finger:
        let path = UIBezierPath()
        path.move(to: activeSlicePoints[0])
        
        for i in 1 ..< activeSlicePoints.count {
            path.addLine(to: activeSlicePoints[i])
        }
        
        activeSliceBG.path = path.cgPath
        activeSliceFG.path = path.cgPath
    }
    
    func createEnemy(forceBomb: ForceBomb = .random) {
        let enemy: SKSpriteNode
        
        var enemyType = Int.random(in: 0...6)
        
        if forceBomb == .never {
            enemyType = Int.random(in: 1...6)
        } else if forceBomb == .always {
            enemyType = 0
        }
        
        if enemyType == 0 {
            enemy = SKSpriteNode()
            enemy.zPosition = 1
            enemy.name = "bombContainer"
            
            let bombImage = SKSpriteNode(imageNamed: "sliceBomb")
            bombImage.name = "bomb"
            enemy.addChild(bombImage)
            
            if bombSoundEffect != nil {
                bombSoundEffect?.stop()
                bombSoundEffect = nil
            }
            
            if let path = Bundle.main.url(forResource: "sliceBombFuse", withExtension: "caf") {
                if let sound = try? AVAudioPlayer(contentsOf: path) {
                    bombSoundEffect = sound
                    sound.play()
                }
            }
            // the fuse burning effect:
            if let emitter = SKEmitterNode(fileNamed: "sliceFuse") {
                emitter.position = CGPoint(x: 76, y: 64) //
                enemy.addChild(emitter)
            }
            
        } else if enemyType == 2 {
            enemy = SKSpriteNode(imageNamed: "pokeball")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemyPokeball"
            enemy.scale(to: CGSize(width: 64, height: 64))
        } else {
            enemy = SKSpriteNode(imageNamed: "penguin")
            run(SKAction.playSoundFileNamed("launch.caf", waitForCompletion: false))
            enemy.name = "enemy"
        }
        
        let randomPosition = CGPoint(x: Int.random(in: 64...960), y: -128)
        enemy.position = randomPosition
        
        let randomAngularVelocity = CGFloat.random(in: -3...3)
        let randomXVelocity: Int
        
        let tossedFromLeft = randomPosition.x < 256
        let tossedFromCenterLeft = randomPosition.x < 512
        let tossedFromCenterRight = randomPosition.x < 768
        
        var fastTossSpeedToRight: Int
        var slowTossSpeedToRight: Int
        var fastTossSpeedToLeft: Int
        var slowTossSpeedToLeft: Int
        
        // The pokeball will be tossed faster than the rest of the nodes:
        if enemyType == 2 {
            fastTossSpeedToRight = Int.random(in: 15...25)
            slowTossSpeedToRight = Int.random(in: 7...12)
            fastTossSpeedToLeft = -Int.random(in: 15...25)
            slowTossSpeedToLeft = -Int.random(in: 7...12)
        } else {
            fastTossSpeedToRight = Int.random(in: 8...15)
            slowTossSpeedToRight = Int.random(in: 3...5)
            fastTossSpeedToLeft = -Int.random(in: 8...15)
            slowTossSpeedToLeft = -Int.random(in: 3...5)
        }
        
        if tossedFromLeft {
            randomXVelocity = fastTossSpeedToRight
        } else if tossedFromCenterLeft {
                randomXVelocity = slowTossSpeedToRight
        } else if tossedFromCenterRight {
            randomXVelocity = slowTossSpeedToLeft
        } else {
            randomXVelocity = fastTossSpeedToLeft
        }
        
        let randomYVelocity = Int.random(in: 24...32)
        
        enemy.physicsBody = SKPhysicsBody(circleOfRadius: 64)
        enemy.physicsBody?.velocity = CGVector(dx: randomXVelocity * 40, dy: randomYVelocity * 40)
        enemy.physicsBody?.angularVelocity = randomAngularVelocity
        enemy.physicsBody?.collisionBitMask = 0
        
        addChild(enemy)
        activeEnemies.append(enemy)
    }
    
    func subtractLife() {
        lives -= 1
        run(SKAction.playSoundFileNamed("wrong.caf", waitForCompletion: false))
        
        var life: SKSpriteNode
        
        if lives == 2 {
            life = livesImages[0]
        } else if lives == 1 {
            life = livesImages[1]
        } else {
            life = livesImages[2]
            endGame(triggeredByBomb: false)
        }
        
        life.texture = SKTexture(imageNamed: "sliceLifeGone")
        life.xScale = 1.3
        life.yScale = 1.3
        life.run(SKAction.scale(to: 1, duration: 0.1))
    }
    
    override func update(_ currentTime: TimeInterval) {
        if activeEnemies.count > 0 {
            for (index, node) in activeEnemies.enumerated().reversed() {
                if node.position.y < -140 {
                    node.removeAllActions()
                    
                    if node.name == "enemy" || node.name == "enemyPokeball" {
                        node.name = ""
                        subtractLife()
                        
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    } else if node.name == "bombContainer" {
                        node.name = ""
                        node.removeFromParent()
                        activeEnemies.remove(at: index)
                    }
                }
            }
        } else {
            if !nextSequenceQueued {
                DispatchQueue.main.asyncAfter(deadline: .now() + popupTime) { [weak self] in
                    self?.tossEnemies()
                }
                nextSequenceQueued = true
            }
        }
        var bombCount = 0
        
        for node in activeEnemies {
            if node.name == "bombContainer" {
                bombCount += 1
                break
            }
        }
        
        if bombCount == 0 {
            //no bombs = stop the fuse sound!
            bombSoundEffect?.stop()
            bombSoundEffect = nil
        }
    }
    
    func tossEnemies() {
        guard isGameEnded == false else { return }
        
        //making the game faster with time:
        popupTime *= 0.991
        chainDelay *= 0.99
        physicsWorld.speed *= 1.02
        
        let sequenceType = sequence[sequencePosition]
        
        switch sequenceType {
        case .oneNoBomb:
            createEnemy(forceBomb: .never)
            
        case .one:
            createEnemy()
            
        case .twoWithOneBomb:
            createEnemy(forceBomb: .never)
            createEnemy(forceBomb: .always)
            
        case .two:
            createEnemy()
            createEnemy()
            
        case .three:
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .four:
            createEnemy()
            createEnemy()
            createEnemy()
            createEnemy()
            
        case .chain:
            createEnemy()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0))
            { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 2))
            { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 3))
            { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 5.0 * 4))
            { [weak self] in self?.createEnemy() }
            
        case .fastChain:
            createEnemy()
            // Here we divide the chainDelay by 10, which will make enemies appear slightly faster:
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0))
            { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 2))
            { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 3))
            { [weak self] in self?.createEnemy() }
            DispatchQueue.main.asyncAfter(deadline: .now() + (chainDelay / 10.0 * 4))
            { [weak self] in self?.createEnemy() }
        }
        
        sequencePosition += 1 // because 'sequence' when we start the game is an array of [.oneNoBomb, .oneNoBomb, .twoWithOneBomb, .twoWithOneBomb, .three, .one, .chain], adding +1 to sequencePosition after each toss will call these cases one by one. So, this is the warm up. After that, we get this:
//        for _ in 0...1000 {
//            if let nextSequence = SequenceType.allCases.randomElement() {
//                sequence.append(nextSequence)
//            }
//        } Which will just call randomElement from allCases of how we can toss the enemies.
        nextSequenceQueued = false // this property is used so we know when all the enemies are destroyed and we're ready to create more.
    }
    
    func nodeHitLabel(hitPosition: CGPoint, text: String) {
        nodeHitLabel = SKLabelNode(fontNamed: "Pixel Emulator")
        nodeHitLabel.text = text
        nodeHitLabel.position = hitPosition
        nodeHitLabel.horizontalAlignmentMode = .center
        nodeHitLabel.fontSize = 24
        nodeHitLabel.zPosition = 2
        addChild(nodeHitLabel)
        
        let move = SKAction.moveBy(x: 0, y: 70, duration: 0.6)
        let fade = SKAction.fadeAlpha(to: 0, duration: 0.6)
        let wait = SKAction.wait(forDuration: 0.8)
        let remove = SKAction.removeFromParent()
        let waitForRemovalSequence = SKAction.sequence([wait, remove])
        nodeHitLabel.run(move)
        nodeHitLabel.run(fade)
        nodeHitLabel.run(waitForRemovalSequence)
    }
}
