//
//  TranscriptModuleView.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import SnapKit
import OAStackView

public class TranscriptView: UIView {

    public let stackView = OAStackView()
    public let scrollView = UIScrollView()
    public let thumb = UIView()
    public let navigationBar = UINavigationBar()
    
    convenience init() {
        self.init(frame: CGRect.zero)
        
        self.backgroundColor = ZZColorTheme.shared().tintColor
        
        addSubview(thumb)
        addSubview(scrollView)
        addSubview(navigationBar)
        scrollView.addSubview(stackView)
        
        stackView.axis = .Vertical
        stackView.spacing = 8
        
        thumb.backgroundColor = UIColor.whiteColor()
        thumb.layer.cornerRadius = 8
        
    }
    
    override public func updateConstraints() {
        
        super.updateConstraints()
        
        guard let screenWidth = self.window?.bounds.width else {
            return
        }
        
        let stackWidth = screenWidth * 2/3
        
        let top = navigationBar.snp_bottomMargin
        
        scrollView.snp_remakeConstraints { (make) in
            make.width.equalTo(stackWidth)
            make.top.equalTo(top).offset(32)
            make.right.equalTo(self.snp_right)
            make.bottom.equalTo(self.snp_bottomMargin)
        }
        
        stackView.snp_remakeConstraints { (make) in
            make.top.bottom.equalTo(scrollView)
            make.width.equalTo(stackWidth - 16)
            make.right.equalTo(self.snp_rightMargin)
        }
        
        thumb.snp_remakeConstraints { (make) in
            make.left.equalTo(self.snp_leftMargin)
            make.top.equalTo(top).offset(8)
            make.size.equalTo(kGridItemSize())
        }
        
        navigationBar.snp_remakeConstraints { (make) in
            make.left.right.top.equalTo(self)
            make.height.equalTo(65)
        }
    }
    
}