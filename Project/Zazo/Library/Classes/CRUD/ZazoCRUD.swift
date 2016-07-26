//
//  ZazoCRUD.swift
//  Zazo
//
//  Created by Rinat on 21/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import BoltsSwift
import Unbox

protocol MessagesService: NSObjectProtocol {
    func get() -> Task<GetAllMessagesResponse>
    func get(by ID: String) -> Task<GetMessageResponse>
    func post(text: String, userID: String) -> Task<GenericResponse>
    func delete(by ID: Int) -> Task<GenericResponse>
}

struct API {
    let messages: MessagesService
}

class ConcreteMessagesService: NSObject, MessagesService {

    let networkClient: NetworkClient
    
    let servicePath = "api/v1/messages"
    
    init(client: NetworkClient) {
        self.networkClient = client
        super.init()
    }
    
    func get() -> Task<GetAllMessagesResponse> {
        return networkClient.get(servicePath).continueOnSuccessWithTask { (response) -> Task<GetAllMessagesResponse> in
            return unbox(response.data)
        }
    }
    
    func get(by ID: String) -> Task<GetMessageResponse> {
        
        let path = servicePath.stringByAppendingString("/\(ID)")
        
        return networkClient.get(path).continueOnSuccessWithTask { (response) -> Task<GetMessageResponse> in
            return unbox(response.data)
        }
    }
    
    func post(text: String, userID: String) -> Task<GenericResponse> {
        
        let params = ["body": text, "type": "text", "receiver_mkey": userID]
        
        return networkClient.post(servicePath, parameters: params).continueOnSuccessWithTask { (response) -> Task<GenericResponse> in
            return unbox(response.data)
        }

    }

    func delete(by ID: Int) -> Task<GenericResponse> {
        return networkClient.get(servicePath).continueOnSuccessWithTask { (response) -> Task<GenericResponse> in
            return unbox(response.data)
        }
    }
    
}

