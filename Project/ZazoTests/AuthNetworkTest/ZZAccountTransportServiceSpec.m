//
//  ZZAccountTransportServiceSpec.m
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright 2015 ANODA. All rights reserved.
//

#import "Specta.h"
#import "ZZAccountTransportService.h"
#import "ZZUserDomainModel.h"
#import "Expecta.h"


SpecBegin(ZZAccountTransportService)

describe(@"ZZAccountTransportService", ^{
    
    __block ZZUserDomainModel* user;
//    __block NSDictionary* resultDict;
    
    beforeAll(^{
        user = [ZZUserDomainModel new];
        user.firstName = @"John";
        user.lastName = @"Doe";
        user.mobileNumber = @"380974720070";
    });
    
    beforeEach(^{
        
    });
    
    it(@"register user test", ^{
        waitUntil(^(DoneCallback done) {
//            [[ZZAccountTransportService registerUserWithModel:user] subscribeNext:^(NSDictionary *authKeys) {
//                expect(authKeys).willNot.beNil();
//                expect(authKeys).contain(@"auth");
//                expect(authKeys).contain(@"mkey");
//                done();
//            }];
        });
    });
    
    afterEach(^{

    });
    
    afterAll(^{

    });
});

SpecEnd
