//
//  NuanceTest.swift
//  Zazo
//
//  Created by Rinat Gabdullin on 27/06/16.
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
    
    
    var exp: XCTestExpectation?
    
    func testManager() {
        
        exp = expectationWithDescription("operation")

        let manager = RecognitionManager(output: self)
        
        manager.registerType(NuanceRecognitionOperation)
        
        guard let resource = NSBundle(forClass: self.classForCoder).URLForResource("test", withExtension: "mov") else {
            XCTFail()
            return
        }

        manager.recognizeFile(resource)
        
        waitForExpectationsWithTimeout(120.0, handler: nil)

    }
    
    func didRecognize(url: NSURL, result: String) {
        print(result)
        exp?.fulfill()
    }
    
    func didFailRecognition(url: NSURL, error: NSError) {
        XCTFail()
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
            print(operation?.result)
            exp.fulfill()
        }
        
        operation?.urlSession = urlSession        
        
        operationQueue.addOperation(operation!)
        
        waitForExpectationsWithTimeout(30.0, handler: nil)
    }

}
