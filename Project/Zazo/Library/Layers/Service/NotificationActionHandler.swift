//
//  NotificationActionHandler.swift
//  Zazo
//
//  Created by Rinat on 19/08/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

@objc class NotificationActionHandler: NSObject {
    
    typealias UserInfo = [String: AnyObject]
    typealias Handler = (UserInfo) -> ()
    
    var handlers = [String: Handler]()
    
    func register(actionIdentifier: String, handler: Handler) {
        handlers[actionIdentifier] = handler
    }
    
    func handle(actionIdentifier: String, userInfo: UserInfo) {
        if let handler = handlers[actionIdentifier] {
            handler(userInfo)
        }
    }
}