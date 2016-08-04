//
//  MessagePopover.swift
//  Zazo
//
//  Created by Server on 02/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import Popover

@objc protocol MessagePopoperControllerDelegate: NSObjectProtocol {
    func messagePopoperController(didDismiss controller: MessagePopoperController)
}

@objc public class MessagePopoperModel: NSObject {
    var date: NSDate!
    var text: String!
    var name: String!
}

@objc public class MessagePopoperController: NSObject {

    public var containerView: UIView = UIApplication.sharedApplication().keyWindow!
    
    var delegate: MessagePopoperControllerDelegate?
    let text: NSAttributedString
    var popover: Popover!
    var isBeingDismissedExternally = false
    
    init(model: MessagePopoperModel) {
        let textMaker = MessagePopoverTextMaker()
        text = textMaker.makeText(for: model)
        
        super.init()
        
        popover = Popover(showHandler: nil, dismissHandler: {
            self.didDismiss()
        })
        popover.blackOverlayColor = UIColor.clearColor()
        
    }
    
    public func show(from view: UIView) {
        
        var point = view.center
        let isTopCell = point.y < self.containerView.frame.height / 2
        
        point.y += UIApplication.sharedApplication().statusBarFrame.height
        
        if isTopCell {
            popover.popoverType = .Down
            point.y += 8
            
        }
        else {
            popover.popoverType = .Up
            point.y -= kLayoutConstNameLabelHeight
        }
        
        popover.show(textView(), point: point, inView: self.containerView)

    }
    
    public func dismiss() {
        isBeingDismissedExternally = true
        popover.dismiss()
    }
    
    func didDismiss() {
        if !isBeingDismissedExternally {
            delegate?.messagePopoperController(didDismiss: self)
        }
    }
    
    func textView() -> UITextView {
        let textView = UITextView()
        textView.attributedText = text
        textView.editable = false
        textView.textContainerInset = UIEdgeInsetsMake(0, 4, 8, 4)
        textView.sizeToFit()
        return textView
    }
}

public class MessagePopoverTextMaker {
    
    typealias attributes = [String : AnyObject]
    let dateFormatter = NSDateFormatter()
    
    init() {
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .ShortStyle
    }
    
    public func makeText(for model: MessagePopoperModel) -> NSAttributedString {
        
        let result = NSMutableAttributedString()
        
        let title = NSAttributedString(string: model.name, attributes: attributesForTitle())
        let body = NSAttributedString(string: model.text, attributes: attributesForBody())
        let date = NSAttributedString(string: dateFormatter.stringFromDate(model.date) , attributes: attributesForDate())
        
        let linebreak = NSAttributedString(string: "\n")
        
        result.appendAttributedString(title)
        result.appendAttributedString(linebreak)
        result.appendAttributedString(body)
        result.appendAttributedString(linebreak)
        result.appendAttributedString(date)
        
        return result.copy() as! NSAttributedString
    }
    
    func attributesForTitle() -> attributes {
        return [NSFontAttributeName: UIFont.systemFontOfSize(18),
                NSParagraphStyleAttributeName: paragraphAttributes(),
                NSForegroundColorAttributeName: ZZColorTheme.shared().tintColor]
    }
    
    func attributesForBody() -> attributes {
        return [NSFontAttributeName: UIFont.systemFontOfSize(16),
                NSParagraphStyleAttributeName: paragraphAttributes()]

    }
    
    func attributesForDate() -> attributes {
        return [NSFontAttributeName: UIFont.systemFontOfSize(14),
                NSParagraphStyleAttributeName: paragraphAttributes(),
                NSForegroundColorAttributeName: UIColor.grayColor()]

    }
    
    func paragraphAttributes() -> NSParagraphStyle {
        let style = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        style.lineHeightMultiple = 1.3
        return style
    }
}
