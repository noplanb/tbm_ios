//
//  tbmTests.m
//  tbmTests
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TBMFriend.h"
#import "TBMVideo.h"

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

- (void)videoTest{
    TBMFriend *friend = [TBMFriend  newWithId:@(1)];
    for (int i=0; i<5; i++) {
        TBMVideo *v = [TBMVideo newWithFriend:friend videoId:@"asdf"];
        NSLog(@"video = %@", v);
    }
    NSLog(@"Friend %@", friend);
    XCTFail(@"Fail");
    NSLog(@"Video count = %lu", (unsigned long)[TBMVideo count]);
}

@end
