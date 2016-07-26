//
//  ZazoTests.swift
//  ZazoTests
//
//  Created by Rinat on 21/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

import XCTest

@testable import Zazo

class ZazoTests: XCTestCase {
    
    let service = ConcreteMessagesService(client: NetworkClient())
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {

        let e = expectationWithDescription("1")
        
        service.delete(by: 1469552394).continueWith { task  in
            
            e.fulfill()
        }
        
        waitForExpectationsWithTimeout(322, handler: nil)
    }
    
}
