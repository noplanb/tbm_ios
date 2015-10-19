//
//  ZZLoadFriendListSpec.m
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright 2015 ANODA. All rights reserved.
//

#import "Specta.h"
#import "ZZFriendsTransportService.h"
#import "ZZFriendDomainModel.h"
#import "Expecta.h"
#import "ZZAccountTransportService.h"
#import "ZZUserDomainModel.h"

SpecBegin(ZZLoadFriendList)

describe(@"ZZLoadFriendList", ^{
    
    __block ZZUserDomainModel* userModel;
    __block NSString* actualSmsCode;
    
    beforeAll(^{
        userModel = [ZZUserDomainModel new];
        userModel.firstName = @"Dima";
        userModel.lastName = @"Frolow";
        userModel.mobileNumber = @"380974720070";
        actualSmsCode = @"0000"; //for success test use only valid sms code!!!
    });
    
    beforeEach(^{

    });
    
    it(@"Load friend list test", ^{
        waitUntilTimeout(10, ^(DoneCallback done) {
            
//           [[ZZAccountTransportService registerUserFromModel:userModel withVerificationCode:actualSmsCode] subscribeNext:^(id x) {
//               [[ZZFriendsTransportService loadFriendList] subscribeNext:^(id x) {
//                   expect(x).willNot.beNil();
//                   done();
//               } error:^(NSError *error) {
//                   expect(error).will.beNil();
//                   done();
//               }];
//           } error:^(NSError *error) {
//               expect(error).will.beNil();
//               done();
//           }];
        });
    });  
    afterEach(^{

    });
    
    afterAll(^{

    });
});

SpecEnd
