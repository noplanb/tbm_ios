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

static const NSString *VH_RESULT_KEY = @"result";
static const NSString *VH_UPDATE_SCHEMA_REQUIRED = @"update_schema_required";
static const NSString *VH_UPDATE_REQUIRED = @"update_required";
static const NSString *VH_UPDATE_OPTIONAL = @"update_optional";
static const NSString *VH_CURRENT = @"current";

@implementation ZZStartInteractor

+ (BOOL) updateSchemaRequired:(NSString *)result
{
    return [result isEqual:VH_UPDATE_SCHEMA_REQUIRED];
}
+ (BOOL) updateRequired:(NSString *)result{
    return [result isEqual:VH_UPDATE_REQUIRED];
}
+ (BOOL) updateOptional:(NSString *)result{
    return [result isEqual:VH_UPDATE_OPTIONAL];
}
+ (BOOL) current:(NSString *)result{
    return [result isEqual:VH_CURRENT];
}

+ (void) goToStore{
    
}

- (void)checkVersion
{
    [[ZZCommonNetworkTransportService checkApplicationVersion] subscribeNext:^(id x) {
       
        OB_INFO(@"checkVersionCompatibility: success: %@", [x objectForKey:@"result"]);
    } error:^(NSError *error) {
        
        OB_WARN(@"checkVersionCompatibility: %@", error);
    }];
    
    [self _checkSession];
}

- (void)_checkSession
{
    ZZUserDomainModel* user = [ZZUserDataProvider authenticatedUser];
    if (user.isRegistered)
    {
        [self.output userHasAuthentication];
    }
    else
    {
        [self.output userRequiresAuthentication];
    }
}

@end
