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
    
    let scrollView = UIScrollView()
    public let contentView = UIView()
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    override init(frame: CGRect) {

        super.init(frame: frame)
        
//        autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        addSubview(scrollView)
        
        scrollView.addSubview(contentView)
        scrollView.contentInset = UIEdgeInsets(top: 44, left: 16, bottom: 90, right: 16)
        scrollView.clipsToBounds = true
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(recognizer)
        
        scrollView.snp_makeConstraints { (make) in
            make.edges.equalTo(self).inset(UIEdgeInsets(top: 20, left: 0, bottom: ZZTabbarViewHeight, right: 0))
        }
        
        contentView.snp_makeConstraints { (make) in
            make.edges.equalTo(scrollView)
            make.width.equalTo(self).offset(-32)
        }
    }
    
    @objc func didTap() {
        self.delegate?.didTapBackground()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}