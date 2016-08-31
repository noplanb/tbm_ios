//
//  ComposeModuleView.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import SnapKit
import OAStackView

public class ComposeView: UIView {

    let elements = ComposeSubviews()
    
    public let scrollView = UIScrollView()
    
    public let bottomSpacer = UIView()
    
    convenience init() {
        self.init(frame: UIScreen.mainScreen().bounds)
        
        self.backgroundColor = ZZColorTheme.shared().tintColor
        
        addSubviews()
        installConstraints()
        
        bottomSpacer.accessibilityIdentifier = "Bottom spacer"
    }
    
    func addSubviews() {
        
        let e = elements
        
        let views = [e.navigationBar,
                     e.keyboardButton,
                     e.sendButton,
                     e.textField,
                     e.emojiKeyboard,
                     bottomSpacer]
        
        for view in views {
            addSubview(view)
        }
        
    }
    
    
    func installConstraints() {
        
        elements.navigationBar.snp_remakeConstraints { (make) in
            make.left.right.top.equalTo(self)
            make.height.equalTo(65)
        }

        elements.textField.snp_remakeConstraints { (make) in
            make.left.right.equalTo(self)
            make.top.equalTo(elements.navigationBar.snp_bottom)
            make.bottom.equalTo(elements.keyboardButton.snp_top).offset(-8)
        }
        
        elements.emojiKeyboard.snp_remakeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(bottomSpacer)
        }
        
        elements.keyboardButton.snp_remakeConstraints { (make) in
            make.left.equalTo(self).offset(16)
            make.bottom.equalTo(bottomSpacer.snp_top).offset(-16)
        }
        
        elements.sendButton.snp_remakeConstraints { (make) in
            make.right.equalTo(self).offset(-16)
            make.bottom.equalTo(bottomSpacer.snp_top).offset(-16)
        }
        
        bottomSpacer.snp_remakeConstraints { (make) in
            make.left.right.bottom.equalTo(self)
            make.height.equalTo(0)
        }
    }
    
}