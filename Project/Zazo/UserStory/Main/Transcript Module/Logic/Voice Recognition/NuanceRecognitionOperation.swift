//
//  NuanceRecognitionOperation.swift
//  Zazo
//
//  Created by Rinat Gabdullin on 27/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import Foundation
import Alamofire

class NuanceRecognitionOperation: RecognitionOperation, NuanceTask {
    
    static let extractor = AudioExtractor()
    
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
        
        if let data = NuanceRecognitionOperation.extractor.extractRawAudio(fileURL) {
            return NSInputStream(data: data)
        }
        
        return nil
    }
    
    func networkTaskCompleted(data: NSData) {
        let result = String(data: data, encoding: NSUTF8StringEncoding)
        
        self.result = result?.componentsSeparatedByString("\n").first
        
        state = .Finished
    }
    
    func networkTaskFailed(error: NSError?) {
        self.error = error
        didFailRecognition()
    }
    
    func request() -> NSURLRequest? {
        
        guard let url = url() else {
            return nil
        }
        
        let request = NSMutableURLRequest(URL: url)
        
        request.HTTPMethod = "POST"
        request.addValue("audio/x-wav;codec=pcm;bit=16;rate=8000", forHTTPHeaderField: "Content-Type")
        request.addValue("en_us", forHTTPHeaderField: "Accept-Language")
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
        
        if self.error == nil {
            error = NSError(domain: "Zazo", code: 0, userInfo: nil)
        }
        
        state = .Finished
    }
}

