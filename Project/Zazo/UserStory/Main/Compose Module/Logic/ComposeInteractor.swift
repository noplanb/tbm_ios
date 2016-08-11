//
//  ComposeModuleInteractor.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import GCDKit
import ReactiveCocoa

class ComposeInteractor: ComposeLogic {
    
    var output: ComposeLogicOutput?
    var service: MessagesService!
    var friendMkey = ""
    
    func sendMessage(text: String) -> SignalProducer<GenericResponse, ServiceError> {
        return service.post(text, userID: friendMkey)
    }
    
}