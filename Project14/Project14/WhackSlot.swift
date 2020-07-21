//
//  WhackSlot.swift
//  Project14
//
//  Created by MacBook on 17/05/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//
import SpriteKit
import UIKit

class WhackSlot: SKNode {
    var charNode: SKSpriteNode!
    
    var isVisible = false
    var isHit = false
    
    func configure(at position: CGPoint) {
        self.position = position
        
        let sprite = SKSpriteNode(imageNamed: "whackHole")
        addChild(sprite)
    
        let cropNode = SKCropNode()
        cropNode.position = CGPoint(x: 0, y: 15)
        cropNode.zPosition = 1
        cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
        
        charNode = SKSpriteNode(imageNamed: "penguinGood")
        charNode.position = CGPoint(x: 0, y: -90)
        charNode.name = "character"
        cropNode.addChild(charNode) // The charNode (character node) is added to cropNode, not to the WhackSlot directly. It's inside the cropNode, and cropNode is added to WhackSlot. Because charNode is below the cropNode, it's not visible until it moves up, being revealed by cropNode.
        
        addChild(cropNode)
    }
    
    func show(hideTime: Double) {
        
        if isVisible { return }
        
        charNode.xScale = 1 // we set the scale of the character back to 1, because in the GameScene we set it to 0.85 when hit.
        charNode.yScale = 1
        
        charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05)) // Move the penguin up by 80 points, with the duration of 0.05s.
        isVisible = true
        isHit = false
        // There will be 1/3 chance for good penguin to appear:
        if Int.random(in: 0...2) == 0 {
            charNode.texture = SKTexture(imageNamed: "penguinGood")
            charNode.name = "charFriend"
        } else {
            charNode.texture = SKTexture(imageNamed: "penguinEvil")
            charNode.name = "charEnemy"
        }
        if let mudParticles = SKEmitterNode(fileNamed: "MudPartic") {
        mudParticles.position = CGPoint(x: 0, y: -20)
        addChild(mudParticles)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + (hideTime * 3.5)) { [weak self] in
            self?.hide()
        } // because hideTime = popupTime in the GameScene, the characters now will hide after popuptime * 3.5 duration.
    }
    
    func hide() {
        if !isVisible { return }
        if let mudParticles = SKEmitterNode(fileNamed: "MudPartic") {
        mudParticles.position = charNode.position
        addChild(mudParticles)
        }
        charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
        isVisible = false
    }
    
    func hit() {
        isHit = true
        
        let delay = SKAction.wait(forDuration: 0.25)
        let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.5)
        let notVisible = SKAction.run { [weak self] in
            self?.isVisible = false
        }
        let sequence = SKAction.sequence([delay, hide, notVisible])
        charNode.run(sequence)
    }
    
}
