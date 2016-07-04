//
//  TranscriptView.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public class TranscriptItemView: UIView {
    
    public let textLabel = UILabel()
    public let timeLabel = UILabel()
    
    convenience init() {
        
        self.init(frame: CGRect.zero)

        // Configure self:
        
//        self.clipsToBounds = true
        self.backgroundColor = UIColor.whiteColor()
        
        let layer = self.layer
        
        layer.cornerRadius = 12
        layer.shadowOpacity = 1
        layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.2).CGColor
        layer.shadowRadius = 2
        layer.shadowOffset = CGSize(width: 0, height: 4)
        
        self.layoutMargins = UIEdgeInsets(top: 6,
                                          left: 12,
                                          bottom: 6,
                                          right: 12)
        
        // Configure subviews:
        
        timeLabel.textColor = UIColor.grayColor()
        timeLabel.textAlignment = .Right
        timeLabel.font = UIFont.systemFontOfSize(11)
        
        textLabel.numberOfLines = 0;
        
        addSubview(textLabel)
        addSubview(timeLabel)
        
    }
    
    public override func updateConstraints() {
        
        super.updateConstraints()
        
        textLabel.snp_remakeConstraints { (make) in
            make.left.equalTo(self.snp_leftMargin)
            make.right.equalTo(self.snp_rightMargin)
            make.top.equalTo(self.snp_topMargin)
        }
        
        timeLabel.snp_remakeConstraints { (make) in
            make.left.equalTo(self.snp_leftMargin)
            make.right.equalTo(self.snp_rightMargin)
            make.bottom.equalTo(self.snp_bottomMargin)
            make.top.equalTo(self.textLabel.snp_bottom)
        }
        
    }
}