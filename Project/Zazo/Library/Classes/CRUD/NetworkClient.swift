//
//  NetworkClient.swift
//  Zazo
//
//  Created by Server on 26/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import ReactiveCocoa

typealias RawResponse = (data: NSData, response: NSHTTPURLResponse)

class NetworkClient: NSObject {
    
    var baseURL: NSURL!
    
    func get(path: String, _ parameters: [String: String]? = nil) -> SignalProducer<RawResponse, ServiceError> {
        return request("GET", path: path, parameters)
    }
    
    func post(path: String, parameters: [String: String]? = nil) -> SignalProducer<RawResponse, ServiceError> {
        return request("POST", path: path, parameters)
    }
    
    func delete(path: String, parameters: [String: String]? = nil) -> SignalProducer<RawResponse, ServiceError> {
        return request("DELETE", path: path, parameters)
    }
    
    private func request(method: String,
                         path: String,
                         _ parameters: [String: String]?) -> SignalProducer<RawResponse, ServiceError> {
        
        let isGetRequest = method == "GET"
        let URLParameters = (isGetRequest && parameters != nil) ? parameters! : [:]
        
        guard let URL = url(path, parameters: URLParameters) else {
            let error = ServiceError.InputError(errorText: "URL is nil")
            return SignalProducer<RawResponse, ServiceError>(error: error)
        }
        
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = method
        request.allHTTPHeaderFields!["Content-Type"] = "application/json"

        if (!isGetRequest && parameters != nil) {
            request.HTTPBody = jsonBody(parameters!)
        }
        
        return SignalProducer<RawResponse, ServiceError> {
            observer, disposable in
            
            NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
                
                guard (error == nil) else {
                    observer.sendFailed(ServiceError.AnotherError(error: error!))
                    return
                }
                
                if let data = data, let response = response as? NSHTTPURLResponse {
                    observer.sendNext(RawResponse(data, response))
                    observer.sendCompleted()
                    return
                }
                
                observer.sendFailed(ServiceError.UnknownError)
            }).resume()
            
        }
    }
    
    func jsonBody(parameters: [String: String]) -> NSData? {
        return try? NSJSONSerialization.dataWithJSONObject(parameters, options: [])
    }
    
    func url(path: String, parameters: [String: String]) -> NSURL? {
        
        guard let URL = NSURL(string: path, relativeToURL: self.baseURL) else {
            return nil
        }
        
        let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true)!
        
        components.queryItems = parameters.map({ (key, value) -> NSURLQueryItem in
            return NSURLQueryItem(name: key, value: value)
        })
    
        return components.URL
    }
    
    func credential() -> NSURLCredential? {
        
        let password = ZZStoredSettingsManager.shared().authToken
        let username = ZZStoredSettingsManager.shared().userID
    
        return NSURLCredential(user: username,
                               password: password,
                               persistence: .ForSession)        
    }
    
}
