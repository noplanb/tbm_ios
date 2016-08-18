//
//  Models.swift
//  Zazo
//
//  Created by Server on 26/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import Unbox
import ReactiveCocoa
import Result
import GCDKit

enum ResponseStatus: String {
    case Success = "success"
    case Failure = "failure"
    case Unknown
}

struct GenericResponse {
    let status: ResponseStatus
    let errors: [String]?
}

extension GenericResponse: Unboxable {
    init(unboxer: Unboxer) {
        status = unboxer.unbox("status")
        errors = unboxer.unbox("errors")
    }
}

extension ResponseStatus: UnboxableEnum {
    static func unboxFallbackValue() -> ResponseStatus {
        return .Unknown
    }
}

enum ServiceError: ErrorType {
    case InputError(errorText: String)
    case ClientError(response: GenericResponse) // 4XX
    case ServerError(statusCode: Int) // 5XX
    case AnotherError(error: ErrorType)
    case UnknownError
}


func unbox<T: Unboxable>(data: NSData) -> Result<T, ServiceError> {
    
    do {
        let result: T = try Unbox(data)
        
        if let genericResponse = result as? GenericResponse {
            if genericResponse.errors != nil {
                return .Failure(ServiceError.ClientError(response: genericResponse))
            }
            else {
                return .Success(result)
            }
        }
        else {
            return .Success(result)
        }
    }
    catch let unboxError as UnboxError {
        
        do {
            let genericResponse: GenericResponse = try Unbox(data)
            
            if genericResponse.errors != nil {
                return .Failure(ServiceError.ClientError(response: genericResponse))
            }
            
            return .Failure(ServiceError.AnotherError(error: unboxError))
        }
        catch {
            return .Failure(ServiceError.AnotherError(error: unboxError))
        }
        
    }
    catch {
        return .Failure(ServiceError.AnotherError(error: error))
    }
}

enum MessageType: String {
    case Video = "video"
    case Text = "text"
    case Unknown
}

extension MessageType: UnboxableEnum {
    static func unboxFallbackValue() -> MessageType {
        return .Unknown
    }
}
