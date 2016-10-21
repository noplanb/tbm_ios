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

@objc public class VideoPlayerFullscreenHelper: NSObject, UIGestureRecognizerDelegate
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
    
    var progress = CGFloat(0)
    var previousRelativeDistance = CGFloat(0)
    var relativeDistance = CGFloat(0)
    
    let recognizer = UIPanGestureRecognizer()
    
    var isFullscreen = false
    
    var isDragging: Bool
    {
        return recognizer.state != .Possible
    }
    
    var enabled = true
    {
        didSet {
            recognizer.enabled = enabled
        }
    }
    
    let view: UIView
    
    var initialFrame: CGRect {
        didSet {
            
            let screenSize = UIScreen.mainScreen().bounds.size
            
            view.frame = initialFrame
            
            let width = screenSize.width - 40
            let relation = width / initialFrame.size.width;
            
            let fullscreenSize = CGSizeMake(width, initialFrame.size.height * relation)
            
            let fullscreenOrigin = CGPointMake(screenSize.width / 2 - fullscreenSize.width / 2 + centerOffset.x,
                                               screenSize.height / 2 - fullscreenSize.height / 2 + centerOffset.y)
            
            fullscreenFrame = CGRect.init(origin: fullscreenOrigin,
                                          size: fullscreenSize)
            
            maximalDistance = distanceBetween(initialCenter, p2: fullscreenCenter)

            progress = 0
            isFullscreen = false
        }
    }
    
    var fullscreenFrame = CGRectZero
    
    public init?(view: UIView!)
    {
        guard (view != nil) else {
            return nil
        }
        
        self.view = view
        
        view.layer.masksToBounds = true
        
        initialFrame = view.frame
        
        super.init()
        
        recognizer.addTarget(self,
                             action: #selector(VideoPlayerFullscreenHelper.handleGesture(_:)))
        
        recognizer.delegate = self
        
    }
    
    @objc func handleGesture(recognizer: UIPanGestureRecognizer)
    {
        let point = recognizer.translationInView(view)
        
        switch recognizer.state
        {
            case .Changed:
                
                if previousRelativeDistance != relativeDistance
                {
                    previousRelativeDistance = relativeDistance
                }

                relativeDistance = relativeDistance(point)
                progress = progressFromDistance(relativeDistance)
                updateAppearanceForProgress(progress)

            case .Cancelled:
                
                completeAnimatedToPosition(0,
                                           velocity: 1,
                                           completion: nil)
                
            case .Ended:
                
                let speed = abs(previousRelativeDistance - relativeDistance)
                
                if previousRelativeDistance < relativeDistance
                {
                    completeAnimatedToPosition(1,
                                               velocity: speed,
                                               completion: nil)
                }
                else
                {
                    completeAnimatedToPosition(0,
                                               velocity: speed,
                                               completion: nil)
                }
                
                break
                
            default: break
        }
    }
    
    @objc public func updateFrameAndAppearance()
    {
        guard !isDragging else
        {
            return;
        }
        
        if isFullscreen
        {
            updateAppearanceForProgress(1)
        }
        else
        {
            updateAppearanceForProgress(0)
        }
    }
    
    func updateAppearanceForProgress(progress: CGFloat)
    {
//        print("progress = \(progress)")
        view.frame = frameForProgress(progress)
        view.layer.cornerRadius = 16 * progress;
    }
    
    func completeAnimatedToPosition(distance: CGFloat,
                                    velocity: CGFloat,
                                    completion: ((Bool) -> Void)?)
    {
     
        progress = self.progressFromDistance(distance)
        
        
        UIView.animateWithDuration(0.3,
                                   delay: 0,
                                   usingSpringWithDamping: 1,
                                   initialSpringVelocity: velocity,
                                   options: [.LayoutSubviews],
                                   animations: {
                                    
                                        self.updateAppearanceForProgress(self.progress)
                                        self.isFullscreen = self.view.bounds.size == self.fullscreenFrame.size
            },
                                   completion: completion)
        
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
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        
        if isFullscreen {
            return true
        }
        
        let touchPoint = touch.locationInView(view)
        let isInside = view.bounds.contains(touchPoint)
        
        return isInside
        
    }
};
