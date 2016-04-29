//
//  DownloadingView.swift
//  Zazo
//
//  Created by Rinat on 29/04/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import UIKit

func delay(delay:Double, closure:()->()) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}

public class DownloadingLayer: CALayer
{
    var backCircle = CAShapeLayer()
    var animatingProgressLayer = CAShapeLayer()
    var arrowLayer = CAShapeLayer()
    var basementLayer = CAShapeLayer()
    var whiteCircle = CAShapeLayer()
    
    let circleLineWidth: CGFloat = 3
    
    override init() {
        
        super.init()
        
        addSublayer(whiteCircle)
        addSublayer(backCircle)
        addSublayer(animatingProgressLayer)
        addSublayer(arrowLayer)
        addSublayer(basementLayer)
        
        whiteCircle.fillColor = UIColor.whiteColor().CGColor
        
        backCircle.fillColor = UIColor.clearColor().CGColor
        backCircle.lineWidth = circleLineWidth
        
        animatingProgressLayer.fillColor = UIColor.clearColor().CGColor
        animatingProgressLayer.lineWidth = circleLineWidth
        animatingProgressLayer.strokeEnd = 0
        
        let arrow = arrowPath()
        arrowLayer.path = arrow.CGPath
        arrowLayer.frame = arrow.bounds
        arrowLayer.anchorPoint = CGPointMake(0.5, 0)
        arrowLayer.position = CGPointMake(32, 13)
        arrowLayer.masksToBounds = true
        
        let basement = basementPath()
        basementLayer.path = basement.CGPath
        basementLayer.frame = basement.bounds
        basementLayer.anchorPoint = CGPointMake(0.5, 0)
        basementLayer.position = CGPointMake(32, 13)
    }
    
    public var baseColor = UIColor.blackColor() {
        didSet {
            backCircle.strokeColor = baseColor.colorWithAlphaComponent(0.3).CGColor
            animatingProgressLayer.strokeColor = baseColor.CGColor
            arrowLayer.fillColor = baseColor.CGColor
            basementLayer.fillColor = baseColor.CGColor
        }
    }
    
    public override func layoutSublayers() {
        super.layoutSublayers()
        
        backCircle.frame = bounds
        backCircle.path = circlePath().CGPath
        
        animatingProgressLayer.frame = bounds
        animatingProgressLayer.path = circlePath().CGPath
        
        whiteCircle.path = UIBezierPath(ovalInRect: bounds).CGPath
        whiteCircle.frame = bounds

    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func circlePath() -> UIBezierPath {
        let rect = CGRectInset(self.bounds, circleLineWidth*1.5, circleLineWidth*1.5)
        
        return UIBezierPath(ovalInRect: rect)
    }
    
    func arrowPath() -> UIBezierPath {
        
        let bezierPath = UIBezierPath()
        bezierPath.moveToPoint(CGPointMake(8.12, -0))
        bezierPath.addLineToPoint(CGPointMake(20.88, -0))
        bezierPath.addLineToPoint(CGPointMake(20.88, 12.25))
        bezierPath.addLineToPoint(CGPointMake(29, 12.25))
        bezierPath.addLineToPoint(CGPointMake(14.5, 26.83))
        bezierPath.addLineToPoint(CGPointMake(0, 12.25))
        bezierPath.addLineToPoint(CGPointMake(8.12, 12.25))
        
        return bezierPath
    }
    
    func basementPath() -> UIBezierPath {
        let bezier2Path = UIBezierPath()
        bezier2Path.moveToPoint(CGPointMake(0, 30.92))
        bezier2Path.addLineToPoint(CGPointMake(29, 30.92))
        bezier2Path.addLineToPoint(CGPointMake(29, 35))
        bezier2Path.addLineToPoint(CGPointMake(0, 35))
        
        return bezier2Path
    }
}

public class DownloadingView: UIView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        backgroundColor = UIColor.clearColor()
        self.downloadingLayer.baseColor = self.tintColor
    }
    
    public var downloadingLayer: DownloadingLayer {
        return self.layer as! DownloadingLayer
    }
    
    public override class func layerClass() -> AnyClass {
        return DownloadingLayer.self;
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var done = 0.0 {
        didSet {
            self.downloadingLayer.animatingProgressLayer.strokeEnd = CGFloat(done)
        }
    }
    
    public func startAnimating() {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = M_PI * 2.0
        animation.duration = 2
        animation.repeatCount = Float.infinity
        animation.cumulative = true
        
        self.downloadingLayer.animatingProgressLayer.addAnimation(animation, forKey: "animating ProgressLayer")
        
        self.done = 0.1
    }
    
    public func finishAnimating(closure:()->()) {
        
        var frame = downloadingLayer.arrowLayer.frame
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.35)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
        
        downloadingLayer.arrowLayer.transform =
            CATransform3DTranslate(downloadingLayer.transform, 0, frame.height + 5, 1)
        
        CATransaction.commit()
        
        delay(0.085) {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.265)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear))
            CATransaction.setCompletionBlock({
                closure()
            })
            
            frame.size.height = 0
            self.downloadingLayer.arrowLayer.frame = frame
            
            CATransaction.commit()
            
        }
    }
    
    override public func intrinsicContentSize() -> CGSize {
        return CGSizeMake(64, 64)
    }
}
