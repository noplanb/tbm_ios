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
#import "TBMVersionHandler.h"
#import "TBMConfig.h"


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
    self.versionHandlerAlert = [[UIAlertView alloc] initWithTitle:@"Update Available" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
    [self.versionHandlerAlert addButtonWithTitle:@"Update"];
    if (negativeButton)
        [self.versionHandlerAlert addButtonWithTitle:@"Later"];
    [self.versionHandlerAlert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([alertView isEqual:self.versionHandlerAlert]) {
        if (buttonIndex == 0) {
            OB_INFO(@"Update clicked");
        } else {
            OB_INFO(@"Cancel clicked");
        }
    } else {
        OB_ERROR(@"Unknown alertView clicked");
    }
}



@end
