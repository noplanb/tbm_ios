//
//  Messages.swift
//  Zazo
//
//  Created by Server on 26/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import Unbox

enum ResponseStatus: String {
    case Success = "success"
    case Failure = "failure"
    case Unknown
}

extension ResponseStatus: UnboxableEnum {
    static func unboxFallbackValue() -> ResponseStatus {
        return .Unknown
    }
}

struct MessagesResponse {
    
    struct Data {
        
        enum MessageType: String {
            case Video = "video"
            case Text = "text"
            case Unknown
        }
        
        struct IncomingMessage {
            let type: MessageType
            let id: String
            let body: String
        }
        
        struct OutcomingMessage {
            let type: MessageType
            let id: String
            let status: Status
    
            enum Status: String {
                case Uploaded = "uploaded"
                case Downloaded = "downloaded"
                case Viewed = "viewed"
                case Unknown
            }
        }
        
        let mKey: String
        let incomingMessages: [IncomingMessage]
        let outcomingMessages: [OutcomingMessage]
    }
    
    let status: ResponseStatus
    let data: [Data]
}

extension MessagesResponse: Unboxable {
    init(unboxer: Unboxer) {
        status = unboxer.unbox("status")
        data = unboxer.unbox("data")
    }
}

extension MessagesResponse.Data: Unboxable {
    init(unboxer: Unboxer) {
        mKey = unboxer.unbox("mKey")
        incomingMessages = unboxer.unbox("messages")
        outcomingMessages = unboxer.unbox("statuses")
    }
}

extension MessagesResponse.Data.OutcomingMessage: Unboxable {
    init(unboxer: Unboxer) {
        type = unboxer.unbox("type")
        id = unboxer.unbox("id")
        status = unboxer.unbox("status")
    }
}

extension MessagesResponse.Data.IncomingMessage: Unboxable {
    init(unboxer: Unboxer) {
        type = unboxer.unbox("type")
        id = unboxer.unbox("id")
        body = unboxer.unbox("body")

    }
}

extension MessagesResponse.Data.MessageType: UnboxableEnum {
    static func unboxFallbackValue() -> MessagesResponse.Data.MessageType {
        return .Unknown
    }
}

extension MessagesResponse.Data.OutcomingMessage.Status: UnboxableEnum {
    static func unboxFallbackValue() -> MessagesResponse.Data.OutcomingMessage.Status {
        return .Unknown
    }
}