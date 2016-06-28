//
//  NuanceTest.swift
//  Zazo
//
//  Created by Server on 27/06/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import XCTest

class NuanceTest: XCTestCase {

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

    func testExample() {

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

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }

}
