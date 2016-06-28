//
//  NuanceTest.swift
//  Zazo
//
//  Created by Server on 27/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import XCTest
import AVFoundation

class NuanceTest: XCTestCase, RecognitionManagerOutput {

    let operationQueue = NSOperationQueue()
    var urlSession = NSURLSession()

    
    override func setUp() {
        super.setUp()

        urlSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
                                  delegate: NuanceURLSessionHandler(),
                                  delegateQueue: operationQueue)
    }
    
    override func tearDown() {

        super.tearDown()
    }
    
    
    func testManager() {
        
        let exp = expectationWithDescription("operation")

        let manager = RecognitionManager(output: self)
        
        manager.registerType(NuanceRecognitionOperation)
        
        guard let resource = NSBundle(forClass: self.classForCoder).URLForResource("test", withExtension: "mp4") else {
            XCTFail()
            return
        }

        manager.recognizeFile(resource)
        
        waitForExpectationsWithTimeout(30.0, handler: nil)

    }
    
    func didRecognize(result: String) {
        
    }
    
    func didFailRecognition(url: NSURL, error: NSError) {
        
    }

    func stestExample() {

        let exp = expectationWithDescription("operation")
        
        guard let resource = NSBundle(forClass: self.classForCoder).URLForResource("vid_from_1465930091964_16000", withExtension: "pcm") else {
            XCTFail()
            return
        }
        
        let operation = NuanceRecognitionOperation(url: resource)
        
        operation?.apiData = NuanceAPIData.sandboxData
        
        operation?.completionBlock = {
            exp.fulfill()
        }
        
        operation?.urlSession = urlSession        
        
        operationQueue.addOperation(operation!)
        
        waitForExpectationsWithTimeout(30.0, handler: nil)
    }

}
