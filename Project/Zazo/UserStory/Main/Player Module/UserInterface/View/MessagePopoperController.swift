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
//    var name: String!
}

@objc public class MessagePopoperController: NSObject {

    public var containerView: UIView = UIApplication.sharedApplication().keyWindow!
    
    weak var delegate: MessagePopoperControllerDelegate?
    let text: NSAttributedString
    var popover: Popover!
    var isBeingDismissedExternally = false
    
    init(group: ZZMessageGroup) {
        let textMaker = MessagePopoverTextMaker()
        text = textMaker.makeText(for: group)
        
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
        textView.textContainerInset = UIEdgeInsetsMake(2, 6, 10, 6)
        
        var frame = textView.frame
        let screenSize = UIScreen.mainScreen().bounds
        var size = textView.sizeThatFits(CGSize(width: screenSize.width - 40, height: CGFloat.max))
        
        let minWidth = screenSize.width / 3 + 20
        let maxHeight = screenSize.height / 3 - 40
        
        size.width = max(minWidth, size.width)
        size.height = min(maxHeight, size.height)
        
        frame.size = size
        textView.frame = frame
        
        return textView
    }
}

public class MessagePopoverTextMaker {
    
    typealias attributes = [String : AnyObject]
    let dateFormatter = NSDateFormatter()
    
    init() {
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
    }
    
    public func makeText(for group: ZZMessageGroup) -> NSAttributedString {
        
        let result = NSMutableAttributedString()
        let title = NSAttributedString(string: group.name, attributes: attributesForTitle())
        let linebreak = NSAttributedString(string: "\n")
        
        let strings: [NSAttributedString] = group.messages.map({
            self.makeText(for: $0.body, aDate: NSDate(timeIntervalSince1970: $0.timestamp()))
        })
        
        result.appendAttributedString(title)
        result.appendAttributedString(linebreak)
        
        for string in strings {
            result.appendAttributedString(string)
            
            let isLastString = strings.last === string

            if !isLastString {
                 result.appendAttributedString(linebreak)
            }
            
        }
        
        return result.copy() as! NSAttributedString
    }
    
    func makeText(for aBody: String, aDate: NSDate) -> NSAttributedString {
        
        let result = NSMutableAttributedString()
        
        let body = NSAttributedString(string: aBody, attributes: attributesForBody())
        let date = NSAttributedString(string: aDate.zz_formattedDate() , attributes: attributesForDate())
        let linebreak = NSAttributedString(string: "\n")
        
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
