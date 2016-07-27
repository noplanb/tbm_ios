//
//  ComposeLogic.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import BoltsSwift

protocol ComposeLogicOutput {

}

protocol ComposeLogic {
    
    func getAllMessages() -> Task<GetAllMessagesResponse>
    func get(byID ID: String) -> Task<GetMessageResponse>
    func sendMessage(text: String) -> Task<GenericResponse>?
    func deleteMessage(byID ID: Int) -> Task<GenericResponse>
    
}