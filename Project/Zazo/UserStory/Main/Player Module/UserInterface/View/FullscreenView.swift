//
//  MessageFullscreenView.swift
//  Zazo
//
//  Created by Rinat on 12/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import OAStackView
import SnapKit

protocol FullscreenViewDelegate: NSObjectProtocol {
    func didTapBackground()
}

public class FullscreenView: UIView {
    
    weak var delegate: FullscreenViewDelegate?
    
    public let stackView = OAStackView()
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {

        super.init(frame: frame)
        
//        autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        addSubview(scrollView)
        
        contentView.addSubview(stackView)
        
        scrollView.addSubview(contentView)
        scrollView.contentInset = UIEdgeInsets(top: 44, left: 0, bottom: 90, right: 0)
        scrollView.clipsToBounds = true
        
        stackView.axis = .Vertical
        stackView.spacing = 8
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(recognizer)
        
        scrollView.snp_makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 20, left: 0, bottom: ZZTabbarViewHeight, right: 0))
        }
        
        contentView.snp_makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.width.equalTo(self)
        }
        
        stackView.snp_makeConstraints { (make) in
            make.left.right.top.equalTo(contentView)
            make.bottom.lessThanOrEqualTo(contentView)
            
        }
    }
    
    @objc func didTap() {
        self.delegate?.didTapBackground()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}