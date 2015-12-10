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
#import "RollbarReachability.h"

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
    ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
    if (user.isRegistered)
    {
        
        ANDispatchBlockToMainQueue(^{
            [self.output applicationIsUpToDateAndUserLogged:YES];
        });
        
        [self _checkVersionStateForUserLoggedInState:YES];
        [[ZZCommonNetworkTransportService loadS3Credentials] subscribeNext:^(id x) {}];
    }
    else
    {
#warning  Possible bug. Should it be called from the main queue?
        [self.output userRequiresAuthentication];
    }
}

- (void)_checkVersionStateForUserLoggedInState:(BOOL)loggedIn
{
    [[ZZCommonNetworkTransportService checkApplicationVersion] subscribeNext:^(id x) {

        NSString* result = [x objectForKey:@"result"];

        if (!ANIsEmpty(result))
        {
            ZZApplicationVersionState state = ZZApplicationVersionStateEnumValueFromString(result);

            if (state < ZZApplicationVersionStateTotalCount)
            {
                ZZLogInfo(@"checkVersionCompatibility: success: %@", [NSObject an_safeString:result]);
                [self _userVersionStateLoadedSuccessfully:state logged:loggedIn];
            }
            else
            {
                ZZLogError(@"versionCheckCallback: unknown version check result: %@", [NSObject an_safeString:result]);
            }
        }
    } error:^(NSError *error) {

        ZZLogWarning(@"checkVersionCompatibility: %@", error);
        if (loggedIn)
        {
            [self _userVersionStateLoadedSuccessfully:ZZApplicationVersionStateCurrent logged:loggedIn];
        }
        [self.output userVersionStateLoadingDidFailWithError:error];
    }];
}

- (void)_userVersionStateLoadedSuccessfully:(ZZApplicationVersionState)state logged:(BOOL)logged
{
    switch (state)
    {
        case ZZApplicationVersionStateUpdateOptional:
        {
            [self.output needUpdateAndCanSkip:YES logged:logged];
            
        }
            break;
        case ZZApplicationVersionStateUpdateSchemaRequired:
        case ZZApplicationVersionStateUpdateRequired:
        {
            [self.output needUpdateAndCanSkip:NO logged:logged];
        }
            break;
        default:
            break;
    }
}


@end
