//
//  tbmTests.m
//  tbmTests
//
//  Created by Sani Elfishawy on 4/24/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TBMKeychainWrapper.h"

@interface KeyChainWrapperTests : XCTestCase

@end

@implementation KeyChainWrapperTests

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

- (void)test1{
    NSString *key = @"TBMmykey";
    NSString *result;
    
    [TBMKeyChainWrapper deleteItem:key];
    result = [TBMKeyChainWrapper getItem:key];
    XCTAssertEqualObjects(result, nil);
    
    
    [TBMKeyChainWrapper putItem:key value:@"my_Value"];
    result = [TBMKeyChainWrapper getItem:key];
    XCTAssertEqualObjects(result, @"my_Value");
    
    [TBMKeyChainWrapper putItem:key value:@"myValue2"];
    result = [TBMKeyChainWrapper getItem:key];
    XCTAssertEqualObjects(result, @"myValue2");

    [TBMKeyChainWrapper deleteItem:key];
    result = [TBMKeyChainWrapper getItem:key];
    XCTAssertEqualObjects(result, nil);
}

@end
