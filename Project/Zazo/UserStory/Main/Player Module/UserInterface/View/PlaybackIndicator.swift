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

@objc class PlaybackSegment: NSObject {
    
    @objc var userdata: NSDictionary!
    let type: ZZIncomingEventType
    
    @objc init(type: ZZIncomingEventType) {
        self.type = type
        super.init()
    }
}

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
                self.updateSegments()
            }
        }
    }
    
    @objc public weak var delegate: PlaybackIndicatorDelegate?
    
    var segmentCount: Int {
        return segmentScheme.count
    }
    
    var segmentScheme = [PlaybackSegment]() {
        didSet {
            updateSegments()
        }
    }
    
    @objc public var currentSegment: Int = 0 {
                
        didSet {
            
            guard oldValue != currentSegment else { return }
            
            if let iconView = segmentAtIndex(currentSegment) as? UIImageView {
                animate(iconView)
            }
            
            guard let oldSegment = segmentAtIndex(oldValue) else { return }
            
            if let slider = oldSegment as? UISlider
            {
                slider.setThumbImage(emptySegmentPositionImage, forState: .Normal)
            }
            
        }
    }
    
    var segmentProgressChangesToIgnore = 0 // hack to ignore incorrect values from AVPlayer
    
    @objc public var segmentProgress: Float = 0 {
        didSet {
            
            guard let segment = segmentAtIndex(currentSegment) as? UISlider else
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
    
    func updateSegments()
    {
        clearSegments()

        for index in 0..<segmentCount
        {
            let type = segmentScheme[index].type
            stackView.addArrangedSubview(makeSegment(of: type))
        }
        
        updateSegmentWidths()
        
        UIView.animateWithDuration(0.25)
        {
            self.layoutIfNeeded()
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateSegmentWidths()
    }
    
    func updateSegmentWidths() {
        
        let totalSpacingWidth = stackView.spacing * CGFloat(stackView.arrangedSubviews.count - 1)
        let screenWidth = self.frame.width

        let segmentViews = stackView.arrangedSubviews.filter { (view) -> Bool in
            return view is PlaybackSegmentView
        } .map { (element) -> PlaybackSegmentView in
            return element as! PlaybackSegmentView
        }
    
        let countOfNonSegmentViews = stackView.arrangedSubviews.count - segmentViews.count
        let widthOfNonSegmentView = CGFloat(29)
        let totalWidthOfNonSegmentViews = CGFloat(countOfNonSegmentViews) * widthOfNonSegmentView
        
        let segmentWidth = (screenWidth - totalSpacingWidth - totalWidthOfNonSegmentViews) / CGFloat(segmentViews.count)
        
        for segmentView in segmentViews {
            segmentView.preferredWidth = segmentWidth
        }
        
    }
    
    func clearSegments() {
        
        currentSegment = 0
        previousSegment = nil
        
        let count = stackView.arrangedSubviews.count
        
        for _ in 0..<count
        {
            stackView.removeArrangedSubview(stackView.arrangedSubviews.last!)
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
        result.distribution = .Fill
        self.addSubview(result)
        
        result.snp_makeConstraints { make in
           make.edges.equalTo(self)
        }
    
        return result;
    }()
    
    func makeSegment(of type: ZZIncomingEventType) -> UIView
    {
        if type == .Video {
            
            let segment = PlaybackSegmentView()
            
            segment.backgroundColor = UIColor.clearColor()
            segment.exclusiveTouch = true
            segment.minimumTrackTintColor = self.colorTheme.bodyColor
            segment.maximumTrackTintColor = self.colorTheme.bodyColor
            segment.userInteractionEnabled = false
            segment.setThumbImage(emptySegmentPositionImage, forState: .Normal)
            segment.translatesAutoresizingMaskIntoConstraints = false
            segment.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
            segment.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
            segment.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
            segment.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)

            return segment
        }

        if type == .Message {
            
            let icon = UIImage(named: "text-message-icon", inBundle: nil, compatibleWithTraitCollection: nil)!
            let segment = UIImageView(image: icon)
            
            segment.sizeToFit()
            segment.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
            segment.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Vertical)
            segment.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Horizontal)
            segment.setContentCompressionResistancePriority(UILayoutPriorityRequired, forAxis: .Vertical)
            segment.translatesAutoresizingMaskIntoConstraints = false

            segment.contentMode = .Center
            
            return segment
            
        }
        
        return UIView()
    }
    
    private func animate(view: UIView) {
        
        UIView.animateWithDuration(0.2,
                                   delay: 0,
                                   usingSpringWithDamping: 1,
                                   initialSpringVelocity: 1,
                                   options: [],
                                   animations: {
                                    
                                    view.transform = CGAffineTransformMakeScale(1.2, 1.2)
                                    
        }) { (completed) in
            
        }
        
        UIView.animateWithDuration(0.3,
                                   delay: 0.2,
                                   usingSpringWithDamping: 1,
                                   initialSpringVelocity: 1,
                                   options: [],
                                   animations: {
                                    
                                    view.transform = CGAffineTransformIdentity
                                    
        }) { (completed) in
            
        }
        
        
    }
    
    var previousSegment: UISlider?    
    
    @objc func dragWithRecognizer(recognizer: UIPanGestureRecognizer) {
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
        
        guard let segment = view as? PlaybackSegmentView else
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
    
    func segmentAtIndex(index: Int) -> UIView?
    {
        guard stackView.arrangedSubviews.count > index else
        {
            return nil
        }
        
        if let slider = stackView.arrangedSubviews[index] as? UIView
        {
            return slider
        }
        
        return nil
    }
    
    @objc func didStartDragging() {
        delegate?.didStartDragging()
    }
    
    @objc func didFinishDragging() {
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