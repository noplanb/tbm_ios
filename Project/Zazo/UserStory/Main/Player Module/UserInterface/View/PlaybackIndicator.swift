//
//  PlaybackIndicator.swift
//  Zazo
//
//  Created by Rinat on 15/05/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import OAStackView
import SnapKit

public struct PlaybackIndicatorTheme {
    
    let bodyColor: UIColor
    let textColor: UIColor
    
    static let defaultTheme =
        PlaybackIndicatorTheme(bodyColor: ZZColorTheme.shared().tintColor,
                               textColor: UIColor.whiteColor())
    
    static let invertedTheme =
        PlaybackIndicatorTheme(bodyColor: UIColor.whiteColor(),
                               textColor: ZZColorTheme.shared().tintColor)
}

@objc public protocol PlaybackIndicatorDelegate: class
{
    func didStartDragging()
    func didFinishDragging()
    func didSeekToPosition(position: CGFloat, ofSegmentWithIndex: Int)
}

public class PlaybackIndicator: UIView
{
    let emptySegmentPositionImage = UIImage()
    
    @objc public var invertedColorTheme = false {
        didSet {
            if oldValue != invertedColorTheme {
                colorTheme = invertedColorTheme ? PlaybackIndicatorTheme.invertedTheme : PlaybackIndicatorTheme.defaultTheme
            }
        }
    }
    
    public var colorTheme = PlaybackIndicatorTheme.defaultTheme {
        didSet {
            
            UIView.performWithoutAnimation {
                
                let count = self.segmentCount
                self.segmentCount = 0 // in order to redraw segments
                self.segmentCount = count
            }
        }
    }
    
    @objc public weak var delegate: PlaybackIndicatorDelegate?
    
    @objc public var segmentCount: Int = 1 {
        didSet {
            updateSegmentCountTo(segmentCount)
            currentSegment = 0
            previousSegment = nil
        }
    }
    
    @objc public var currentSegment: Int = 0 {
                
        didSet {
            
            guard oldValue != currentSegment else
            {
                return
            }
            
            if let segment = segmentAtIndex(oldValue)
            {
                segment.setThumbImage(emptySegmentPositionImage, forState: .Normal)
                
//                print("thumb cleared for \(currentSegment)")
            }
       
        }
    }
    
    var segmentProgressChangesToIgnore = 0 // hack to ignore incorrect values from AVPlayer
    
    @objc public var segmentProgress: Float = 0 {
        didSet {
            
            guard let segment = segmentAtIndex(currentSegment) else
            {
                return
            }
            
            segment.value = segmentProgress
            
//            print(segmentProgress)

            if (segmentProgressChangesToIgnore > 0)
            {
                segmentProgressChangesToIgnore -= 1
            }
            else
            {

                if segment.thumbImageForState(.Normal) == emptySegmentPositionImage
                {
                    let badgeNumber = currentSegment + Int(1)
                    let image = ZZBadgeIndicator.renderWithNumber(badgeNumber ,
                                                                  fontColor: colorTheme.textColor,
                                                                  backgroundColor: colorTheme.bodyColor)
                    
                    segment.setThumbImage(image, forState: .Normal)
                    
//                    print("thumb set for \(currentSegment)")
                }
            }

        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.tintColor = ZZColorTheme.shared().tintColor
        
        let panRecognizer = UIPanGestureRecognizer(target: self,
                                                   action: #selector(dragWithRecognizer))
        
        panRecognizer.delegate = self
        
        addGestureRecognizer(panRecognizer)

        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(tapWithRecognizer))
        addGestureRecognizer(recognizer)

    }
    
    convenience init() {
        self.init(frame: CGRectZero)
    }
    
    func updateSegmentCountTo(segmentCount: Int)
    {        
        if segmentCount < stackView.arrangedSubviews.count
        {
            
            let count = stackView.arrangedSubviews.count - segmentCount
            
            for _ in 0..<count
            {
                stackView.removeArrangedSubview(stackView.arrangedSubviews.last!)
            }
            
        }
            
        else if segmentCount > stackView.arrangedSubviews.count
        {
            let count = segmentCount - stackView.arrangedSubviews.count
            
            for _ in 0..<count
            {
                stackView.addArrangedSubview(makeSegment())
            }
        }
             
        UIView.animateWithDuration(0.25)
        {
            self.layoutIfNeeded()
        }
    }
    
    override public func intrinsicContentSize() -> CGSize {
        return CGSize(width: UIViewNoIntrinsicMetric, height: 23)
    }

    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var stackView: OAStackView = {
        let result = OAStackView()

        result.spacing = 10
        result.distribution = .FillEqually
        self.addSubview(result)
        
        result.snp_makeConstraints { make in
           make.edges.equalTo(self)
        }
    
        return result;
    }()
    
    func makeSegment() -> UIView
    {
        let segment = PlaybackSegment()
        
        segment.backgroundColor = UIColor.clearColor()
        segment.exclusiveTouch = true
        segment.minimumTrackTintColor = self.colorTheme.bodyColor
        segment.maximumTrackTintColor = self.colorTheme.bodyColor
        segment.userInteractionEnabled = false
        segment.setThumbImage(emptySegmentPositionImage, forState: .Normal)
        segment.translatesAutoresizingMaskIntoConstraints = false
        
        return segment
    }
    
    var previousSegment: UISlider?    
    
    @objc func dragWithRecognizer(recognizer: UIPanGestureRecognizer)
    {
        switch recognizer.state
        {
            case .Began:
                didStartDragging()
            case .Cancelled, .Ended:
                didFinishDragging()
            default:
                break
        }
        
        handleTouchAtPoint(recognizer.locationInView(self))
    }
    
    @objc func tapWithRecognizer(recognizer: UITapGestureRecognizer)
    {
        segmentProgressChangesToIgnore = 4
        
        didStartDragging()
        handleTouchAtPoint(recognizer.locationInView(self))
        didFinishDragging()
    }
    
    func handleTouchAtPoint(aPoint: CGPoint)
    {
        var point = aPoint
        
        point.y = self.bounds.height / 2
        
        let view = self.hitTest(point, withEvent: nil)
        
        guard let segment = view as? PlaybackSegment else
        {
            return
        }
        
        let pointOnSegment = segment.convertPoint(point, fromView: self)
        
        let relativePosition = pointOnSegment.x / segment.bounds.width
        
        if segment != previousSegment
        {
            
            guard let newSegmentIndex = stackView.arrangedSubviews.indexOf(segment) else
            {
                return;
            }
            
            currentSegment = newSegmentIndex
        
            previousSegment = segment;
        }
        
        segmentProgress = Float(relativePosition)
        
        delegate?.didSeekToPosition(relativePosition, ofSegmentWithIndex: currentSegment)
        
    }
    
    func segmentAtIndex(index: Int) -> UISlider?
    {
        guard stackView.arrangedSubviews.count > index else
        {
            return nil
        }
        
        if let slider = stackView.arrangedSubviews[index] as? UISlider
        {
            return slider
        }
        
        return nil
    }
    
    @objc func didStartDragging()
    {
        delegate?.didStartDragging()
    }
    
    @objc func didFinishDragging()
    {
        delegate?.didFinishDragging()
    }

}

extension PlaybackIndicator: UIGestureRecognizerDelegate {
    
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        guard let gestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer else {
            return true
        }
        
        let velocity = gestureRecognizer.velocityInView(self)
        return fabs(velocity.y) < fabs(velocity.x)
    }
}