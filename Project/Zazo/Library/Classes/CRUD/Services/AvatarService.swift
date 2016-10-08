//
//  AvatarService.swift
//  Zazo
//
//  Created by Rinat on 13/09/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Result

class AvatarData: NSObject {
    var timestamp: NSInteger = 0
    var isAvatarEnabled = false
}

class ConcreteAvatarService: NSObject, AvatarService, LegacyAvatarService {
    
    var networkClient: NetworkClient! = nil
    let path = "api/v1/avatars"
    
    func get() -> SignalProducer<GetAvatarResponse, ServiceError> {
        return networkClient.get(path).attemptMap({ (data, response) -> Result<GetAvatarResponse, ServiceError> in
            return unbox(data)
        })
    }
    
    func delete() -> SignalProducer<GenericResponse, ServiceError> {
        return networkClient.delete(path).attemptMap({ (data, response) -> Result<GenericResponse, ServiceError> in
            return unbox(data)
        })
    }
    
    func set(avatar: UIImage) -> SignalProducer<GenericResponse, ServiceError> {
        
        let parameters: [String: AnyObject] =
            ["use_as_thumbnail": "avatar",
             "avatar": avatar]

        return networkClient.post(path, parameters: parameters, isFormData: true).attemptMap({ (data, response) -> Result<GenericResponse, ServiceError> in
            return unbox(data)
        })
    }

    func legacyGet() -> RACSignal! {
        
        let signal = get().map { (response) -> AvatarData in
            let data = AvatarData()
            data.timestamp = response.data.timestamp ?? 0
            data.isAvatarEnabled = response.data.useAsThumbnail == .Avatar
            return data
        }
        
        return signal.toRACSignal()
    }
    
    func legacyDelete() -> RACSignal! {
        
        let signal = delete().map({ (response) -> NSNumber in
            return NSNumber(bool: response.status == .Success)
        })
        
        return signal.toRACSignal()
    }
    
    func legacySet(image: UIImage!) -> RACSignal! {
        
        let signal = set(image).map({ (response) -> NSNumber in
            return NSNumber(bool: response.status == .Success)
        })
        
        return signal.toRACSignal()
    }
    
}
