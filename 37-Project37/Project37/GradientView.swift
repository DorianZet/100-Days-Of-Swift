//
//  GradientView.swift
//  Project37
//
//  Created by Mateusz Zacharski on 23/07/2020.
//  Copyright © 2020 Mateusz Zacharski. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView { // @IBDesignable means that Xcode should build the class and make it draw inside Interface Builder whenever changes are made. This means any custom drawing you do will be reflected inside Interface Builder.
    @IBInspectable var topColor: UIColor = UIColor.white // @IBInspectable makes a property from our class an editable value inside Interface Builder. Strings will have an editable text box, booleans will have a checkbox, and colors will have a color selection palette.
    @IBInspectable var bottomColor: UIColor = UIColor.black
    
    // When iOS asks what kind of layer to use for drawing, it should return CAGradientLayer:
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    // When iOS tells the view to layout its subviews, it should apply the colors to the gradient:
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
    }
    
}
