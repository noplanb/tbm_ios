//
//  ZZLoadFriendListTest.m
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ZZFriendsTransportService.h"

@interface ZZLoadFriendListTest : XCTestCase

@end

@implementation ZZLoadFriendListTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testLoadFriendList
{
    XCTestExpectation* exp = [self expectationWithDescription:@"load friend list"];
    
    [[ZZFriendsTransportService loadFriendList] subscribeNext:^(id x) {
        
    } error:^(NSError *error) {
        NSInteger userNotAuthorizedError = 3840;
        XCTAssertEqual(error.code, userNotAuthorizedError);
        [exp fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:6 handler:^(NSError *error) {
        XCTAssertNil(error);
    }];

}

@end
