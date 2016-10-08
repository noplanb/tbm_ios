//
//  GetAvatarResponse.swift
//  Zazo
//
//  Created by Rinat on 15/09/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import Unbox

struct GetAvatarResponse {
    
    struct AvatarData {
        
        enum UseAsThumbnail: String {
            case LastFrame = "last_frame"
            case Avatar = "avatar"
        }
        
        let timestamp: Int?
        let useAsThumbnail: UseAsThumbnail?
    }
    
    let status: ResponseStatus
    let data: AvatarData

}

extension GetAvatarResponse: Unboxable {
    init(unboxer: Unboxer) {
        status = unboxer.unbox("status")
        data = unboxer.unbox("data")
    }
}

extension GetAvatarResponse.AvatarData: Unboxable {
    init(unboxer: Unboxer) {
        timestamp = unboxer.unbox("timestamp")
        useAsThumbnail = unboxer.unbox("use_as_thumbnail")
    }
}

extension GetAvatarResponse.AvatarData.UseAsThumbnail: UnboxableEnum {
    static func unboxFallbackValue() -> GetAvatarResponse.AvatarData.UseAsThumbnail {
        return .Avatar
    }
}
