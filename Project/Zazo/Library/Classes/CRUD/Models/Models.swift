//
//  Models.swift
//  Zazo
//
//  Created by Server on 26/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import Unbox
import BoltsSwift
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

enum ResponseError: ErrorType {
    case LogicError(response: GenericResponse)
    case OtherError(error: ErrorType)
}

func unbox<T: Unboxable>(data: NSData) -> Task<T> {
    
    let completion = TaskCompletionSource<T>()
    
    GCDQueue.Background.async {
        
        do {
            let result: T = try Unbox(data)
            completion.setResult(result)
        }
        catch let unboxError as UnboxError {
            
            do {
                let genericResponse: GenericResponse = try Unbox(data)
                
                if genericResponse.errors != nil {
                    completion.setError(ResponseError.LogicError(response: genericResponse))
                }
            }
            catch {
                completion.setError(ResponseError.OtherError(error: unboxError))
            }
            
        }
        catch let e {
            completion.setError(ResponseError.OtherError(error: e))
        }
    }
    
    return completion.task
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
