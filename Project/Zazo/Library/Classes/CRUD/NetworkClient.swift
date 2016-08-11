//
//  NetworkClient.swift
//  Zazo
//
//  Created by Server on 26/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import ReactiveCocoa
import Alamofire

typealias RawResponse = (data: NSData, response: NSHTTPURLResponse)

class NetworkClient: NSObject {
    
    let baseURL = NSURL(string: "http://staging.zazoapp.com")!
    let manager = Alamofire.Manager()
    
    func get(path: String, _ parameters: [String: String]? = nil) -> SignalProducer<RawResponse, ServiceError> {
        return request(.GET, path: path, parameters)
    }
    
    func post(path: String, parameters: [String: String]? = nil) -> SignalProducer<RawResponse, ServiceError> {
        return request(.POST, path: path, parameters)
    }
    
    func delete(path: String, parameters: [String: String]? = nil) -> SignalProducer<RawResponse, ServiceError> {
        return request(.DELETE, path: path, parameters)
    }
    
    private func request(method: Alamofire.Method,
                         path: String,
                         _ parameters: [String: String]?) -> SignalProducer<RawResponse, ServiceError> {
        
        return SignalProducer<RawResponse, ServiceError> {
            observer, disposable in
            
            let encoding: ParameterEncoding = {
                switch method {
                case .GET:
                    return .URL
                default:
                    return .JSON
                }
            }()
            
            
            self.manager.request(method,
                NSURL(string: path, relativeToURL: self.baseURL)!,
                parameters: parameters,
                encoding: encoding,
                headers: nil)
                
                .authenticate(usingCredential: self.credential()!)
                .response { (request, response, data, error) in
                    
                    guard (error == nil) else {
                        observer.sendFailed(ServiceError.AnotherError(error: error!))
                        return
                    }
                    
                    if let data = data, let response = response {
                        observer.sendNext(RawResponse(data, response))
                        observer.sendCompleted()
                        return
                    }
                    
                    observer.sendFailed(ServiceError.UnknownError)
            }
        }
    }
    
    func credential() -> NSURLCredential? {
        
//        return NSURLCredential(user: "rCjSwpr9R9KaCnL7gRdf",
//                               password: "Gk2I2Y54DsdS3qPFtpBE",
//                               persistence: .ForSession)
        
        
        let password = ZZStoredSettingsManager.shared().authToken
        let username = ZZStoredSettingsManager.shared().userID
    
        return NSURLCredential(user: username,
                               password: password,
                               persistence: .ForSession)        
    }
    
}
