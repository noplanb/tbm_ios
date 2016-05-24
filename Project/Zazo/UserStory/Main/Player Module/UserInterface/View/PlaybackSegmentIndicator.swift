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
    func didTapOnSegmentWithIndex(segmentIndex: Int)
    func didStartDragging()
    func didFinishDragging()
    func didSeekToPosition(position: CGFloat)
}

public class PlaybackSegmentIndicator: UIView
{
    @objc public weak var delegate: PlaybackSegmentIndicatorDelegate?
    
    @objc public var segmentCount: Int = 1 {
        didSet {
            updateSegmentCountTo(segmentCount)
            currentSegment = 0
        }
    }
    
    @objc public var currentSegment: Int = 0 {
        didSet {
            for view in stackView.arrangedSubviews
            {
                if let slider = view as? UISlider
                {
                    slider.setThumbImage(UIImage(), forState: .Normal)
                    slider.value = 0
                }
                
                let image = ZZBadgeIndicator.renderWithNumber(currentSegment + Int(1))
                
                segmentAtIndex(currentSegment)?.setThumbImage(image, forState: .Normal)
                
            }
        }
    }
    
    @objc public var segmentProgress: Float = 0 {
        didSet {
            segmentAtIndex(currentSegment)?.value = segmentProgress
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
        
        return segment
    }
    
    
    var previousSlider: UISlider?    
    
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
        handleTouchAtPoint(recognizer.locationInView(self))
    }
    
    func handleTouchAtPoint(aPoint: CGPoint)
    {
        var point = aPoint
        
        point.y = self.bounds.height / 2
        
        let view = self.hitTest(point, withEvent: nil)
        
        guard let slider = view as? UISlider else
        {
            return
        }
        
        if slider != previousSlider
        {
            if previousSlider != nil
            {
                delegate?.didTapOnSegmentWithIndex(stackView.arrangedSubviews.indexOf(slider)!)
            }
            
            previousSlider = slider;
        }
        
        let pointOnSegment = slider.convertPoint(point, fromView: self)
        
        let relativePosition = pointOnSegment.x / slider.bounds.width
        
        slider.value = Float(relativePosition)
        
        delegate?.didSeekToPosition(relativePosition)

    }
    
    func segmentAtIndex(index: Int) -> UISlider?
    {
        if stackView.arrangedSubviews.count < index
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

