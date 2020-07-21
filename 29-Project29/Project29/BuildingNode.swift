//
//  BuildingNode.swift
//  Project29
//
//  Created by MacBook on 26/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//
import SpriteKit
import UIKit

class BuildingNode: SKSpriteNode {
    var currentImage: UIImage!

    func setup() {
        name = "building"
        
        currentImage = drawBuilding(size: size)
        texture = SKTexture(image: currentImage)
        
        configurePhysics()
    }
    
    func configurePhysics() {
        physicsBody = SKPhysicsBody(texture: texture!, size: size)
        physicsBody?.isDynamic = false
        physicsBody?.categoryBitMask = CollisionTypes.building.rawValue
        physicsBody?.contactTestBitMask = CollisionTypes.banana.rawValue
    }
    
    func drawBuilding(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let img = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            
            let color: UIColor
            
            switch Int.random(in: 0...2) {
            case 0:
                color = UIColor(hue: 0.502, saturation: 0.98, brightness: 0.67, alpha: 1)
            case 1:
                color = UIColor(hue: 0.999, saturation: 0.99, brightness: 0.67, alpha: 1)
            default:
                color = UIColor(hue: 0, saturation: 0, brightness: 0.67, alpha: 1)
            }
            
            color.setFill()
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fill)
            
            let lightOnColor = UIColor(hue: 0.19, saturation: 0.67, brightness: 0.99, alpha: 1)
            let lightOffColor = UIColor(hue: 0, saturation: 0, brightness: 0.34, alpha: 1)
            
            // stride() function lets you loop from one number to another with a specific interval. The line below means: "count from 10 up to the height of the building minus 10, in intervals of 40." So, it will go 10, 50, 90, 130 and so on. Note that stride() has two variants - stride(from:to:by) and stride(from:through:by). The first counts up to BUT EXCLUDING the 'to' parameter, whereas the second counts up to AND including the 'through' parameter. We'll be using stride(from:to:by) below:
            for row in stride(from: 10, to: Int(size.height - 10), by: 40) {
                for col in stride(from: 10, to: Int(size.width - 10), by: 40) {
                    if Bool.random() { // this means: "if we get back 'true' randomly".
                        lightOnColor.setFill()
                    } else {
                        lightOffColor.setFill()
                    }
                    ctx.cgContext.fill(CGRect(x: col, y: row, width: 15, height: 20))
                }
            }
        }
        return img
    }
    
    func hit(at point: CGPoint) {
        let convertedPoint = CGPoint(x: point.x + size.width / 2, y: abs(point.y - (size.height / 2))) // 'abs' function means "take any negative sign and ignore it - so all numbers are positive.
        
        let renderer = UIGraphicsImageRenderer(size: size)
        let img = renderer.image { ctx in
            currentImage.draw(at: .zero) // fill the current image right in there so it looks like the existing building we have right now.
            ctx.cgContext.addEllipse(in: CGRect(x: convertedPoint.x - 32, y: convertedPoint.y - 32, width: 64, height: 64)) // the explosion chunk will be cut out exactly from the center of the ellipse.
            ctx.cgContext.setBlendMode(.clear) // destroy whatever is there already.
            ctx.cgContext.drawPath(using: .fill) // clear that texture space in the ellipse we specified.
        }
        
        texture = SKTexture(image: img)
        currentImage = img
        configurePhysics()
    }
}
