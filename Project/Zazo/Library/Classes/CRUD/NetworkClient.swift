//
//  NetworkClient.swift
//  Zazo
//
//  Created by Server on 26/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import BoltsSwift
import Alamofire

typealias RawResponse = (data: NSData, response: NSHTTPURLResponse)

class NetworkClient: NSObject {
    
    let baseURL = NSURL(string: "http://staging.zazoapp.com")!
    
    let manager = Alamofire.Manager()
    
    func get(path: String, _ parameters: [String: String]? = nil) -> Task<RawResponse> {
        return request(.GET, path: path, parameters)
    }
    
    func post(path: String, parameters: [String: String]? = nil) -> Task<RawResponse> {
        return request(.POST, path: path, parameters)
    }
    
    func delete(path: String, parameters: [String: String]? = nil) -> Task<RawResponse> {
        return request(.DELETE, path: path, parameters)
    }
    
    private func request(method: Alamofire.Method,
                         path: String,
                         _ parameters: [String: String]?) -> Task<RawResponse> {
        
        let completion = TaskCompletionSource<RawResponse>()
        
        let encoding: ParameterEncoding = {
            switch method {
            case .GET:
                return .URL
            default:
                return .JSON
            }
        }()
        
        
        manager.request(method,
            NSURL(string: path, relativeToURL: baseURL)!,
            parameters: parameters,
            encoding: encoding,
            headers: headers())
            
            .authenticate(usingCredential: credential()!)
            .response { (request, response, data, error) in
                
                guard (error == nil) else {
                    completion.setError(error!)
                    return
                }
                
                if let data = data, let response = response {
                    completion.setResult(RawResponse(data, response))
                    return
                }
                
                abort()
        }
        
        return completion.task
    }
    
    func headers() -> [String: String]? {
        return nil
    }
    
    func credential() -> NSURLCredential? {
        
        return NSURLCredential(user: "rCjSwpr9R9KaCnL7gRdf",
                               password: "Gk2I2Y54DsdS3qPFtpBE",
                               persistence: .ForSession)

//        let defaults = NSUserDefaults.standardUserDefaults()
//        
//        guard
//            let username = defaults.objectForKey("mkey") as? String,
//            let password = defaults.objectForKey("auth") as? String
//            else {
//                return nil
//        }
//        
//        return NSURLCredential(user: username,
//                               password: password,
//                               persistence: .ForSession)
        
        
    }
    
}
