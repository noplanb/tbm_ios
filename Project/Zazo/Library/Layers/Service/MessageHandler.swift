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
        
        handleNewMessage(model: messageModel)
    }
    
    func handleNewMessage(model messageModel: ZZMessageDomainModel) {
        
        deleteMessage(Int(messageModel.messageID)!)
        
        guard !ZZMessageDataProvider.messageExists(messageModel.messageID) else {
            logWarning("message exists")
            return
        }

        ZZMessageDataUpdater.deleteReadMessagesForFriendWithID(messageModel.friendID)
        ZZVideoDataUpdater.deleteAllViewedVideosWithFriendID(messageModel.friendID, exceptVideoWithID: ZZVideoStatusHandler.sharedInstance().currentlyPlayedVideoID)
        ZZMessageDataUpdater.insertMessage(messageModel)
        ZZFriendDataUpdater.updateFriendWithID(messageModel.friendID, setLastEventType: .Message)
        notifyObservers(messageChanged: messageModel)
    }
    
    func deleteMessage(messageID: Int) {
        messagesService.delete(by: messageID).start { (event) in
            
            switch event {
            case .Failed(let error):
                logWarning("Error deletion for message \(messageID): \(error)")
            default:
                break
            }
        }
    }
    
    @objc func mark(asRead messageModel: ZZMessageDomainModel) {
        
        ZZMessageDataUpdater.updateMessageWithID(messageModel.messageID, setStatus: .Read)
        ZZFriendDataUpdater.updateFriendWithID(messageModel.friendID, setLastEventType: .Message)
        notifyObservers(messageChanged: messageModel)
    }
    
    @objc func pollMessages() {
        messagesService.get().start { (event) in
            switch event {
            case .Next(let result):
                for group in result.data {
                    self.handleNewMessages(group.incomingMessages, from: group.mKey)
                }
            case .Failed(let error):
                logError("\(error)")
            default: break
            }
        }
    }
    
    func handleNewMessages(messages: [GetAllMessagesResponse.Data.IncomingMessage],
                           from friendMKey: String) {
        
        let messages = messages.filter({ $0.type == .Text })
        
        guard messages.count > 0 else {
            return
        }
        
        guard let friendModel = ZZFriendDataProvider.friendWithMKeyValue(friendMKey) else {
            logWarning("invalid mkey \(friendMKey)")
            return
        }
        
        
        for message in messages {
            let messageModel = ZZMessageDomainModel()
            messageModel.body = message.body
            messageModel.friendID = friendModel.idTbm
            messageModel.setMessageTypeAsString(message.type.rawValue)
            messageModel.messageID = message.id
            handleNewMessage(model: messageModel)
        }
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