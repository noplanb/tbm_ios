//
//  ComposeLogic.swift
//  Zazo
//
//  Created by Rinat on 30/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import ReactiveCocoa

protocol ComposeLogicOutput {

}

protocol ComposeLogic {
    func sendMessage(text: String) -> SignalProducer<GenericResponse, ServiceError>
}