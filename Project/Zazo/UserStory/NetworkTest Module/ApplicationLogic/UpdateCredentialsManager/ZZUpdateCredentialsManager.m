//
//  ZZUpdateCredentialsManager.m
//  Zazo
//
//  Created by ANODA on 12/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZUpdateCredentialsManager.h"
#import "ZZStoredSettingsManager.h"
#import "ZZCommonNetworkTransportService.h"
#import "ZZFriendsTransportService.h"

@implementation ZZUpdateCredentialsManager

- (void)updateCredentialsWithCompletion:(ANCodeBlock)completionBlock;
{
    [self _setupUserCredentials];
    [self _updateS3CredentialsWithCompletion:completionBlock];
}

- (void)_setupUserCredentials
{
    //TODO: Authorization flow?
    [ZZStoredSettingsManager shared].userID = @"I15WzFMcAcqb9V9BjzJu";
    [ZZStoredSettingsManager shared].authToken = @"5gDAiXN5by9yp6FpA7w9";
}

- (void)_updateS3CredentialsWithCompletion:(ANCodeBlock)completion
{
    [[ZZCommonNetworkTransportService loadS3Credentials] subscribeNext:^(id x) {
        [self loadFriends:completion];
    } error:^(NSError *error) {
        [self _safetyExecuteBlock:completion];
    }];
}

- (void)loadFriends:(ANCodeBlock)completionBlock
{
    [[ZZFriendsTransportService loadFriendList] subscribeNext:^(id x) {
        [self _safetyExecuteBlock:completionBlock];
    } error:^(NSError *error) {
        [self _safetyExecuteBlock:completionBlock];
    }];
}

- (void)_safetyExecuteBlock:(ANCodeBlock)completionBlock
{
    if (completionBlock)
    {
        completionBlock();
    }
}

@end
