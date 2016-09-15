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
    
    func post(path: String, parameters: [String: AnyObject]? = nil, isFormData: Bool = false) -> SignalProducer<RawResponse, ServiceError> {
        return request("POST",
                       path: path,
                       parameters,
                       encodeAsFormData: isFormData)
    }
    
    func delete(path: String, parameters: [String: String]? = nil) -> SignalProducer<RawResponse, ServiceError> {
        return request("DELETE", path: path, parameters)
    }
    
    private func request(method: String,
                         path: String,
                         _ parameters: [String: AnyObject]?,
                           encodeAsFormData: Bool = false)
        -> SignalProducer<RawResponse, ServiceError> {
        
        let isGetRequest = method == "GET"
        let URLParameters = (isGetRequest && parameters != nil) ? parameters! as! [String:String] : [:]
        
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
                    observer.sendFailed(ServiceError.AnotherError(errorText: "\(error)"))
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
    
    func jsonBody(parameters: [String: AnyObject]) -> NSData? {
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
    
    func formBody(params: [String: AnyObject]) -> NSData {
        
        let body = NSMutableData();
        let boundaryConstant = "----------V2ymHFg03ehbqgZCaKO6jy--";

        for (key, value) in params {
            
            guard value is String else {
                continue
            }
            
            body.appendData("\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);
            body.appendData("Content-Disposition: form-data; name=\"\(key.stringByAddingPercentEncodingWithAllowedCharacters(.symbolCharacterSet())!)\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);
            body.appendData("\(value.stringByAddingPercentEncodingWithAllowedCharacters(.symbolCharacterSet())!)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);
        }
        
        for (key, value) in params {
            
            guard let image = value as? UIImage else {
                continue
            }
            
            let imageData = UIImageJPEGRepresentation(image, 1.0);
            
            body.appendData("\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);
            body.appendData("Content-Disposition: form-data; name=\"\(key)\"; filename=\"image\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);
            body.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);
            body.appendData(imageData!);
            body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);
            body.appendData("\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!);

        }
        
        return body
    }

    
}
