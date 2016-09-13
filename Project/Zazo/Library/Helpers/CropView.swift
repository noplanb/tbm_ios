//
//  CropView.swift
//  Zazo
//
//  Created by Rinat on 08/09/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import SnapKit

class CropView: UIView, UIScrollViewDelegate {
    
    let scrollView = UIScrollView()
    let imageView = UIImageView()
    let navigationBar = UINavigationBar()
    let overlayView = CropOverlayView()
    
    var cropSize = CGSize(width: 100, height: 100) {
        didSet {
            remakeConstraints()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeLayout()
        backgroundColor = UIColor.blackColor()
            
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        
        navigationBar.barStyle = .BlackTranslucent
        overlayView.userInteractionEnabled = false
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeLayout() {
        self.addSubview(scrollView)
        self.addSubview(overlayView)
        self.addSubview(navigationBar)
        
        scrollView.addSubview(imageView)
        
        imageView.snp_makeConstraints { (make) in
            make.edges.equalTo(scrollView)
        }
        
        navigationBar.snp_makeConstraints { (make) in
            make.height.equalTo(65)
            make.left.top.right.equalTo(self)
        }
        
        overlayView.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        remakeConstraints()
    }
    
    func remakeConstraints() {
        scrollView.snp_remakeConstraints { (make) in
            make.center.equalTo(self)
            make.size.equalTo(self.cropSize)
        }
        
        overlayView.overlayLayer.cropSize = cropSize
        overlayView.overlayLayer.avatarRadius = cropSize.width/2.5
        overlayView.overlayLayer.setNeedsLayout()
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    override func hitTest(point: CGPoint, withEvent event: UIEvent?) -> UIView? {
        var view = super.hitTest(point, withEvent: event) ?? scrollView
        
        if view === self {
            view = scrollView
        }
        
        return view
    }
}