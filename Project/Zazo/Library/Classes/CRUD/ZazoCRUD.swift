//
//  ZazoCRUD.swift
//  Zazo
//
//  Created by Rinat on 21/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import BoltsSwift

protocol MessagesService: NSObjectProtocol {
    func get() -> Task<GetAllMessagesResponse>
    func get(by ID: String) -> Task<GetMessageResponse>
    func post(text: String, userID: String) -> Task<GenericResponse>
    func delete(by ID: Int) -> Task<GenericResponse>
}

//struct API {    
//    let messages: MessagesService
//}