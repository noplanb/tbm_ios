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
    
    var popoverWidth: CGFloat {
        let screenWidth = UIScreen.mainScreen().bounds.size.width
        return screenWidth * 3 / 4
    }
    
    weak var delegate: MessagePopoperControllerDelegate?
    
    var popoverView: Popover?
    var fullscreenView: FullscreenView?
    
    var isBeingDismissedExternally = false
    let textMaker = MessagePopoverTextMaker()
    let maxPopoverHeight: CGFloat
    let messages: ZZMessageGroup
    
    init(group: ZZMessageGroup) {
        
        messages = group
        let screenSize = UIScreen.mainScreen().bounds
        maxPopoverHeight = screenSize.height / 3 - 40
        
        super.init()
    }
    
    public func show(from view: UIView) {
        
        let content = textMaker.makeText(for: messages)
        let contentView = messageView(withText: content)
        
        if contentView.bounds.height > maxPopoverHeight {
            let views = textMaker.makeTexts(for: messages).map({ text in
                messageView(withText: text)
            })
            showFullscreen(with: views)
        }
        else {
            showPopover(contentView, from: view)
        }
    }
    
    public func showPopover(view: UIView, from fromView: UIView) {
        
        popoverView = Popover(showHandler: nil, dismissHandler: {
            self.didDismiss()
        })
        
        guard let popoverView = popoverView else {
            return
        }

        popoverView.blackOverlayColor = UIColor.clearColor()

        var point = fromView.superview!.convertPoint(fromView.center, toView: containerView)
        let isTopCell = point.y < containerView.bounds.height / 2
        
//        point.y += UIApplication.sharedApplication().statusBarFrame.height
        
        if isTopCell {
            popoverView.popoverType = .Down
            point.y += 8
            
        }
        else {
            popoverView.popoverType = .Up
            point.y -= kLayoutConstNameLabelHeight
        }
        
        popoverView.show(view, point: point, inView: self.containerView)
    }
    
    public func showFullscreen(with views: [UIView]) {
        
        let fullscreenView = FullscreenView()
        self.fullscreenView = fullscreenView
        
        fullscreenView.delegate = self
        
        fullscreenView.frame = containerView.bounds
        containerView.addSubview(fullscreenView)
        
        for view in views {
            fullscreenView.stackView.addArrangedSubview(self.fullscreenItemContainer(for: view))
        }
    }
    
    func fullscreenItemContainer(for view: UIView) -> UIView {
        
        let containerView = UIView()
        containerView.addSubview(view)
        
        view.snp_makeConstraints { (make) in
            make.bottom.top.equalTo(containerView)
            make.centerX.equalTo(containerView)
            make.size.equalTo(view.frame.size)
        }

        return containerView
    }
    
    public func dismiss() {
        isBeingDismissedExternally = true
        popoverView?.dismiss()
        fullscreenView?.removeFromSuperview()
    }
    
    func didDismiss() {
        if !isBeingDismissedExternally {
            delegate?.messagePopoperController(didDismiss: self)
        }
    }
    
    func messageView(withText text: NSAttributedString) -> UIView {
        
        let textView = UITextView()
        textView.scrollEnabled = false
        textView.attributedText = text
        textView.editable = false
        textView.textContainerInset = UIEdgeInsetsMake(2, 6, 10, 6)
        textView.layer.cornerRadius = 8
        
        var size = textView.sizeThatFits(CGSize(width: popoverWidth, height: CGFloat.max))
        size.width = max(popoverWidth, size.width)
        
//        let view = UIView()
//        view.addSubview(textView)
        
        textView.frame = CGRect(origin: CGPointZero, size: size)

        return textView
    }
}

extension MessagePopoperController: FullscreenViewDelegate {
    func didTapBackground() {
        self.fullscreenView?.removeFromSuperview()
        self.didDismiss()
    }
}

public class MessagePopoverTextMaker {
    
    typealias attributes = [String : AnyObject]
    let dateFormatter = NSDateFormatter()
    
    init() {
        dateFormatter.dateStyle = .ShortStyle
        dateFormatter.timeStyle = .ShortStyle
    }
    
    public func makeTexts(for group: ZZMessageGroup) -> [NSAttributedString] {
        
        var strings: [NSAttributedString] = group.messages.map({
            self.makeText(for: $0.body, aDate: NSDate(timeIntervalSince1970: $0.timestamp()))
        })
        
        let firstString = NSMutableAttributedString(string: "\(group.name)\n", attributes: attributesForTitle())
        firstString.appendAttributedString(strings[0])
        strings[0] = firstString
        
        return strings
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
