//
//  PlaybackSegmentIndicator.swift
//  Zazo
//
//  Created by Rinat on 15/05/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import OAStackView
import SnapKit

@objc public protocol PlaybackSegmentIndicatorDelegate: class
{
    func didStartDragging()
    func didFinishDragging()
    func didSeekToPosition(position: CGFloat, ofSegmentWithIndex: Int)
}

public class PlaybackSegmentIndicator: UIView
{
    let emptySegmentPositionImage = UIImage()
    
    @objc public weak var delegate: PlaybackSegmentIndicatorDelegate?
    
    @objc public var segmentCount: Int = 1 {
        didSet {
            updateSegmentCountTo(segmentCount)
            currentSegment = 0
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
            
            if (segmentProgressChangesToIgnore > 0)
            {
                segmentProgressChangesToIgnore -= 1
            }
            else
            {

                if segment.thumbImageForState(.Normal) == emptySegmentPositionImage
                {
                    let image = ZZBadgeIndicator.renderWithNumber(currentSegment + Int(1))
                    segment.setThumbImage(image, forState: .Normal)
                }
            }

        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stackView.frame = self.bounds
        self.tintColor = ZZColorTheme.shared().tintColor
        
        let panRecognizer = UIPanGestureRecognizer(target: self,
                                                   action: #selector(dragWithRecognizer))
        
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
     
        self.layoutIfNeeded()
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
        segment.minimumTrackTintColor = self.tintColor
        segment.maximumTrackTintColor = self.tintColor
        segment.userInteractionEnabled = false
        segment.setThumbImage(emptySegmentPositionImage, forState: .Normal)

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
        if stackView.arrangedSubviews.count < index
        {
            return nil
        }
        
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

