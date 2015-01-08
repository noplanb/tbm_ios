//
//  TBMDispatchTests.m
//  tbm
//
//  Created by Sani Elfishawy on 1/6/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TBMDispatch.h"

@interface TBMDispatchTests : XCTestCase

@end

@implementation TBMDispatchTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardow@usern code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    [TBMDispatch dispatch: @"this is a test message"];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
