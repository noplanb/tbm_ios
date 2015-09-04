//
//  ZZRegistrationWithSMSTest.m
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ZZAccountTransportService.h"
#import "ZZUserDomainModel.h"


@interface ZZRegistrationWithSMSTest : XCTestCase

@property (nonatomic, strong) ZZUserDomainModel* userModel;

@end

@implementation ZZRegistrationWithSMSTest

- (void)setUp {
    [super setUp];
    self.userModel = [ZZUserDomainModel new];
    self.userModel.firstName = @"Dima";
    self.userModel.lastName = @"Frolow";
    self.userModel.mobileNumber = @"380974720070";
}

- (void)tearDown {
    [super tearDown];
}

- (void)testRegistrationWithSMS
{
    // test with actual sms verification code!!!
    XCTestExpectation* expectation = [self expectationWithDescription:@"registration with sms"];
//    [[ZZAccountTransportService registerUserFromModel:self.userModel withVerificationCode:@"9980"] subscribeNext:^(id x) {
//        
////        NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject: [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
////        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
////        [defaults setObject: cookiesData forKey: @"sessionCookies"];
////        [defaults synchronize];
//        
//        XCTAssertNotNil(x);
//        [expectation fulfill];
//    }];
    [self waitForExpectationsWithTimeout:8 handler:^(NSError *error) {
        XCTAssertNil(error); 
    }];
}

@end
