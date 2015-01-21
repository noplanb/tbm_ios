//
//  TBMHomeViewController+VersionController.m
//  tbm
//
//  Created by Sani Elfishawy on 8/20/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMHomeViewController.h"
#import "TBMHomeViewController+VersionController.h"
#import "OBLogger.h"
#import "TBMConfig.h"
#import "TBMAlertController.h"

@implementation TBMHomeViewController (VersionController)

- (void)versionCheckCallback:(NSString *)result{
    OB_INFO(@"versionCheckCallback: %@" , result);
    if ([TBMVersionHandler updateSchemaRequired:result]){
        [self showVersionHandlerDialogWithMessage:[self makeMessageWithQualifier:@"obsolete"] negativeButton:false];
    } else if ([TBMVersionHandler updateRequired:result]){
        [self showVersionHandlerDialogWithMessage:[self makeMessageWithQualifier:@"obsolete"] negativeButton:false];
    } else if ([TBMVersionHandler updateOptional:result]){
        [self showVersionHandlerDialogWithMessage:[self makeMessageWithQualifier:@"out of date"] negativeButton:true];
    } else if (![TBMVersionHandler current:result]){
        OB_ERROR(@"versionCheckCallback: unknown version check result: %@", result);
    }
}

- (NSString *)makeMessageWithQualifier:(NSString *)q{
    return [NSString stringWithFormat:@"Your %@ app is %@. Please update", CONFIG_APP_NAME, q];
}

- (void)showVersionHandlerDialogWithMessage:(NSString *)message negativeButton:(BOOL)negativeButton{
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Update Available" message:message];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Later" style:SDCAlertActionStyleCancel handler:nil]];
    [alert addAction:[SDCAlertAction actionWithTitle:@"Update" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://testflightapp.com"]];
    }]];
    [alert presentWithCompletion:nil];
}

@end
