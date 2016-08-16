//
//  ComposeViews.swift
//  Zazo
//
//  Created by Rinat on 19/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

struct ComposeSubviews {
    
    let navigationBar: UINavigationBar = {
        
        let bar = UINavigationBar()
        
        bar.translucent = false
        bar.barTintColor = ZZColorTheme.shared().menuTintColor
        bar.barStyle = .Black
        bar.tintColor = UIColor.whiteColor()
        
        return bar
    }()
    
    let textField: UITextView = {
        
        let field = UITextView()
        
        field.text = ""
        field.textColor = UIColor.whiteColor()
        field.backgroundColor = UIColor.clearColor()
        field.tintColor = UIColor.whiteColor()
        field.clipsToBounds = true
        
        return field
    }()
    
    let sendButton: UIButton = {
        
        let button = UIButton()
        
        button.setImage(UIImage(named: "send-button"), forState: .Normal)
        button.tintColor = UIColor.whiteColor()
        
        return button
    }()
    
    let keyboardButton: UIButton = {
        
        let button = UIButton()
        
        button.setImage(UIImage(named: "keyboard-icon"), forState: .Normal)
        button.tintColor = UIColor.whiteColor()
        
        return button
    }()
    
    let emojiKeyboard: UIView = {
        
        return UIView()
    }()
}
