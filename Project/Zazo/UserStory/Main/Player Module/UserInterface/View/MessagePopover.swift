//
//  MessagePopover.swift
//  Zazo
//
//  Created by Server on 02/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import Popover

@objc public class MessagePopoperModel: NSObject {
    var date: NSDate!
    var text: String!
    var name: String!
}

@objc public class MessagePopoperController: NSObject {

    let text: NSAttributedString
    let popover = Popover()
    
    init(model: MessagePopoperModel) {
        let textMaker = MessagePopoverTextMaker()
        text = textMaker.makeText(for: model)
        super.init()
    }
    
    public func show(from view: UIView) {
        
        guard let rootView = view.window?.rootViewController?.view else {
            return
        }
        
        var point = view.center        
        let isTopCell = point.y < rootView.frame.height / 2
        
        point.y += UIApplication.sharedApplication().statusBarFrame.height
        
        if isTopCell {
            popover.popoverType = .Down
            point.y += 8
            
        }
        else {
            popover.popoverType = .Up
            point.y -= kLayoutConstNameLabelHeight
        }
        
        popover.show(textView(), point: point)

    }
    
    public func dismiss() {
        popover.dismiss()
    }
    
    func textView() -> UITextView {
        let textView = UITextView()
        textView.attributedText = text
        textView.editable = false
        textView.sizeToFit()
        return textView
    }
    
}

public class MessagePopoverTextMaker {
    
    typealias attributes = [String : AnyObject]
    
    public func makeText(for model: MessagePopoperModel) -> NSAttributedString {
        
        let result = NSMutableAttributedString()
        
        let title = NSAttributedString(string: model.name, attributes: attributesForTitle())
        let body = NSAttributedString(string: model.text, attributes: attributesForBody())
        let date = NSAttributedString(string: model.date.description, attributes: attributesForDate())
        
        let linebreak = NSAttributedString(string: "\n")
        
        result.appendAttributedString(title)
        result.appendAttributedString(linebreak)
        result.appendAttributedString(body)
        result.appendAttributedString(linebreak)
        result.appendAttributedString(date)
        
        return result.copy() as! NSAttributedString
    }
    
    func attributesForTitle() -> attributes {
        return [NSFontAttributeName: UIFont.systemFontOfSize(14),
                NSForegroundColorAttributeName: ZZColorTheme.shared().tintColor]
    }
    
    func attributesForBody() -> attributes {
        return [NSFontAttributeName: UIFont.systemFontOfSize(12)]

    }
    
    func attributesForDate() -> attributes {
        return [NSFontAttributeName: UIFont.systemFontOfSize(11),
                NSForegroundColorAttributeName: UIColor.grayColor()]

    }
}
