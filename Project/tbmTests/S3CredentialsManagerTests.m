//
//  S3CredentialsManagerTests.m
//  tbm
//
//  Created by Sani Elfishawy on 1/5/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TBMS3CredentialsManager.h"
#import "TBMKeyChainWrapper.h"

@interface S3CredentialsManagerTests : XCTestCase

@end

@implementation S3CredentialsManagerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test {
    [TBMS3CredentialsManager refreshFromServer:^(BOOL success) {
        XCTAssert(success, @"failed to refresh from server");
        [self checkCredentials];
    }];
    [TBMKeyChainWrapper deleteItem:S3_SECRET_KEY];
    [self checkNoCredentials];
}

- (void) checkCredentials{
    NSDictionary *c = [TBMS3CredentialsManager credentials];
    XCTAssertNotNil(c, @"got nil for credentials");
    XCTAssertNotNil(c[S3_REGION_KEY], @"got nil for region");
    XCTAssertNotNil(c[S3_BUCKET_KEY], @"got nil for bucket");
    XCTAssertNotNil(c[S3_ACCESS_KEY], @"got nil for access");
    XCTAssertNotNil(c[S3_SECRET_KEY], @"got nil for secret");
}

- (void) checkNoCredentials{
    NSDictionary *c = [TBMS3CredentialsManager credentials];
    XCTAssertNil(c);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
