//
//  RecognitionManager.swift
//  Zazo
//
//  Created by Server on 27/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

public protocol RecognitionManagerOutput {
    
    func didRecognize(result: String)
    func didFailRecognition(url: NSURL, error: NSError)

}

public class RecognitionManager {
    
    public typealias operationType = RecognitionOperation.Type
    
    let output: RecognitionManagerOutput
    
    var operationQueue = NSOperationQueue()
    
    var operationTypes = Array<operationType>()
    
    init(handler: RecognitionManagerOutput) {
        self.output = handler
    }
    
    public init(output: RecognitionManagerOutput) {

        self.output = output
        
    }
    
    public func registerType(type: operationType) {
        
        operationTypes.append(type)
        
    }
    
    public func recognizeFile(url: NSURL) {
        
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
            
            operationQueue.addOperation(operation)
            return
        }
            
        output.didFailRecognition(url, error: genericError())
        
    }
    
    func operationCompleted(operation: RecognitionOperation) {
        
    }
    
    func genericError() -> NSError {
        
        return NSError(domain: "Zazo", code: 1, userInfo: nil)
        
    }
}