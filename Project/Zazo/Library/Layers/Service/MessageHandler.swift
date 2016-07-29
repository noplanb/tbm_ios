//
//  MessageHandler.swift
//  Zazo
//
//  Created by Server on 28/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

@objc public protocol MessageEventsObserver: NSObjectProtocol {
    
    func messageStatusChanged(message: ZZMessageDomainModel)
}

public func ==(lhs: MessageEventsObserver, rhs: MessageEventsObserver) -> Bool {
    return lhs === rhs
}


@objc class MessageHandler: NSObject {
    
    static let sharedInstance = MessageHandler()
    
    private var messageEventsObservers = [MessageEventsObserver]()
    
    @objc func handleNewMessage(notification m: ZZMessageNotificationDomainModel) {
        
        let friendModel = ZZFriendDataProvider.friendWithMKeyValue(m.from_mkey)
        
        let messageModel = ZZMessageDomainModel()
        
        messageModel.body = m.body
        messageModel.friendID = friendModel.idTbm
        messageModel.setMessageTypeAsString(m.type)
        
        ZZMessageDataUpdater.insertMessage(messageModel)
        
    }
 
    
}

extension MessageHandler {
    func addMessageEventsObserver(observer: MessageEventsObserver) {
        
        guard messageEventsObservers.indexOf({$0 == observer}) == nil else {
            logWarning("Already contains this observer")
            return
        }
        
        messageEventsObservers.append(observer)
    }
}