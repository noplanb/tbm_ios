//
//  ZazoCRUD.swift
//  Zazo
//
//  Created by Rinat on 21/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import PromiseKit
import Alamofire
import Unbox

let serverURL = NSURL(string: "http://staging.zazoapp.com/")

struct PromiseResult<T> {
    let result: Promise<Result<T>>
}

enum Result<T> {
    case Success(T)
    case Failure(NSError)
}

protocol MessagesService: NSObjectProtocol {
    func get() -> PromiseResult<MessagesResponse>
//    func get(by ID: String) -> PromiseResult<MessagesResponse>
//    func post(text: NSString, userID: NSString) -> PromiseResult<Response>
//    func delete(by ID: Int) -> PromiseResult<Response>
}

struct CRUD {
    let messages: MessagesService
}


class ConcreteMessagesService: NSObject, MessagesService {

    let networkClient: NetworkClient
    
    init(client: NetworkClient) {
        self.networkClient = client
        super.init()
    }
    
    func get() -> PromiseResult<MessagesResponse> {
        
        when(promises: [networkClient.get("api/v1/messages/")])
        
        
    }
    
//    func get(by ID: String) -> PromiseResult<MessagesResponse> {
//        
//    }
//    
//    func post(text: NSString, userID: NSString) -> PromiseResult<Response> {
//        
//    }
//    
//    func delete(by ID: Int) -> PromiseResult<Response> {
//        
//    }
    
}

typealias RawResponse = (data: NSData, response: NSHTTPURLResponse)

class NetworkClient: NSObject {
    
    let baseURL: NSURL
    
    init(url: NSURL) {
        baseURL = url
        super.init()
    }
    
    let manager = Alamofire.Manager()
    
    func get(path: String, _ parameters: [String: String]?) -> Promise<RawResponse> {
        return request(.GET, path: path, parameters)
    }
    
    func post(path: String, parameters: [String: String]?) -> Promise<RawResponse> {
        return request(.POST, path: path, parameters)
    }
    
    func delete(path: String, parameters: [String: String]?) -> Promise<RawResponse> {
        return request(.DELETE, path: path, parameters)
    }
    
    private func request(method: Alamofire.Method, path: String, _ parameters: [String: String]?) -> Promise<RawResponse> {
        
        let encoding: ParameterEncoding = {
            switch method {
            case .GET:
                return .URL
            default:
                return .JSON
            }
        }()
        
        return Promise { fullfill, reject in
            
            manager.request(method,
                path,
                parameters: parameters,
                encoding: encoding,
                headers: headers())
                
                .authenticate(usingCredential: credential()!)
                .response { (request, response, data, error) in
                    
                    guard (error == nil) else {
                        reject(error!)
                        return
                    }
                    
                    if let data = data, let response = response {
                        fullfill(RawResponse(data, response))
                        return
                    }
                    
                    abort()
            }
        }
    }
    
    func headers() -> [String: String] {
        
    }
    
    func credential() -> NSURLCredential? {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        
        guard
            let username = defaults.objectForKey("mkey") as? String,
            let password = defaults.objectForKey("auth") as? String
            else {
                return nil
        }
        
        return NSURLCredential(user: username,
                               password: password,
                               persistence: .ForSession)
        
        
    }
    
}
