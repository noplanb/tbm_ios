//
//  Menu.swift
//  Zazo
//
//  Created by Rinat on 05/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import Popover

public protocol MenuOutput {
    
    func eventFromMenu(menu: Menu, didPick item: MenuItem)
    
}

@objc public class MenuItem: NSObject {
    
    var userData: AnyObject?
    var title: String
    
    init(title: String) {
        self.title = title
    }
}

@objc public class Menu: NSObject {
    
    public var output: MenuOutput?
    
    let table = MenuTable(frame: CGRect.init(x: 0, y: 0, width: 200, height: 100), style: UITableViewStyle.Plain)
    
    public func show(from view: UIView, items: [MenuItem]) {
        
        table.items = items
        
        let popover = Popover(options: [.Type(.Up)])
        
        var point = view.frame.origin
        
        point.x += 6
        point.x += view.frame.size.width / 2 // Center X
        point.y += view.frame.size.height    // Bottom Y
        
        // Corrections:
        
        point.y += UIApplication.sharedApplication().statusBarFrame.height
        point.y -= kLayoutConstNameLabelHeight
        
        popover.show(table,
                     point: point,
                     inView: view.window!)
    }
    
}

class MenuTable: UITableView {
    
    var items: [MenuItem]? {
        didSet {
            self.reloadData()
        }
    }
    
    var height: CGFloat {
        
        guard let count = items?.count else {
            return 100
        }
        
        return CGFloat(count) * 44
    }
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(width: 200, height: height)
    }
}

extension MenuTable: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
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
        
        cell?.textLabel?.text = item.title
        
        return cell!
    }

}