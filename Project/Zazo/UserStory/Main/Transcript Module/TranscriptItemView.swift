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
        
        timeLabel.textColor = UIColor.grayColor()
        timeLabel.textAlignment = .Right
        
        self.backgroundColor = UIColor.whiteColor()
        self.layer.cornerRadius = 16
        
        self.layer.shadowColor = UIColor.blackColor().colorWithAlphaComponent(0.5).CGColor
        self.layer.shadowRadius = 8
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
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