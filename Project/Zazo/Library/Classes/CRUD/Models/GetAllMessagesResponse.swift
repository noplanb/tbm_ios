//
//  Messages.swift
//  Zazo
//
//  Created by Server on 26/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import Unbox

struct GetAllMessagesResponse {
    
    struct Data {
        
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

extension GetAllMessagesResponse: Unboxable {
    init(unboxer: Unboxer) {
        status = unboxer.unbox("status")
        data = unboxer.unbox("data")
    }
}

extension GetAllMessagesResponse.Data: Unboxable {
    init(unboxer: Unboxer) {
        mKey = unboxer.unbox("mkey")
        incomingMessages = unboxer.unbox("messages")
        outcomingMessages = unboxer.unbox("statuses")
    }
}

extension GetAllMessagesResponse.Data.OutcomingMessage: Unboxable {
    init(unboxer: Unboxer) {
        type = unboxer.unbox("type")
        id = unboxer.unbox("message_id")
        status = unboxer.unbox("status")
    }
}

extension GetAllMessagesResponse.Data.IncomingMessage: Unboxable {
    init(unboxer: Unboxer) {
        type = unboxer.unbox("type")
        id = unboxer.unbox("message_id")
        body = unboxer.unbox("body")

    }
}

extension GetAllMessagesResponse.Data.OutcomingMessage.Status: UnboxableEnum {
    static func unboxFallbackValue() -> GetAllMessagesResponse.Data.OutcomingMessage.Status {
        return .Unknown
    }
}