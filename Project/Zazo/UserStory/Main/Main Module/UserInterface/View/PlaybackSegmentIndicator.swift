//
//  PlaybackSegmentIndicator.swift
//  Zazo
//
//  Created by Rinat on 15/05/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import OAStackView


public protocol PlaybackSegmentIndicatorDelegate: class
{
    func didTapOnSegmentWithIndex(segmentIndex: Int)
}

public class PlaybackSegmentIndicator: UIView
{
    public weak var delegate: PlaybackSegmentIndicatorDelegate?
    
    var intristicContentSize = CGSize(width: 200, height: 5)
    
    @objc public var segmentCount: Int = 1 {
        didSet {
            updateSegmentCountTo(segmentCount)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(origin: frame.origin, size: self.intristicContentSize))
        
        stackView.frame = self.bounds
        self.backgroundColor = UIColor.lightGrayColor()
        
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
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var stackView: OAStackView = {
        let result = OAStackView()
        
        result.spacing = 5
        result.distribution = .FillEqually
        self.addSubview(result)
        
        return result;
    }()
    
    func makeSegment() -> UIView
    {
        let result = UIView()
        
        result.backgroundColor = UIColor.blackColor()
        
        let recognizer = UITapGestureRecognizer(target: self,
                                                action: #selector(didTapOnSegmentWithRecogizer))
        
        result.addGestureRecognizer(recognizer)
        
        return result
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

