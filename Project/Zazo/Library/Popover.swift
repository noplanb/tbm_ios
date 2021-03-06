//
//  Popover.swift
//  Popover
//
//  Created by corin8823 on 8/16/15.
//  Copyright (c) 2015 corin8823. All rights reserved.
//

import UIKit

public enum PopoverOption {
  case ArrowSize(CGSize)
  case AnimationIn(NSTimeInterval)
  case AnimationOut(NSTimeInterval)
  case CornerRadius(CGFloat)
  case SideEdge(CGFloat)
  case BlackOverlayColor(UIColor)
  case OverlayBlur(UIBlurEffectStyle)
  case Type(PopoverType)
  case Color(UIColor)
}

@objc public enum PopoverType: Int {
    case Up
    case Down
}

public class Popover: UIView {

  // custom property
  public var arrowSize: CGSize = CGSize(width: 16.0, height: 10.0)
  public var animationIn: NSTimeInterval = 0.6
  public var animationOut: NSTimeInterval = 0.3
  public var cornerRadius: CGFloat = 6.0
  public var sideEdge: CGFloat = 20.0
  public var popoverType: PopoverType = .Down
  public var blackOverlayColor: UIColor = UIColor(white: 0.0, alpha: 0.2)
  public var overlayBlur: UIBlurEffect?
  public var popoverColor: UIColor = UIColor.whiteColor()

  // custom closure
  private var didShowHandler: (() -> ())?
  private var didDismissHandler: (() -> ())?

  private var blackOverlay: UIControl = UIControl()
  private var containerView: UIView!
  private var contentView: UIView!
  private var contentViewFrame: CGRect!
  private var arrowShowPoint: CGPoint!
  private let arrow = CAShapeLayer()
    
  public init() {
    super.init(frame: CGRect.zero)
    self.backgroundColor = UIColor.clearColor()
  }

  public convenience init(showHandler: (() -> ())?, dismissHandler: (() -> ())?) {
    self.init()
    self.didShowHandler = showHandler
    self.didDismissHandler = dismissHandler
  }

  public convenience init(options: [PopoverOption]?, showHandler: (() -> ())? = nil, dismissHandler: (() -> ())? = nil) {
    self.init()
    self.setOptions(options)
    self.didShowHandler = showHandler
    self.didDismissHandler = dismissHandler
  }

  private func setOptions(options: [PopoverOption]?){
    if let options = options {
      for option in options {
        switch option {
        case let .ArrowSize(value):
          self.arrowSize = value
        case let .AnimationIn(value):
          self.animationIn = value
        case let .AnimationOut(value):
          self.animationOut = value
        case let .CornerRadius(value):
          self.cornerRadius = value
        case let .SideEdge(value):
          self.sideEdge = value
        case let .BlackOverlayColor(value):
          self.blackOverlayColor = value
        case let .OverlayBlur(style):
          self.overlayBlur = UIBlurEffect(style: style)
        case let .Type(value):
          self.popoverType = value
        case let .Color(value):
          self.popoverColor = value
        }
      }
    }
  }

  required public init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func create() {
    var frame = self.contentView.frame
    frame.origin.x = self.arrowShowPoint.x - frame.size.width * 0.5

    var sideEdge: CGFloat = 0.0
    if frame.size.width < self.containerView.frame.size.width {
      sideEdge = self.sideEdge
    }

    let outerSideEdge = CGRectGetMaxX(frame) - self.containerView.bounds.size.width
    if outerSideEdge > 0 {
      frame.origin.x -= (outerSideEdge + sideEdge)
    } else {
      if CGRectGetMinX(frame) < 0 {
        frame.origin.x += abs(CGRectGetMinX(frame)) + sideEdge
      }
    }
    self.frame = frame

    let arrowPoint = self.containerView.convertPoint(self.arrowShowPoint, toView: self)
    let anchorPoint: CGPoint
    switch self.popoverType {
    case .Up:
      frame.origin.y = self.arrowShowPoint.y - frame.height - self.arrowSize.height
      anchorPoint = CGPoint(x: arrowPoint.x / frame.size.width, y: 1)
    case .Down:
      frame.origin.y = self.arrowShowPoint.y
      anchorPoint = CGPoint(x: arrowPoint.x / frame.size.width, y: 0)
    }

    let lastAnchor = self.layer.anchorPoint
    self.layer.anchorPoint = anchorPoint
    let x = self.layer.position.x + (anchorPoint.x - lastAnchor.x) * self.layer.bounds.size.width
    let y = self.layer.position.y + (anchorPoint.y - lastAnchor.y) * self.layer.bounds.size.height
    self.layer.position = CGPoint(x: x, y: y)

    self.frame = frame
    
    createArrow()
  }

