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
}

public class PlaybackSegmentIndicator: UIView
{
    @objc public weak var delegate: PlaybackSegmentIndicatorDelegate?
    
    @objc public var segmentCount: Int = 1 {
        didSet {
            updateSegmentCountTo(segmentCount)
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
                    
//                    slider.maximumTrackTintColor = self.tintColor.colorWithAlphaComponent(0.5)
                    
//                    if currentSegment > 0
//                    {
//                        if let index = stackView.arrangedSubviews.indexOf(slider)
//                        {
//                            if index < currentSegment
//                            {
//                                slider.maximumTrackTintColor = self.tintColor
//                                
//                            }
//                        }
//                    }
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
        let result = PlaybackSegment()
        
        result.backgroundColor = UIColor.clearColor()
                
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(didTapOnSegmentWithRecogizer))
        
        result.minimumTrackTintColor = self.tintColor
        result.maximumTrackTintColor = self.tintColor
        
        result.addGestureRecognizer(recognizer)
        
        return result
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
    
    @objc func didTapOnSegmentWithRecogizer(recognizer: UITapGestureRecognizer)
    {
        guard recognizer.view != nil else
        {
            return
        }
        
        let foundIndex = self.stackView.arrangedSubviews.indexOf(recognizer.view!)
        
        if let index = foundIndex
        {
            delegate?.didTapOnSegmentWithIndex(index)
        }
    }
}

