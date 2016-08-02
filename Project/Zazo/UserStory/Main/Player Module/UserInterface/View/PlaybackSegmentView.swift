//
//  PlaybackSegment.swift
//  Zazo
//
//  Created by Rinat on 18/05/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

class PlaybackSegmentView: UISlider {
    
    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        
        let height: CGFloat = 3
        
        return CGRect(x: 0,
                      y: CGRectGetMidY(bounds) - height/2,
                      width: bounds.width,
                      height: height)
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        if pointInside(point, withEvent: event)
        {
            return self
        }
        
        return nil
    }
    
    var preferredWidth = CGFloat(50) {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
   
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: preferredWidth, height: UIViewNoIntrinsicMetric)
    }
}