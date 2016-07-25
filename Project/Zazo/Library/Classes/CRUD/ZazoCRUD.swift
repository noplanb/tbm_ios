//
//  ZazoCRUD.swift
//  Zazo
//
//  Created by Rinat on 21/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import PromiseKit

struct PromiseResult<T> {
    let result: Promise<Result<T>>
}

enum Result<T> {
    case Success(T)
    case Failure(NSError)
}

//enum APIEndpoint {
//
//    case messageGetAll
//    case messageGetByID(Int)
//    case messagePost(text: NSString, userID: NSString)
//    case messageDeleteByID(Int)
//
//}

enum APIEndpoint {
    enum Method {
        case getAll
        case getByID(Int)
        case post(text: NSString, userID: NSString)
        case deleteByID(Int)
    }
    
    case Messages(Method)
}

protocol MessagesService: NSObjectProtocol {
    func get() -> PromiseResult<MessagesResponse>
    func get(by ID: String) -> PromiseResult<MessagesResponse>
    func post(text: NSString, userID: NSString) -> PromiseResult<Response>
    func delete(by ID: Int) -> PromiseResult<Response>
}

struct CRUD {
    let messages: MessagesService
}


class Response: NSObject {
    
}

class MessagesResponse: Response {
    
}

class ConcreteMessagesService: NSObject, MessagesService {

    func get() -> PromiseResult<MessagesResponse> {
        let client = NetworkClient(url: NSURL())
        
        client.makeRequest(for: APIEndpoint.Messages(.getAll))
        
    }
    
    func get(by ID: String) -> PromiseResult<MessagesResponse> {
        
    }
    
    func post(text: NSString, userID: NSString) -> PromiseResult<Response> {
        
    }
    
    func delete(by ID: Int) -> PromiseResult<Response> {
        
    }
    
}

class NetworkClient: NSObject {
    
    enum HTTPMethod {
        case GET
        case POST
        case DELETE
    }
    
    let baseURL: NSURL
    
    init(url: NSURL) {
        baseURL = url
        super.init()
    }
    
    func makeRequest(for endpoint: APIEndpoint) -> NSURLRequest {
        
//        var path: String!
//        var parameters: [[String: String]]
//        var method: HTTPMethod!
        
        var request: NSURLRequest?
        
        switch endpoint {
            case .Messages(let messages):
            
                request = makeRequest(forMessages: messages)
        }
        
        return request!
    }
    
    func makeRequest(forMessages endpoint: APIEndpoint.Method) -> NSURLRequest {
        
    }
}
