//
//  GetMessageResponse.swift
//  Zazo
//
//  Created by Server on 26/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import Unbox

struct GetMessageResponse {
    
    struct MessageData {
        let transcription: String
    }

    let status: ResponseStatus
    let data: MessageData

}

extension GetMessageResponse: Unboxable {
    init(unboxer: Unboxer) {
        status = unboxer.unbox("status")
        data = unboxer.unbox("data")
    }
}

extension GetMessageResponse.MessageData: Unboxable {
    init(unboxer: Unboxer) {
        transcription = unboxer.unbox("transcription")
    }
}