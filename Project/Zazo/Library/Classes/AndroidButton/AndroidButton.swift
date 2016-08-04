//
//  AndroidButton.swift
//  Zazo
//
//  Created by Rinat on 03/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

let names = [AndroidButtonType.Next: "next-icon", AndroidButtonType.Reply: "reply-icon"]

class AndroidButton: UIButton {
    
    init?(androidButtonOfType type:AndroidButtonType) {
        
        guard let imageName = names[type] else {
            return nil
        }
        
        super.init(frame: CGRect.zero)
        
        let image = UIImage(named: imageName)
        setImage(image, forState: .Normal)
        backgroundColor = UIColor.whiteColor()
        layer.cornerRadius = 32
        layer.shadowOffset = CGSize(width: 0, height: 12)
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOpacity = 0.2
        
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize.init(width: 64, height: 64)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}