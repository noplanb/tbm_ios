//
//  MessagesService.swift
//  Zazo
//
//  Created by Server on 27/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

class ConcreteMessagesService: NSObject, MessagesService {
    
    let networkClient: NetworkClient
    
    let servicePath = "api/v1/messages"
    
    init(client: NetworkClient) {
        self.networkClient = client
        super.init()
    }
    
    func get() -> SignalProducer<GetAllMessagesResponse, ServiceError> {
        return networkClient.get(servicePath).attemptMap({ (data, response) -> Result<GetAllMessagesResponse, ServiceError> in
            return unbox(data)
        })
    }
    
    func getTranscript(by ID: String) -> SignalProducer<GetMessageResponse, ServiceError> {
        
        let path = servicePath.stringByAppendingString("/\(ID)")
        
        return networkClient.get(path).attemptMap({ (data, response) -> Result<GetMessageResponse, ServiceError> in
            return unbox(data)
        })
    }
    
    func post(text: String, userID: String) -> SignalProducer<GenericResponse, ServiceError> {
        
        guard (userID as NSString).length > 0 else {
            logError("UserID is empty")
            return SignalProducer(error: ServiceError.InputError(errorText: "UserID is empty"))
        }
        
        let params = ["body": text, "type": "text", "receiver_mkey": userID]
        
        return networkClient.post(servicePath, parameters: params).attemptMap({ (data, response) -> Result<GenericResponse, ServiceError> in
            return unbox(data)
        })
    }
    
    func delete(by ID: String) -> SignalProducer<GenericResponse, ServiceError> {
        
        let path = servicePath.stringByAppendingString("/").stringByAppendingString(ID)
        
        return networkClient.delete(path).attemptMap({ (data, response) -> Result<GenericResponse, ServiceError> in
            return unbox(data)
        })
    }
    
}