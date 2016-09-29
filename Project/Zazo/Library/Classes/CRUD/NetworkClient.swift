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
    
    var baseURL: NSURL!
    
    func get(path: String, _ parameters: [String: String]? = nil) -> SignalProducer<RawResponse, ServiceError> {
        return request(.GET, path: path, parameters)
    }
    
    func post(path: String, parameters: [String: AnyObject]? = nil, isFormData: Bool = false) -> SignalProducer<RawResponse, ServiceError> {
        return request(.POST,
                       path: path,
                       parameters,
                       encodeAsFormData: isFormData)
    }
    
    func delete(path: String, parameters: [String: String]? = nil) -> SignalProducer<RawResponse, ServiceError> {
        return request(.DELETE, path: path, parameters)
    }
    
    private func request(method: Alamofire.Method,
                         path: String,
                         _ parameters: [String: AnyObject]?,
                           encodeAsFormData: Bool = false)
        -> SignalProducer<RawResponse, ServiceError> {
        
            return SignalProducer<RawResponse, ServiceError> {
                observer, disposable in
                
                guard let path = NSURL(string: path, relativeToURL: self.baseURL) else {
                    observer.sendFailed(ServiceError.InputError(errorText: "Invalid path"))
                    return
                }
                
                var request: Alamofire.Request! = nil
                
                let sendBlock = {
                    if let credentials = self.credentials() {
                        request.authenticate(usingCredential: credentials)
                    }
                    request.response(completionHandler: { (request, response, data, error) in
                        
                        guard (error == nil) else {
                            observer.sendFailed(ServiceError.AnotherError(errorText: "\(error)"))
                            return
                        }
                        
                        if let data = data, let response = response {
                            observer.sendNext(RawResponse(data, response))
                            observer.sendCompleted()
                            return
                        }
                        
                        observer.sendFailed(ServiceError.UnknownError)
                    })
                }
                
                if encodeAsFormData {
                    guard let parameters = parameters else {
                        return
                    }
                    let data = self.multipartData(parameters)
                    
                    Alamofire.upload(.POST, path, headers: nil, multipartFormData: data, encodingMemoryThreshold: Manager.MultipartFormDataEncodingMemoryThreshold) {result in
                    
                        switch result {
                        case .Success(let postRequest, _, _):
                            request = postRequest
                        default: break
                        }
                        
                        sendBlock()
                    }
                }
                else {
                    request = Alamofire.request(method, path, parameters: parameters, encoding: .JSON, headers: nil)
                    sendBlock()
                }
                
            }
    }

    func multipartData(parameters: [String: AnyObject]) -> (MultipartFormData -> Void) {
        
        return { (formData) in
            for (key, value) in parameters {
                if let image = value as? UIImage {
                    guard let data = UIImagePNGRepresentation(image) else {
                        continue
                    }
                    formData.appendBodyPart(data: data, name: key, fileName: "\(key).png", mimeType: "image/png")
                }
                if let text = value as? String {
                    guard let data = text.dataUsingEncoding(NSUTF8StringEncoding) else {
                        continue
                    }
                    formData.appendBodyPart(data: data, name: key)
                }
            }
        }
        
    }

    func credentials() -> NSURLCredential? {
        
        let password = ZZStoredSettingsManager.shared().authToken
        let username = ZZStoredSettingsManager.shared().userID
    
        return NSURLCredential(user: username,
                               password: password,
                               persistence: .ForSession)        
    }

    
}
