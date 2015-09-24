//
//  ZZStartPresenter.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZStartPresenter.h"
#import "ZZAlertBuilder.h"

@interface ZZStartPresenter ()

@end

@implementation ZZStartPresenter

- (void)configurePresenterWithUserInterface:(UIViewController<ZZStartViewInterface>*)userInterface
{
    self.userInterface = userInterface;
    [self.interactor checkVersionState];
}

#pragma mark - Output

- (void)userRequiresAuthentication
{
    [self.wireframe presentRegistrationController];
}

- (void)userHasAuthentication
{
    [self.wireframe presentMenuControllerWithGrid];
}

- (void)userVersionStateLoadedSuccessfully:(ZZApplicationVersionState)versionState
{
    
    NSString* message = nil;
    BOOL canSkipUpdate = NO;
    
    switch (versionState)
    {
        case ZZApplicationVersionStateCurrent:
        {
            
        } break;
        case ZZApplicationVersionStateUpdateOptional:
        {
            canSkipUpdate = YES;
            message = [self makeMessageWithQualifier:@"out of date"];
        }  break;
        case ZZApplicationVersionStateUpdateSchemaRequired:
        case ZZApplicationVersionStateUpdateRequired:
        {
            message = [self makeMessageWithQualifier:@"obsolete"];
        } break;
        default: break;
    }
    
    if (!ANIsEmpty(message))
    {
        [ZZAlertBuilder presentAlertWithTitle:@"Update Available"
                                      details:message
                            cancelButtonTitle:canSkipUpdate ? @"Later" : nil
                            actionButtonTitle:@"Update" action:^{
                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppstoreURLString]];
                            }];
    }
}


- (NSString*)makeMessageWithQualifier:(NSString *)q
{
    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    return [NSString stringWithFormat:@"Your %@ app is %@. Please update", appName, q];
}




#pragma mark - Module Interface


@end
