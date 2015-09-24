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

@implementation ZZStartInteractor

- (void)checkVersionState
{
    [[ZZCommonNetworkTransportService checkApplicationVersion] subscribeNext:^(id x) {
       
        NSString* result = [x objectForKey:@"result"];
        
        if (!ANIsEmpty(result))
        {
            ZZApplicationVersionState state = ZZApplicationVersionStateEnumValueFromString(result);
            
            if (state < ZZApplicationVersionStateTotalCount)
            {
                OB_INFO(@"checkVersionCompatibility: success: %@", [NSObject an_safeString:result]);
                [self.output userVersionStateLoadedSuccessfully:state];
            }
            else
            {
                OB_ERROR(@"versionCheckCallback: unknown version check result: %@", [NSObject an_safeString:result]);
            }
        }
    } error:^(NSError *error) {
        
        OB_WARN(@"checkVersionCompatibility: %@", error);
        [self.output userVersionStateLoadedingDidFailWithError:error];
    }];
    
    [self _checkSession];
}


#pragma mark - Private

- (void)_checkSession
{
    ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
    if (user.isRegistered)
    {
        [[ZZCommonNetworkTransportService loadS3Credentials] subscribeNext:^(id x) {
            
            [self.output userHasAuthentication];
        } error:^(NSError *error) {
            [self.output userHasAuthentication]; // TODO: check this
        }];
    }
    else
    {
        [self.output userRequiresAuthentication];
    }
}

@end
