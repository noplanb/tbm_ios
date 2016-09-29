//
//  ZZStartInteractor.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZStartInteractor.h"
#import "ZZCommonNetworkTransportService.h"
#import "ZZUserDataProvider.h"
#import "ZZRollbarAdapter.h"
#import "ZZUpdateHelper.h"

@import AWSS3;

@implementation ZZStartInteractor

- (void)checkVersionStateAndSession
{
    ANDispatchBlockToBackgroundQueue(^{
        [self _checkSession];
    });
}

#pragma mark - Private

- (void)_checkSession
{
    ZZUserDomainModel *user = [ZZUserDataProvider authenticatedUser];

#ifdef NETTEST
    if (user.isRegistered)
    {
        [self.output presentNetworkTestController];
    }
    else
    {
        [self.output userRequiresAuthentication];
    }
#else
    if (user.isRegistered)
    {
        [[ZZRollbarAdapter shared] updateUserFullName:[user fullName]
                                                phone:user.mobileNumber
                                               itemID:user.idTbm];

        ANDispatchBlockToMainQueue(^{
            [self.output applicationIsUpToDateAndUserLogged:YES];
        });

        [[ZZCommonNetworkTransportService loadS3CredentialsOfType:ZZCredentialsTypeVideo] subscribeNext:^(id x) {
        
        }];
    }
    else
    {
        [self.output userRequiresAuthentication];
    }

#endif

}

@end
