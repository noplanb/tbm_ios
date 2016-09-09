//
//  CropViewOverlayLayer.swift
//  Zazo
//
//  Created by Rinat on 09/09/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation


class CropOverlayLayer: CALayer {
    
    var cropSize = CGSize(width: 300, height: 450)
    var avatarRadius = CGFloat(100)
    var avatarLabelWidth = CGFloat(120)
    var cellLabelWidth = CGFloat(100)
    let labelsHeight = CGFloat(24)
    
    let cellAreaLabelText = "CELL AREA"
    let avatarAreaLabelText = "AVATAR AREA"
    
    
    let outerOverlayColor: CGColor = UIColor.blackColor().colorWithAlphaComponent(0.5).CGColor
    
    let backgroundLayer = CAShapeLayer()
    let cellBorderLayer = CAShapeLayer()
    let cellBorderMaskLayer = CAShapeLayer()
    let avatarBorderLayer = CAShapeLayer()
    let cellLabelBackground = CALayer()
    let avatarLabelBackground = CALayer()
    let cellLabel = CATextLayer()
    let avatarLabel = CATextLayer()
    
    override init() {
        super.init()
        self.backgroundColor = UIColor.clearColor().CGColor
        
        addSublayer(backgroundLayer)
        backgroundLayer.fillColor = outerOverlayColor
        backgroundLayer.fillRule = kCAFillRuleEvenOdd
        
        addSublayer(cellBorderLayer)
        cellBorderLayer.fillColor = nil
        cellBorderLayer.strokeColor = UIColor.whiteColor().CGColor
        cellBorderLayer.lineWidth = 2
        
        addSublayer(avatarBorderLayer)
        avatarBorderLayer.fillColor = nil
        avatarBorderLayer.strokeColor = UIColor.whiteColor().CGColor
        avatarBorderLayer.lineWidth = 2
        
        cellBorderMaskLayer.fillColor = UIColor.redColor().CGColor
        cellBorderMaskLayer.fillRule = kCAFillRuleEvenOdd
        cellBorderLayer.mask = cellBorderMaskLayer
        
        addSublayer(cellLabelBackground)
        cellLabelBackground.backgroundColor = UIColor.blueColor().CGColor
        cellLabelBackground.cornerRadius = labelsHeight/2
        
        addSublayer(avatarLabelBackground)
        avatarLabelBackground.backgroundColor = UIColor.blueColor().CGColor
        avatarLabelBackground.cornerRadius = labelsHeight/2
        
        addSublayer(cellLabel)
        cellLabel.string = attributedString(from: cellAreaLabelText)
        cellLabel.alignmentMode = kCAAlignmentCenter
        cellLabel.contentsScale = UIScreen.mainScreen().scale
        
        addSublayer(avatarLabel)
        avatarLabel.string = attributedString(from: avatarAreaLabelText)
        avatarLabel.alignmentMode = kCAAlignmentCenter
        avatarLabel.contentsScale = UIScreen.mainScreen().scale
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        
        let cellRect = CGRect(center: bounds.center, size: cropSize)
        let cellPath = UIBezierPath(roundedRect: cellRect, cornerRadius: 18)
        
        let maskedPath = UIBezierPath(rect: bounds)
        maskedPath.appendPath(cellPath)
        maskedPath.usesEvenOddFillRule = true
        backgroundLayer.path = maskedPath.CGPath
        backgroundLayer.frame = bounds
        
        cellBorderLayer.path = cellPath.CGPath
        
        let r2 = avatarRadius * avatarRadius
        let l = avatarLabelWidth * avatarLabelWidth
        let r = (r2 + r2 - l) / (2 * r2)
        let excludeRadius = acos(r)
        
        let avatarAreaPath =
            UIBezierPath(arcCenter: bounds.center,
                         radius: avatarRadius,
                         startAngle: CGFloat(M_PI_2) + excludeRadius/2,
                         endAngle:  CGFloat(M_PI_2) - excludeRadius/2 ,
                         clockwise: true)
        
        avatarBorderLayer.path = avatarAreaPath.CGPath
        
        let cellTitleCenter = CGPoint(x: bounds.center.x,
                                      y: cellRect.maxY)
        let cellTitleSize = CGSize(width: cellLabelWidth, height: labelsHeight)
        var cellTitleRect = CGRect(center: cellTitleCenter,
                                   size: cellTitleSize)
        
        let cellTitlePath = UIBezierPath(roundedRect: cellTitleRect, cornerRadius: 0)
        let maskedCellPath = UIBezierPath(rect: bounds)
        maskedCellPath.appendPath(cellTitlePath)
        maskedCellPath.usesEvenOddFillRule = true
        cellBorderMaskLayer.path = maskedCellPath.CGPath
        
        cellTitleRect.insetInPlace(dx: 6, dy: 0)
        cellLabelBackground.frame = cellTitleRect
        cellTitleRect.offsetInPlace(dx: 0, dy: 5)
        cellLabel.frame = cellTitleRect
        
        let avatarTitleRectCenter = CGPoint(x: bounds.center.x, y: bounds.center.y + avatarRadius - labelsHeight/2)
        var avatarTitleRect = CGRect(center: avatarTitleRectCenter, size: CGSize(width: avatarLabelWidth, height: labelsHeight))
        avatarTitleRect.insetInPlace(dx: 6, dy: 0)
        
        avatarLabelBackground.frame = avatarTitleRect
        avatarTitleRect.offsetInPlace(dx: 0, dy: 5)
        avatarLabel.frame = avatarTitleRect
    }
    
    func attributedString(from string: String) -> NSAttributedString {
        
        let attributes: [String: AnyObject] = [
            NSFontAttributeName: UIFont.boldSystemFontOfSize(11),
            NSKernAttributeName: 1.2,
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            ]
        
        let result = NSAttributedString(string: string, attributes: attributes)
        return result
    }
}

extension CGRect {
    
    init(center: CGPoint, size: CGSize) {
        self = CGRect(origin: CGPoint.zero, size: size)
        self.center = center
    }
    
    var center: CGPoint {
        get {
            return CGPoint(x: self.midX, y: self.midY)
        }
        set {
            origin = CGPointMake(newValue.x - size.width/2, newValue.y - size.height/2)
        }
    }
}

class CropOverlayView: UIView {
    
    var overlayLayer: CropOverlayLayer {
        return layer as! CropOverlayLayer
    }
    
    override class func layerClass() -> AnyClass {
        return CropOverlayLayer.self
    }
}
