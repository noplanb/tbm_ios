//
//  PlaybackSegment.swift
//  Zazo
//
//  Created by Rinat on 18/05/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

class PlaybackSegment: UISlider {
    
    override func trackRectForBounds(bounds: CGRect) -> CGRect {
        
        let height: CGFloat = 3
        
        return CGRect(x: 0,
                      y: CGRectGetMidY(bounds) - height/2,
                      width: bounds.width,
                      height: height)
    }
}