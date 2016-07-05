//
//  RecognitionManager.swift
//  Zazo
//
//  Created by Rinat Gabdullin on 27/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

@objc public protocol RecognitionManagerOutput {
    
    func didRecognize(url: NSURL, result: String)
    func didFailRecognition(url: NSURL, error: NSError)

}

@objc public class RecognitionManager: NSObject {
    
    public typealias operationType = RecognitionOperation.Type
    
    let output: RecognitionManagerOutput
    
    let urlSession: NSURLSession
    
    var operationQueue = NSOperationQueue()
    
    var operationTypes = Array<operationType>()
    
    public init(output: RecognitionManagerOutput) {
        
        operationQueue.qualityOfService = .UserInitiated
        
        urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                                  delegate: NuanceURLSessionHandler(),
                                  delegateQueue: operationQueue)
        
        self.output = output
        
        super.init()
        
        registerType(NuanceRecognitionOperation)
        
    }
    
    public func registerType(type: operationType) {
        
        operationTypes.append(type)
        
    }
    
    public func recognizeFile(url: NSURL) {
        
        print("started", NSDate())
        
        var operation: RecognitionOperation?
        
        for type in operationTypes {
            
            operation = type.init(url: url)
            
            if operation != nil {
                break
            }
        }
        
        if let operation = operation {

            operation.completionBlock = {
                self.operationCompleted(operation)
            }
            
            if let operation = operation as? NuanceRecognitionOperation {
                operation.urlSession = urlSession
                operation.apiData = NuanceAPIData.sandboxData
            }
            
            operationQueue.addOperation(operation)
            return
        }
            
        output.didFailRecognition(url, error: genericError())
        
    }
    
    func operationCompleted(operation: RecognitionOperation) {
        
        print("finished", NSDate())
        
        if let error = operation.error {
            output.didFailRecognition(operation.fileURL, error: error)
            
        } else {
            output.didRecognize(operation.fileURL, result: operation.result!)
        }
        
    }
    
    func genericError() -> NSError {
        
        return NSError(domain: "Zazo", code: 1, userInfo: nil)
        
    }
}