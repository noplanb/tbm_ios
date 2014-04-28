//
//  tbmTests.m
//  tbmTests
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TBMFriend.h"

@interface tbmTests : XCTestCase

@end

@implementation tbmTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

// Note this should really run on an in memory store rather than a persistant store so it can be destroyed and created with each test.
// see - http://iamleeg.blogspot.com/2009/09/unit-testing-core-data-driven-apps.html
// however since the model friend currently goes to the store created by our application and I dont want to refactor this for testing
// it currently goes to the store
- (void)testFriend
{
    NSArray *friends;
    TBMFriend *friend;
    
    [TBMFriend destroyAll];
    friends = [TBMFriend all];
    XCTAssertEqual([friends count], (NSUInteger)0, @"");
    [TBMFriend newWithId:0];
    friends = [TBMFriend all];
    XCTAssertEqual([friends count], (NSUInteger)1, @"");
    for (int i = 1; i<6; i++) {
        [TBMFriend newWithId:@(i)];
    }
    friends = [TBMFriend all];
    XCTAssertEqual([friends count], (NSUInteger)6, @"");
    
    friend = [TBMFriend findWithId:@(0)];
    friend.outgoingVideoStatus = OUTGOING_VIDEO_STATUS_NEW;
    friend = [TBMFriend findWithId:@(0)];
    XCTAssertEqual(friend.outgoingVideoStatus, OUTGOING_VIDEO_STATUS_NEW, @"");
    [TBMFriend destroyAll];
}

@end
