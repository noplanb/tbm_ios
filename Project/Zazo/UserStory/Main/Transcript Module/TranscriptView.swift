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
    public let thumb = UIImageView()
    public let navigationBar = UINavigationBar()
    
    public var playbackIndicator: UIView? {
        
        didSet {
            
            if oldValue?.superview == self {
                oldValue?.removeFromSuperview()
            }
            
            if let newValue = playbackIndicator {
                initiatePlaybackIndicator(newValue)
            }
            
        }
    }

    public var playerView: UIView? {
        
        didSet {
            
            if oldValue?.superview == self {
                oldValue?.removeFromSuperview()
            }
            
            if let newValue = playerView {
                initiatePlayerView(newValue)
            }
            
        }
    }
    
    let thumbHolder = UIView()
    let fadingView = FadingView()

    convenience init() {
        self.init(frame: CGRect.zero)
        
        self.backgroundColor = ZZColorTheme.shared().tintColor
        
        addSubview(thumbHolder)
        addSubview(fadingView)
        addSubview(navigationBar)
        
        fadingView.addSubview(scrollView)
        
        scrollView.addSubview(stackView)
        scrollView.clipsToBounds = false
        
        navigationBar.translucent = false
        navigationBar.barTintColor = ZZColorTheme.shared().menuTintColor
        navigationBar.barStyle = .Black
        navigationBar.tintColor = UIColor.whiteColor()
        
        stackView.axis = .Vertical
        stackView.spacing = 12
        
        thumbHolder.addSubview(thumb)
        thumbHolder.backgroundColor = UIColor.whiteColor()
        thumbHolder.layer.cornerRadius = 4
        
        thumb.contentMode = .ScaleAspectFill
        thumb.clipsToBounds = true
    
        
        
    }
    
    var constraintsSet = false
    
    override public func updateConstraints() {
        
        super.updateConstraints()
        
        guard let screenWidth = self.window?.bounds.width else {
            return
        }
        
        guard !constraintsSet else {
            return
        }
        
        constraintsSet = true
        
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
        
        thumbHolder.snp_remakeConstraints { (make) in
            make.left.equalTo(self.snp_leftMargin)
            make.top.equalTo(top).offset(24)
            make.size.equalTo(kGridItemSize())
        }
        
        thumb.snp_remakeConstraints { (make) in
            make.edges.equalTo(thumbHolder).inset(4)
        }
        
        navigationBar.snp_remakeConstraints { (make) in
            make.left.right.top.equalTo(self)
            make.height.equalTo(65)
        }
        
    }
    
    private func initiatePlaybackIndicator(indicator: UIView) {

        addSubview(indicator)
        
        indicator.snp_remakeConstraints { (make) in
            make.left.right.equalTo(self)
            make.centerY.equalTo(navigationBar.snp_bottom)
            make.height.equalTo(22)
        }

    }
    
    private func initiatePlayerView(view: UIView) {
    
        thumbHolder.addSubview(view)
        
        view.snp_remakeConstraints { (make) in
            make.edges.equalTo(thumbHolder).inset(4)
        }

        
    }
}