//
//  ViewController.swift
//  Project27
//
//  Created by MacBook on 20/06/2020.
//  Copyright © 2020 Mateusz. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet var imageView: UIImageView!
    var currentDrawType = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        drawRectangle()
    }

  
    @IBAction func redrawTapped(_ sender: Any) {
        currentDrawType += 1
        if currentDrawType > 7 {
            currentDrawType = 0
        }
        
        switch currentDrawType {
        case 0:
            drawRectangle()
            
        case 1:
            drawCircle()
            
        case 2:
            drawCheckerboard()
            
        case 3:
            drawRotatedSquares()
            
        case 4:
            drawLines()
            
        case 5:
            drawImagesAndText()
            
        case 6:
            drawStar()
            
        case 7:
            drawTwin()
            
        default:
            break
        }
    }
    
    
    func drawRectangle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // we make a canvas 512x512, ready for drawing.
        
        let image = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512) // for some reason, an inset has to be set with 'dy:', as without it, there are no black edges at the top and bottom edges.
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addRect(rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image // put that rendered image into our wide imageView on our UIView.
    }
    
    func drawCircle() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // we make a canvas 512x512, ready for drawing.
        
        let image = renderer.image { ctx in
            let rectangle = CGRect(x: 0, y: 0, width: 512, height: 512).insetBy(dx: 5, dy: 5) // we make the inset to avoid clipping of the circle.
            
            ctx.cgContext.setFillColor(UIColor.red.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.setLineWidth(10)
            
            ctx.cgContext.addEllipse(in: rectangle)
            ctx.cgContext.drawPath(using: .fillStroke)
        }
        
        imageView.image = image // put that rendered image into our wide imageView on our UIView.
    }
    
    func drawCheckerboard() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // we make a canvas 512x512, ready for drawing.
        
        let image = renderer.image { ctx in
            ctx.cgContext.setFillColor(UIColor.black.cgColor)
            
            for row in 0 ..< 8 {
                for col in 0 ..< 8 {
                    if (row + col) % 2 == 0 {
                        ctx.cgContext.fill(CGRect(x: col * 64, y: row * 64, width: 64, height: 64))
                    }
                }
            }
        }
        
        imageView.image = image // put that rendered image into our wide imageView on our UIView.
    }
    
    func drawRotatedSquares() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // we make a canvas 512x512, ready for drawing.
        
        let image = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256) // setting the x and y of the drawn square in the centre of the view.
            
            let rotations = 16
            let amount = Double.pi / Double(rotations)
            
            for _ in 0...rotations {
                // setting the square top and left coordinates to -128, with width and height of 256, rotating each square by pi/16
                ctx.cgContext.rotate(by: CGFloat(amount))
                ctx.cgContext.addRect(CGRect(x: -128, y: -128, width: 256, height: 256))
            }
            
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        
        imageView.image = image // put that rendered image into our wide imageView on our UIView.
    }
    
    func drawLines() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // we make a canvas 512x512, ready for drawing.
        
        let image = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 256) // drawing from the center of our canvas.
            
            var first = true
            var length: CGFloat = 256
            
            for _ in 0 ..< 256 {
                ctx.cgContext.rotate(by: .pi / 2)
                
                if first {
                    ctx.cgContext.move(to: CGPoint(x: length, y: 50))
                    first = false
                } else {
                    ctx.cgContext.addLine(to: CGPoint(x: length, y: 50))
                }
                
                length *= 0.99 // decrease the length for each loop instance

            }
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
            ctx.cgContext.strokePath()
        }
        imageView.image = image // put that rendered image into our wide imageView on our UIView.
    }
    
    func drawImagesAndText() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // we make a canvas 512x512, ready for drawing.
        
        let image = renderer.image { ctx in
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attrs: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 36),
                .paragraphStyle: paragraphStyle
            ]
            
            let string = "The best-laid schemes o'\nmice an' men aft agley"
            
            let attributedString = NSAttributedString(string: string, attributes: attrs)
            
            attributedString.draw(with: CGRect(x: 32, y: 32, width: 448, height: 448), options: .usesLineFragmentOrigin, context: nil)
            
            let mouse = UIImage(named: "mouse")
            mouse?.draw(at: CGPoint(x: 300, y: 150))
        }
        
        imageView.image = image // put that rendered image into our wide imageView on our UIView.
    }
    
    func drawStar() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // we make a canvas 512x512, ready for drawing.
            
        let image = renderer.image { ctx in
            ctx.cgContext.translateBy(x: 256, y: 0)
            ctx.cgContext.setFillColor(UIColor.systemYellow.cgColor)

            //top triangle:
            ctx.cgContext.move(to: CGPoint(x: 0, y: 0))
            ctx.cgContext.addLine(to: CGPoint(x: -96, y: 256))
            ctx.cgContext.addLine(to: CGPoint(x: 96, y: 256))
            ctx.cgContext.closePath()
            ctx.cgContext.drawPath(using: .fill)

            //medium triangle left:
             ctx.cgContext.move(to: CGPoint(x: -256, y: 192))
             ctx.cgContext.addLine(to: CGPoint(x: 0, y: 180))
             ctx.cgContext.addLine(to: CGPoint(x: 0, y: 384))
             ctx.cgContext.closePath()
             ctx.cgContext.drawPath(using: .fill)

            // bottom triangle left:
             ctx.cgContext.move(to: CGPoint(x: -256, y: 512))
             ctx.cgContext.addLine(to: CGPoint(x: 0, y: 128))
             ctx.cgContext.addLine(to: CGPoint(x: 0, y: 384))
             ctx.cgContext.closePath()
             ctx.cgContext.drawPath(using: .fill)

            //bottom triangle right:
            ctx.cgContext.move(to: CGPoint(x: 256, y: 512))
            ctx.cgContext.addLine(to: CGPoint(x: 0, y: 128))
            ctx.cgContext.addLine(to: CGPoint(x: 0, y: 384))
            ctx.cgContext.closePath()
            ctx.cgContext.drawPath(using: .fill)

            
            //medium triangle right:
             ctx.cgContext.move(to: CGPoint(x: 256, y: 192))
             ctx.cgContext.addLine(to: CGPoint(x: 0, y: 180))
             ctx.cgContext.addLine(to: CGPoint(x: 0, y: 384))
             ctx.cgContext.closePath()
             ctx.cgContext.drawPath(using: .fill)
        }
        imageView.image = image // put that rendered image into our wide imageView on our UIView.
    }
    
    func drawTwin() {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512)) // we make a canvas 512x512, ready for drawing.
                
            let image = renderer.image { ctx in
                ctx.cgContext.setStrokeColor(UIColor.black.cgColor)
                ctx.cgContext.setLineWidth(10)

                //letter T:
                ctx.cgContext.move(to: CGPoint(x: 30, y: 55))
                ctx.cgContext.addLine(to: CGPoint(x: 131, y: 55))
                
                ctx.cgContext.move(to: CGPoint(x: 81, y: 50))
                ctx.cgContext.addLine(to: CGPoint(x: 81, y: 462))

                ctx.cgContext.drawPath(using: .stroke)

                //letter W:
                ctx.cgContext.move(to: CGPoint(x: 151, y: 50))
                ctx.cgContext.addLine(to: CGPoint(x: 151, y: 462))
                
                ctx.cgContext.move(to: CGPoint(x: 151, y: 462))
                ctx.cgContext.addLine(to: CGPoint(x: 202, y: 300))
                
                ctx.cgContext.move(to: CGPoint(x: 202, y: 300))
                ctx.cgContext.addLine(to: CGPoint(x: 252, y: 462))
                
                ctx.cgContext.move(to: CGPoint(x: 252, y: 462))
                ctx.cgContext.addLine(to: CGPoint(x: 252, y: 50))
                
                ctx.cgContext.drawPath(using: .stroke)
                
                // letter I:
                ctx.cgContext.move(to: CGPoint(x: 323, y: 50))
                ctx.cgContext.addLine(to: CGPoint(x: 323, y: 462))
                
                ctx.cgContext.drawPath(using: .stroke)

                // letter N:
                ctx.cgContext.move(to: CGPoint(x: 393, y: 50))
                ctx.cgContext.addLine(to: CGPoint(x: 393, y: 462))
                
                ctx.cgContext.move(to: CGPoint(x: 393, y: 50))
                ctx.cgContext.addLine(to: CGPoint(x: 494, y: 462))
                
                ctx.cgContext.move(to: CGPoint(x: 494, y: 462))
                ctx.cgContext.addLine(to: CGPoint(x: 494, y: 50))

                ctx.cgContext.drawPath(using: .stroke)
            }
            imageView.image = image // put that rendered image into our wide imageView on our UIView.
    }
}

