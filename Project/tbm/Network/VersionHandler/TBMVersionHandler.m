//
//  TBMVersionHandler.m
//  tbm
//
//  Created by Sani Elfishawy on 8/20/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import "TBMVersionHandler.h"
#import "TBMConfig.h"
#import "TBMStringUtils.h"
#import "OBLogger.h"
#import "NSObject+ANSafeValues.h"
#import "NSString+ANAdditions.h"
#import "ZZCommonNetworkTransport.h"
#import "TBMAlertController.h"
#import "ZZCommonNetworkTransportService.h"

static const NSString *VH_RESULT_KEY = @"result";
static const NSString *VH_UPDATE_SCHEMA_REQUIRED = @"update_schema_required";
static const NSString *VH_UPDATE_REQUIRED = @"update_required";
static const NSString *VH_UPDATE_OPTIONAL = @"update_optional";
static const NSString *VH_CURRENT = @"current";

@interface TBMVersionHandler()

@property (nonatomic, retain) id<TBMVersionHandlerDelegate> delegate;

@end

@implementation TBMVersionHandler

- (instancetype) initWithDelegate:(id<TBMVersionHandlerDelegate>)delegate
{
    self = [super init];
    if (self)
    {
        _delegate = delegate;
    }
    return self;
}

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

- (void) checkVersionCompatibility
{
    [[ZZCommonNetworkTransportService checkApplicationVersion] subscribeNext:^(id x) {
        
        OB_INFO(@"checkVersionCompatibility: success: %@", [x objectForKey:@"result"]);
        if (_delegate)
        {
            [_delegate versionCheckCallback:[x objectForKey:VH_RESULT_KEY]];
        }
    } error:^(NSError *error) {
        OB_WARN(@"checkVersionCompatibility: %@", error);
    }];
}

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

- (NSString *)makeMessageWithQualifier:(NSString *)q
{
    NSString* appName = [[NSBundle mainBundle] infoDictionary][@"CFBundleDisplayName"];
    return [NSString stringWithFormat:@"Your %@ app is %@. Please update", appName, q];
}

- (void)showVersionHandlerDialogWithMessage:(NSString *)message negativeButton:(BOOL)negativeButton{
    TBMAlertController *alert = [TBMAlertController alertControllerWithTitle:@"Update Available" message:message];
    if (negativeButton)
        [alert addAction:[SDCAlertAction actionWithTitle:@"Later" style:SDCAlertActionStyleCancel handler:nil]];
    
    [alert addAction:[SDCAlertAction actionWithTitle:@"Update" style:SDCAlertActionStyleDefault handler:^(SDCAlertAction *action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppstoreURLString]];
    }]];
    [alert presentWithCompletion:nil];
}

@end