  func createArrow() {
    let (path, anchorPoint) = self.popoverType.arrowPath()
    arrow.path = path.CGPath
    arrow.bounds = path.bounds
    arrow.anchorPoint = anchorPoint
    arrow.fillColor = UIColor.whiteColor().CGColor
    self.layer.addSublayer(arrow)

    arrow.position = self.containerView.convertPoint(self.arrowShowPoint, toView: self)
    
//    switch popoverType {
//    case .Up:
//      arrow.position = CGPoint(x: self.bounds.width/2, y: self.bounds.height)
//    case .Down:
//      arrow.position = CGPoint(x: self.bounds.width/2, y: -arrowSize.height)
//    }
  }
    
  public func show(contentView: UIView, fromView: UIView) {
    self.show(contentView, fromView: fromView, inView: UIApplication.sharedApplication().keyWindow!)
  }

  public func show(contentView: UIView, fromView: UIView, inView: UIView) {
    let point: CGPoint
    switch self.popoverType {
    case .Up:
        point = inView.convertPoint(CGPoint(x: fromView.frame.origin.x + (fromView.frame.size.width / 2), y: fromView.frame.origin.y), fromView: fromView.superview)
    case .Down:
        point = inView.convertPoint(CGPoint(x: fromView.frame.origin.x + (fromView.frame.size.width / 2), y: fromView.frame.origin.y + fromView.frame.size.height), fromView: fromView.superview)
    }
    self.show(contentView, point: point, inView: inView)
  }

  public func show(contentView: UIView, point: CGPoint) {
    self.show(contentView, point: point, inView: UIApplication.sharedApplication().keyWindow!)
  }

  public func show(contentView: UIView, point: CGPoint, inView: UIView) {
    self.blackOverlay.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    self.blackOverlay.frame = inView.bounds

    if let overlayBlur = self.overlayBlur {
      let effectView = UIVisualEffectView(effect: overlayBlur)
      effectView.frame = self.blackOverlay.bounds
      effectView.userInteractionEnabled = false
      self.blackOverlay.addSubview(effectView)
    } else {
      self.blackOverlay.backgroundColor = self.blackOverlayColor
      self.blackOverlay.alpha = 0
    }

    inView.addSubview(self.blackOverlay)
    self.blackOverlay.addTarget(self, action: #selector(Popover.dismiss), forControlEvents: .TouchUpInside)

    self.containerView = inView
    self.contentView = contentView
    self.contentView.backgroundColor = UIColor.clearColor()
    self.contentView.layer.cornerRadius = self.cornerRadius
    self.contentView.layer.masksToBounds = true
    self.arrowShowPoint = point
    self.show()
  }

  private func show() {
    self.setNeedsDisplay()
    switch self.popoverType {
    case .Up:
      self.contentView.frame.origin.y = 0.0
    case .Down:
      self.contentView.frame.origin.y = self.arrowSize.height
    }
    self.addSubview(self.contentView)
    self.containerView.addSubview(self)

    self.create()
    self.transform = CGAffineTransformMakeScale(0.0, 0.0)
    UIView.animateWithDuration(self.animationIn, delay: 0,
      usingSpringWithDamping: 0.7,
      initialSpringVelocity: 3,
      options: .CurveEaseInOut,
      animations: {
        self.transform = CGAffineTransformIdentity
      }){ _ in
        self.didShowHandler?()
    }
    UIView.animateWithDuration(self.animationIn / 3,
      delay: 0,
      options: .CurveLinear,
      animations: { _ in
        self.blackOverlay.alpha = 1
      }, completion: { _ in
    })
  }

  public func dismiss() {
    if self.superview != nil {
      UIView.animateWithDuration(self.animationOut, delay: 0,
        options: .CurveEaseInOut,
        animations: {
          self.transform = CGAffineTransformMakeScale(0.0001, 0.0001)
          self.blackOverlay.alpha = 0
        }){ _ in
          self.contentView.removeFromSuperview()
          self.blackOverlay.removeFromSuperview()
          self.removeFromSuperview()
          self.didDismissHandler?()
      }
    }
  }

  private func isCornerLeftArrow() -> Bool {
    return self.arrowShowPoint.x == self.frame.origin.x
  }

  private func isCornerRightArrow() -> Bool {
    return self.arrowShowPoint.x == self.frame.origin.x + self.bounds.width
  }

  private func radians(degrees: CGFloat) -> CGFloat {
    return (CGFloat(M_PI) * degrees / 180)
  }
}

extension PopoverType {
    
  func arrowPath() -> (path: UIBezierPath, anchorPoint: CGPoint) {
    
    let path = UIBezierPath()
    var point: CGPoint

    switch self {
      case .Down:
        path.moveToPoint(CGPointMake(8, 0))
        path.addLineToPoint(CGPointMake(0, 10))
        path.addLineToPoint(CGPointMake(16, 10))
        path.addLineToPoint(CGPointMake(8, 0))
        path.closePath()
        point = CGPoint(x: 0.5, y: 0)
      case .Up:
        path.moveToPoint(CGPointMake(8, 10))
        path.addLineToPoint(CGPointMake(0, 0))
        path.addLineToPoint(CGPointMake(16, 0))
        path.addLineToPoint(CGPointMake(8, 10))
        point = CGPoint(x: 0.5, y: 1)
      }
    
      return (path, point)
    }
}