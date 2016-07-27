//
//  ComposeModuleInteractor.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import GCDKit
import BoltsSwift

class ComposeInteractor: ComposeLogic {
    
    var output: ComposeLogicOutput?
    var service: MessagesService!
    var friendMkey = ""
    
    func getAllMessages() -> Task<GetAllMessagesResponse> {
        return service.get().continueWithTask(Executor.MainThread, continuation: { (task) -> Task<GetAllMessagesResponse> in
            return task
        })
    }
    
    func get(byID ID: String) -> Task<GetMessageResponse> {
        return service.get(by: ID).continueWithTask(Executor.MainThread, continuation: { (task) -> Task<GetMessageResponse> in
            return task
        })
    }
    
    func sendMessage(text: String) -> Task<GenericResponse>? {
        
        return service.post(text, userID: friendMkey).continueWithTask(Executor.MainThread, continuation: { (task) -> Task<GenericResponse> in
            return task
        })
    }
    
    func deleteMessage(byID ID: Int) -> Task<GenericResponse> {
        return service.delete(by: ID).continueWithTask(Executor.MainThread, continuation: { (task) -> Task<GenericResponse> in
            return task
        })
    }
    
}