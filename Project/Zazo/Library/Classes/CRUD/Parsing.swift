//
//  Parsing.swift
//  Zazo
//
//  Created by Rinat on 13/09/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import Unbox
import Result


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
            
            return .Failure(ServiceError.AnotherError(errorText: unboxError.description))
        }
        catch {
            return .Failure(ServiceError.AnotherError(errorText: unboxError.description))
        }
        
    }
    catch {
        return .Failure(ServiceError.AnotherError(errorText: "\(error)"))
    }
}
