//
//  MessagePopover.swift
//  Zazo
//
//  Created by Server on 02/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import OAStackView

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
    
    var maxPopoverHeight: CGFloat {
        let screenSize = UIScreen.mainScreen().bounds
        return screenSize.height / 3 - 40
    }
    
    weak var delegate: MessagePopoperControllerDelegate?
    
    var popoverView: Popover?
    var fullscreenView: FullscreenView?
    
    var isBeingDismissedExternally = false
    let group: ZZMessageGroup
    
    let textMaker = MessagePopoverTextMaker()
    
    init(group: ZZMessageGroup) {

        self.group = group
        super.init()
    }
    
    public func show(from view: UIView) {
        
        let views = group.messages.map({ self.messageView(withModel: $0) })
        let contentView = makeStackedView(with: views)
        
        if contentView.bounds.height > maxPopoverHeight {
            showFullscreen(with: contentView)
        }
        else {
            showPopover(contentView, from: view)
        }
    }
    
    public func makeStackedView(with views: [UIView]) -> UIView {
        let spacing = CGFloat(8)
        var height: CGFloat = CGFloat(views.count - 1) * spacing
        let contentView = OAStackView()
        contentView.spacing = spacing
        contentView.axis = .Vertical
        
        for view in views {
            height += view.bounds.height
            contentView.addArrangedSubview(view)
        }
        
        contentView.frame = CGRect(origin: CGPoint.zero, size: CGSize(width: popoverWidth, height: height))
        return contentView
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
    
    public func showFullscreen(with view: UIView) {
        
        let fullscreenView = FullscreenView()
        self.fullscreenView = fullscreenView
        fullscreenView.delegate = self
        
        fullscreenView.frame = containerView.bounds
        containerView.addSubview(fullscreenView)
        
        fullscreenView.contentView.addSubview(view)
        view.snp_makeConstraints { (make) in
            make.edges.equalTo(fullscreenView.contentView)
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
    
    func messageView(withModel model: ZZMessageDomainModel) -> UIView {
        let view = NSBundle.mainBundle().loadNibNamed("MessageView", owner: self, options: [:])!.first as! MessageView
        view.nameLabel.text = group.name.uppercaseString
        view.timeLabel.text = NSDate(timeIntervalSince1970: model.timestamp()).zz_formattedDate()
        view.bodyLabel.text = model.body
        view.layer.cornerRadius = 8
        
        var size = view.systemLayoutSizeFittingSize(CGSize(width: popoverWidth, height: 1000),
                                                    withHorizontalFittingPriority: UILayoutPriorityRequired,
                                                    verticalFittingPriority: UILayoutPriorityFittingSizeLevel)
        size.width = max(popoverWidth, size.width)
        view.frame = CGRect(origin: CGPoint.zero, size: size)
        view.autoresizingMask = []
        
        return view
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
