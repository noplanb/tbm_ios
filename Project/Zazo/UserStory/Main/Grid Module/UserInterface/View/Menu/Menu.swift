//
//  Menu.swift
//  Zazo
//
//  Created by Rinat on 05/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

@objc public protocol MenuOutput {
    
    func event(from menu: Menu, didPick item: MenuItem)    
}

@objc public class Menu: NSObject {
    
    @objc weak public var output: MenuOutput?
    
    var table = MenuTable(frame: CGRect.zero, style: UITableViewStyle.Plain)
    weak var popover: Popover?
    
    override init() {
        super.init()
        table.menu = self
    }
    
    public func show(from view: UIView, items: [MenuItem]) {
        
        let popover = Popover()
        self.popover = popover
        
        table.items = items
        
        guard let rootView = view.window?.rootViewController?.view else {
            return
        }
        
        var point = view.frame.origin
        
        point.x += 6
        point.x += view.frame.size.width / 2 // Center X
        point.y += view.frame.size.height    // Bottom Y
        
        let isTopCell = point.y < rootView.frame.height / 2

        // Corrections:
        
        point.y += UIApplication.sharedApplication().statusBarFrame.height
        
        if isTopCell {
            
            popover.popoverType = .Down
            point.y += 8
            
        }
        else {
            
            popover.popoverType = .Up
            point.y -= kLayoutConstNameLabelHeight
            
        }
        
        popover.show(table,
                     point: point,
                     inView: rootView)
    }
 
    public func hide() {
        popover?.dismiss()
    }
}

class MenuTable: UITableView {
    
    var width = CGFloat(200)
    weak var menu: Menu?
    
    var items: [MenuItem]? {
        
        didSet {
            self.reloadData()
            self.updateFrame()
        }
    }
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        
        delegate = self
        dataSource = self
        
        alwaysBounceVertical = false
        
        rowHeight = 44
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var height: CGFloat {
        
        guard let count = items?.count else {
            return 100
        }
        
        return CGFloat(count) * rowHeight
    }
    
    override func intrinsicContentSize() -> CGSize {
        
        return CGSize(width: self.width,
                      height: height)
        
    }
    
    func updateFrame() {
        
        invalidateIntrinsicContentSize()
        
        self.frame = CGRect(origin: CGPoint.zero,
                            size: intrinsicContentSize())
        
    }
}

extension MenuTable: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        self.deselectRowAtIndexPath(indexPath, animated: true)
        
        let item = items![indexPath.row]
        
        menu?.output?.event(from: menu!, didPick: item)
        
        menu?.hide()
    }
}

extension MenuTable: UITableViewDataSource {

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let items = items else {
            return 0
        }
        
        return items.count
    }
    
    internal func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "MenuTableCell"
        
        var cell = dequeueReusableCellWithIdentifier(cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: cellIdentifier)            
        }
        
        let item = items![indexPath.row]
        
        cell?.imageView?.image = item.icon
        
        cell?.textLabel?.text = item.title
        
        return cell!
    }

}