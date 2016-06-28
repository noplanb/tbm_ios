//
//  NuanceRecognitionOperation.swift
//  Zazo
//
//  Created by Server on 27/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import Alamofire

class NuanceRecognitionOperation: RecognitionOperation, NuanceTask {
    
    var urlSession: NSURLSession?
    var apiData: NuanceAPIData?
    var task: NSURLSessionUploadTask?
    
    override func start() {
        
        guard let urlSession = self.urlSession else {
            print("urlSession not set")
            didFailRecognition()
            return
        }
        
        guard let request = request() else {
            print("Couldn't make a request")
            didFailRecognition()
            return
        }
        
        task = urlSession.uploadTaskWithStreamedRequest(request)
        
        task?.resume()
        
        self.state = .Executing
    }

    override func cancel() {
        task?.cancel()
        state = .Finished
    }
    
    func makeInputStream() -> NSInputStream? {
        return NSInputStream(URL: fileURL)
    }
    
    func networkTaskCompleted(data: NSData) {
        result = NSString(data: data, encoding: NSUTF8StringEncoding)
        state = .Finished
    }
    
    func networkTaskFailed(error: NSError) {
        self.error = error
        state = .Finished
    }
    
    func request() -> NSURLRequest? {
        
        guard let url = url() else {
            return nil
        }
        
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.addValue("audio/x-wav;codec=pcm;bit=16;rate=16000", forHTTPHeaderField: "Content-Type")
        request.addValue("en-US", forHTTPHeaderField: "Accept-Language")
        request.addValue("chunked", forHTTPHeaderField: "Transfer-Encoding")
        request.addValue("text/plain", forHTTPHeaderField: "Accept")
        request.addValue("Dictation", forHTTPHeaderField: "Accept-Topic")
        
        return request
    }
    
    func url() -> NSURL? {

        guard let apiData = self.apiData else {
            print("self.apiData not set")
            return nil
        }

        let string = "https://dictation.nuancemobility.net:443/NMDPAsrCmdServlet/dictation?appId=\(apiData.appId)&appKey=\(apiData.appKey)&id=\(apiData.asrKey)"
        
        return NSURL(string: string)
    }
    
    func didFailRecognition() {
        
    }
}

