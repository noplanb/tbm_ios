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

//- (void)versionCheckCallback:(NSString *)result
//{
//    
//    OB_INFO(@"versionCheckCallback: %@" , result);
//    
//    if ([TBMVersionHandler updateSchemaRequired:result])
//    {
//        [self showVersionHandlerDialogWithMessage:[self makeMessageWithQualifier:@"obsolete"] negativeButton:false];
//    }
//    else if ([TBMVersionHandler updateRequired:result])
//    {
//        [self showVersionHandlerDialogWithMessage:[self makeMessageWithQualifier:@"obsolete"] negativeButton:false];
//    }
//    else if ([TBMVersionHandler updateOptional:result])
//    {
//        [self showVersionHandlerDialogWithMessage:[self makeMessageWithQualifier:@"out of date"] negativeButton:true];
//    }
//    else if (![TBMVersionHandler current:result])
//    {
//        OB_ERROR(@"versionCheckCallback: unknown version check result: %@", result);
//    }
//}
//
//- (NSString *)makeMessageWithQualifier:(NSString *)q
//{
//    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
//    return [NSString stringWithFormat:@"Your %@ app is %@. Please update", appName, q];
//}
//
//- (void)showVersionHandlerDialogWithMessage:(NSString *)message negativeButton:(BOOL)negativeButton
//{
//    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Update Available" message:message];
//    if (negativeButton)
//        [alert addAction:[SDCAlertAction actionWithTitle:@"Later" style:SDCAlertActionStyleCancel handler:nil]];
//    
//    [alert addAction:[SDCAlertAction actionWithTitle:@"Update" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppstoreURLString]];
//    }]];
//    [alert presentWithCompletion:nil];
//}



#pragma mark - Private

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
