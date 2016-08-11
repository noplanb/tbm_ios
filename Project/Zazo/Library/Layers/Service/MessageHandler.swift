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

@objc class MessageHandler: NSObject {
    
    static let sharedInstance = MessageHandler()
    
    private var messageEventsObservers = [MessageEventsObserver]()
    private let messagesService: MessagesService
    
    override init() {
        messagesService = ConcreteMessagesService(client: NetworkClient())
    }
    
    @objc func handleNewMessage(notification m: ZZMessageNotificationDomainModel) {
        
        let friendModel = ZZFriendDataProvider.friendWithMKeyValue(m.from_mkey)
        let messageModel = ZZMessageDomainModel()
        
        messageModel.body = m.body
        messageModel.friendID = friendModel.idTbm
        messageModel.setMessageTypeAsString(m.type)
        messageModel.messageID = m.message_id
        
        ZZMessageDataUpdater.deleteReadMessagesForFriendWithID(friendModel.idTbm)
        ZZVideoDataUpdater.deleteAllViewedVideosWithFriendID(friendModel.idTbm, exceptVideoWithID: ZZVideoStatusHandler.sharedInstance().currentlyPlayedVideoID)
        
        ZZMessageDataUpdater.insertMessage(messageModel)
        ZZFriendDataUpdater.updateFriendWithID(messageModel.friendID, setLastEventType: .Message)
        
        notifyObservers(messageChanged: messageModel)
        
        let messageID = Int(m.message_id)!
        messagesService.delete(by: messageID).continueWith { (task) in
            
            if let error = task.error {
                logWarning("Error deletion for message \(messageID): \(error)")
            }            
        }
    }
    
    @objc func mark(asRead messageModel: ZZMessageDomainModel) {
        
        ZZMessageDataUpdater.updateMessageWithID(messageModel.messageID, setStatus: .Read)
        ZZFriendDataUpdater.updateFriendWithID(messageModel.friendID, setLastEventType: .Message)
        notifyObservers(messageChanged: messageModel)
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
    
    func notifyObservers(messageChanged messageModel: ZZMessageDomainModel) {
        for observer in messageEventsObservers {
            observer.messageStatusChanged(messageModel)
        }
    }
    
}


public func ==(lhs: MessageEventsObserver, rhs: MessageEventsObserver) -> Bool {
    return lhs === rhs
}