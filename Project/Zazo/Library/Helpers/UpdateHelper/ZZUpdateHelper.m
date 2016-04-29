//
// Created by Rinat on 29/04/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZUpdateHelper.h"
#import "ZZCommonNetworkTransportService.h"
#import "ZZApplicationVersionEnumHelper.h"
#import "ZZAlertBuilder.h"


@implementation ZZUpdateHelper {

}

+ (instancetype)shared
{
    static id shared;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [ZZUpdateHelper new];
    });
    
    return shared;
}

- (void)checkForUpdates
{
    [[ZZCommonNetworkTransportService checkApplicationVersion] subscribeNext:^(id x) {

        NSString* result = [x objectForKey:@"result"];

        if (!ANIsEmpty(result))
        {
            ZZApplicationVersionState state = ZZApplicationVersionStateEnumValueFromString(result);

            if (state < ZZApplicationVersionStateTotalCount)
            {
                ZZLogInfo(@"checkVersionCompatibility: success: %@", [NSObject an_safeString:result]);
                [self _userVersionStateLoadedSuccessfully:state];
            }
            else
            {
                ZZLogError(@"versionCheckCallback: unknown version check result: %@", [NSObject an_safeString:result]);
            }
        }
    } error:^(NSError *error) {

        ZZLogWarning(@"checkVersionCompatibility: %@", error);

    }];
}

- (void)_userVersionStateLoadedSuccessfully:(ZZApplicationVersionState)state
{
    switch (state)
    {
        case ZZApplicationVersionStateUpdateOptional:
        {
            [self _needUpdateAndCanSkip:YES];

        }
            break;
        case ZZApplicationVersionStateUpdateSchemaRequired:
        case ZZApplicationVersionStateUpdateRequired:
        {
            [self _needUpdateAndCanSkip:NO];
        }
            break;
        default:
            break;
    }
}


- (void)_needUpdateAndCanSkip:(BOOL)canBeSkipped
{
    NSString* message = canBeSkipped ? [self _makeMessageWithQualifier:@"out of date"] : [self _makeMessageWithQualifier:@"obsolete"];
    NSString* cancelButtonTitle = canBeSkipped ? @"Later" : nil;
    NSString* actionButtonTitle = @"Update";
    NSString* title = @"Update Available";

    ANCodeBlock updateBlock = ^{

        if (!canBeSkipped)
        {
            [self _needUpdateAndCanSkip:NO];
        }

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppstoreURLString]];

    };

    [ZZAlertBuilder presentAlertWithTitle:title
                                  details:message
                        cancelButtonTitle:cancelButtonTitle
                       cancelButtonAction:canBeSkipped ? ^{

                       }: nil
                        actionButtonTitle:actionButtonTitle
                                   action:updateBlock];

}

#pragma mark Support

- (NSString*)_makeMessageWithQualifier:(NSString *)q
{
    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    return [NSString stringWithFormat:@"Your %@ app is %@. Please update", appName, q];
}

@end