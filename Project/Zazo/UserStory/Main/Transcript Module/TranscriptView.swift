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
    public let playbackIndicator = PlaybackIndicator()

    let fadingView = FadingView()

    convenience init() {
        self.init(frame: CGRect.zero)
        
        self.backgroundColor = ZZColorTheme.shared().tintColor
        
        addSubview(thumb)
        addSubview(fadingView)
        addSubview(navigationBar)
        addSubview(playbackIndicator)
        
        fadingView.addSubview(scrollView)
        
        scrollView.addSubview(stackView)
        scrollView.clipsToBounds = false
        
        navigationBar.translucent = false
        navigationBar.barTintColor = ZZColorTheme.shared().menuTintColor
        navigationBar.barStyle = .Black
        navigationBar.tintColor = UIColor.whiteColor()
        
        stackView.axis = .Vertical
        stackView.spacing = 12
        
        thumb.backgroundColor = UIColor.whiteColor()
        thumb.layer.cornerRadius = 8
        
        playbackIndicator.translatesAutoresizingMaskIntoConstraints = false
        playbackIndicator.invertedColorTheme = true
        playbackIndicator.segmentCount = 3
        playbackIndicator.segmentProgress = 0.5
        
    }
    
    override public func updateConstraints() {
        
        super.updateConstraints()
        
        guard let screenWidth = self.window?.bounds.width else {
            return
        }
        
        let stackWidth = screenWidth * 2/3
        
        let top = navigationBar.snp_bottom
        
        fadingView.snp_remakeConstraints { (make) in
            make.width.equalTo(stackWidth)
            make.top.equalTo(top)
            make.right.equalTo(self.snp_right)
            make.bottom.equalTo(self.snp_bottomMargin)
        }
        
        scrollView.snp_remakeConstraints { (make) in
            make.edges.equalTo(fadingView).inset(UIEdgeInsets(top: 48, left: 0, bottom: 22, right: 0))
        }
        
        stackView.snp_remakeConstraints { (make) in
            make.top.bottom.equalTo(scrollView)
            make.width.equalTo(stackWidth - 16)
            make.right.equalTo(self.snp_rightMargin)
        }
        
        thumb.snp_remakeConstraints { (make) in
            make.left.equalTo(self.snp_leftMargin)
            make.top.equalTo(top).offset(24)
            make.size.equalTo(kGridItemSize())
        }
        
        navigationBar.snp_remakeConstraints { (make) in
            make.left.right.top.equalTo(self)
            make.height.equalTo(65)
        }
        
        playbackIndicator.snp_remakeConstraints { (make) in
            make.left.right.equalTo(self)
            make.centerY.equalTo(navigationBar.snp_bottom)
            make.height.equalTo(22)
        }
    }
    
}