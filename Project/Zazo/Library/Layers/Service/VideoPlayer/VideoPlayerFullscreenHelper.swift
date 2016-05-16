//
//  VideoPlayerFullscreenHelper.swift
//  Zazo
//
//  Created by Rinat on 11/05/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit


@objc public class VideoPlayerFullscreenHelper: NSObject
{
    public var centerOffset = CGPoint.init(x: 0, y: -20)
    
    var maximalDistance: CGFloat = 0
    
    var fullscreenCenter: CGPoint
    {
        get {
            return CGPoint.init(x: CGRectGetMidX(fullscreenFrame),
                                y: CGRectGetMidY(fullscreenFrame))
        }
    }
    
    var initialCenter: CGPoint
    {
        get {
            return CGPoint.init(x: CGRectGetMidX(initialFrame),
                                y: CGRectGetMidY(initialFrame))
        }
    }
    
    var previousRelativeDistance = CGFloat(0)
    var relativeDistance = CGFloat(0)
    
    let view: UIView
    
    var initialFrame = CGRectZero
    var fullscreenFrame = CGRectZero
    
    var isFullscreen = false
    {
        didSet {
            print("fullscreeen = \(isFullscreen)" )
        }
    }
    
    public init?(view: UIView!)
    {
        guard (view != nil) else {
            return nil
        }
        
        self.view = view
        
        view.layer.masksToBounds = true
        
        super.init()
        
        let recognizer = UIPanGestureRecognizer.init(target: self,
                                                     action: #selector(VideoPlayerFullscreenHelper.handleGesture(_:)))
        
        view.addGestureRecognizer(recognizer)
    }
    
    public func prepare()
    {
        isFullscreen = view.bounds.size == fullscreenFrame.size
        
        guard (!isFullscreen) else
        {
            return
        }
        
        let screenSize = UIScreen.mainScreen().bounds.size

        initialFrame = view.frame
        
        let width = screenSize.width - 40
        let relation = width / initialFrame.size.width;
        
        let fullscreenSize = CGSizeMake(width, initialFrame.size.height * relation)
        
        let fullscreenOrigin = CGPointMake(screenSize.width / 2 - fullscreenSize.width / 2 + centerOffset.x,
                                           screenSize.height / 2 - fullscreenSize.height / 2 + centerOffset.y)

        fullscreenFrame = CGRect.init(origin: fullscreenOrigin,
                                      size: fullscreenSize)
        
        maximalDistance = distanceBetween(initialCenter, p2: fullscreenCenter)

    }
    
    @objc func handleGesture(recognizer: UIPanGestureRecognizer)
    {
        let point = recognizer.translationInView(view)
        
        switch recognizer.state {
            
        case .Began:
            prepare()
            
        case .Changed:
            
            if previousRelativeDistance != relativeDistance
            {
                previousRelativeDistance = relativeDistance
                
//                print("previousRelativeDistance = \(previousRelativeDistance) relDistance =  \(relativeDistance)")
            }

            relativeDistance = relativeDistance(point)
            let progress = progressFromDistance(relativeDistance)
            self.view.frame = frameForProgress(progress)
            
            updateAppearanceForProgress(progress)
        
        case .Cancelled:
            completeAnimatedToPosition(0, velocity: 1)
            
        case .Ended:
            
            let speed = abs(previousRelativeDistance - relativeDistance)
            
            if previousRelativeDistance < relativeDistance
            {
                completeAnimatedToPosition(1, velocity: speed)
            }
            else
            {
                completeAnimatedToPosition(0, velocity: speed)
            }
            
            break
            
        default: break
        
        }

    }
    
    func updateAppearanceForProgress(progress: CGFloat)
    {
//        print("progress = \(progress)")
        
        self.view.layer.cornerRadius = 16 * progress;
        
    }
    
    func completeAnimatedToPosition(distance: CGFloat, velocity: CGFloat)
    {
     
        let progress = self.progressFromDistance(distance)
        
        
        UIView.animateWithDuration(0.3,
                                   delay: 0,
                                   usingSpringWithDamping: 0.75,
                                   initialSpringVelocity: velocity,
                                   options: [.LayoutSubviews],
                                   animations: {
                                    
                                        self.updateAppearanceForProgress(progress)
                                        self.view.frame = self.frameForProgress(progress)
            },
                                   completion: nil)
        
    }
    
    func progressFromDistance(distance: CGFloat) -> CGFloat
    {
        if isFullscreen
        {
            return distance
        }
        else
        {
            return 1 - distance
        }
    }
    
    func frameForProgress(progress: CGFloat) -> CGRect {
        
        let deltaWidth = fullscreenFrame.size.width - initialFrame.size.width
        let deltaHeight = fullscreenFrame.size.height - initialFrame.size.height
        
        let currentSize = CGSizeMake(deltaWidth * progress + initialFrame.size.width,
                                     deltaHeight * progress + initialFrame.size.height)

        let deltaX = fullscreenFrame.origin.x - initialFrame.origin.x
        let deltaY = fullscreenFrame.origin.y - initialFrame.origin.y
        
        let currentPoint = CGPointMake(initialFrame.origin.x + deltaX * progress,
                                       initialFrame.origin.y + deltaY * progress)
        
        return CGRect.init(origin: currentPoint,
                           size: currentSize)
    }
    
    func relativeDistance(fromPoint: CGPoint) -> CGFloat
    {
        let translatedPoint = CGPoint.init(x: fromPoint.x + initialFrame.origin.x,
                                           y: fromPoint.y + initialFrame.origin.y)
        
        
        let centerPoint = CGPointMake(translatedPoint.x + initialFrame.size.width / 2,
                                      translatedPoint.y + initialFrame.size.height / 2)
        
        
        let distanceToFullscreen    = distanceBetween(centerPoint, p2: fullscreenCenter)
        let distanceToOrigin        = distanceBetween(centerPoint, p2: initialCenter)
        
        var relativeDistance: CGFloat
        
        if isFullscreen
        {
            relativeDistance = 2 - distanceToFullscreen / maximalDistance
        }
        else
        {
            relativeDistance = (maximalDistance - distanceToOrigin) / maximalDistance
        }
        
        if relativeDistance < 0
        {
            relativeDistance = 0
        }
        
        if relativeDistance > 1
        {
            relativeDistance = 1
        }
        
//        print("maximalDistance = \(maximalDistance)")
//        print("distanceToFullscreen = \(distanceToFullscreen)")
//        print("distanceToOrigin = \(distanceToOrigin)")
//        print("rel = \(relativeDistance)")
        
        return relativeDistance
    }
    
    func distanceBetween(p1: CGPoint, p2: CGPoint) -> CGFloat
    {
        return hypot(p1.x - p2.x,
                     p1.y - p2.y)
    }
};