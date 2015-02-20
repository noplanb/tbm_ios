//
//  StringUtilsTest.m
//  Zazo
//
//  Created by Sani Elfishawy on 2/19/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TBMStringUtils.h"

@interface StringUtilsTest : XCTestCase

@end

@implementation StringUtilsTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    NSString *valueJson = @"{\"videoId\":\"1424297090233\"}";
    NSDictionary *valueObj = [TBMStringUtils dictionaryWithJson:valueJson];
    NSLog(@"%@", valueObj);

    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
