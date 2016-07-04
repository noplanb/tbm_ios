//
//  FadingScrollView.swift
//  Zazo
//
//  Created by Rinat on 04/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public class FadingView: UIView {
    
    convenience init() {
        
        self.init(frame: CGRect.zero)
    }
    
    override public func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.layer.mask = makeMask()
        
        
    }
    
    func makeMask() -> CALayer {
        
        let fadingAreaHeight = CGFloat(20)
        
        let layer = CAGradientLayer()
        
        // Frame 
        
        let outerMargin = CGFloat(16)
        var frame = self.layer.bounds
        frame.origin.x -= 16
        frame.size.width += outerMargin * 2
        frame.size.height += outerMargin
        
        layer.frame = frame
        
        // Colors
        
        let transparent = UIColor.clearColor().CGColor
        let black = UIColor.blackColor().CGColor
        layer.colors = [transparent, black, black]
        
        // Locations
        
        let relativeContentTop = fadingAreaHeight / self.layer.frame.height
        layer.locations = [0, relativeContentTop, 1]
        
        return layer
    }
}