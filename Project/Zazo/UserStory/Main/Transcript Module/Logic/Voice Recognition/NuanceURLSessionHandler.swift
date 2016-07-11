//
//  NuanceURLSessionHandler.swift
//  Zazo
//
//  Created by Rinat on 27/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation

protocol NuanceTask {
    
    func makeInputStream() -> NSInputStream?
    func networkTaskCompleted(data: NSData)
    func networkTaskFailed(error: NSError?)
    
}

public class NuanceURLSessionHandler: NSObject, NSURLSessionTaskDelegate {
    
    var responses = Dictionary<NSURLSessionTask, NSMutableData>()
    
    // MARK: NSURLSessionTaskDelegate
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, needNewBodyStream completionHandler: (NSInputStream?) -> Void) {
      
        guard let nuanceTask = findNuanceTask(for: task, in: session.delegateQueue) else {
            return
        }
        
        let stream = nuanceTask.makeInputStream()
        
        completionHandler(stream)

    }
    
    public func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        
        guard let data = responses[task] else {
            return
        }
        
        guard let nuanceTask = findNuanceTask(for: task, in: session.delegateQueue) else {
            return
        }
        
        guard error == nil else {
            nuanceTask.networkTaskFailed(error)
            return
        }
        
        guard let response = task.response as? NSHTTPURLResponse else {
            return
        }
        
        if response.statusCode >= 500 {
            nuanceTask.networkTaskFailed(error)
            return
        }
        
        nuanceTask.networkTaskCompleted(data)        
    }
    
    public func URLSession(session: NSURLSession, dataTask: NSURLSessionDataTask, didReceiveData aData: NSData)
    {
        var data = responses[dataTask]
        
        if data == nil {
            data = NSMutableData()
            responses[dataTask] = data
        }
        
        data?.appendData(aData)
    }
    
    // MARK: Support methods
    
    func findNuanceTask(for networkTask: NSURLSessionTask, in queue: NSOperationQueue) -> NuanceTask? {
        
        for operation in queue.operations {
            
            guard let nuanceOperation = operation as? NuanceRecognitionOperation else {
                continue
            }
            
            guard nuanceOperation.task == networkTask else {
                continue
            }
            
            return nuanceOperation
        }
        
        return nil
    }
}
