//
//  ZZSecretInteractor.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretInteractor.h"
#import "ZZSettingsModel.h"
#import "ZZStoredSettingsManager.h"
#import "TBMUser.h"
#import "TBMDispatch.h"
#import "ZZAPIRoutes.h"

@implementation ZZSecretInteractor

- (void)loadData
{
    ZZSettingsModel* model = [self _generateDebugSettingsModel];
    [self.output dataLoaded:model];
}

- (void)dispatchData
{
    [TBMDispatch dispatch:[self _generateCurrentStateMessage]];
}

- (void)forceCrash
{
    NSString* message = [NSString stringWithFormat:@"CRASH BUTTON EXCEPTION: %@", [self _generateCurrentStateMessage]];
    [TBMDispatch dispatch:message]; // TODO: check it in previous versions
    //BADABOOOOOOM!
    [[NSArray array] objectAtIndex:2];
}

- (void)resetHints
{
    [ZZStoredSettingsManager shared].hintsDidStartRecord = NO;
    [ZZStoredSettingsManager shared].hintsDidStartPlay = NO;
}

- (void)removeAllDanglingFiles
{
    //TODO:
}

- (void)removeAllUserData
{
    //TODO: magical record
}


#pragma mark - Updating Settings

- (void)updateCustomServerEnpointValueTo:(NSString*)value
{
    [ZZStoredSettingsManager shared].serverURLString = value;
}

- (void)updateDebugStateTo:(BOOL)isEnabled
{
    [ZZStoredSettingsManager shared].debugModeEnabled = isEnabled;
}

- (void)updateServerStateTo:(NSInteger)state
{
    [ZZStoredSettingsManager shared].serverEndpointState = state;
    [self.output serverEndpointValueUpdatedTo:apiBaseURL()];
}

- (void)updateShouldUserSDKForLogging:(BOOL)isEnabled
{
    [ZZStoredSettingsManager shared].shouldUseRollBarSDK = isEnabled;
}

- (void)updateShouldForceSMSStateTo:(BOOL)isEnabled
{
    [ZZStoredSettingsManager shared].forceSMS = isEnabled;
}

- (void)updateShouldForceCallStateTo:(BOOL)isEnabled
{
    [ZZStoredSettingsManager shared].forceCall = isEnabled;
}


#pragma mark - Private

- (ZZSettingsModel*)_generateSettingsModel
{
    ZZStoredSettingsManager* manager = [ZZStoredSettingsManager shared];
    ZZSettingsModel* model = [ZZSettingsModel new];
    model.isDebugEnabled = manager.debugModeEnabled;
    model.serverURLString = apiBaseURL();
    model.serverIndex = manager.serverEndpointState;
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString* buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    model.version = [NSString stringWithFormat:@"%@(%@)",
                     [NSObject an_safeString:version],
                     [NSObject an_safeString:buildNumber]];
    
    TBMUser *user = [TBMUser getUser];
    model.firstName = user.firstName;
    model.lastName = user.lastName;
    model.phoneNumber = user.mobileNumber;
    
    return model;
}


#pragma mark - Dispatch Message Generation

- (NSString*)_generateCurrentStateMessage
{
    ZZSettingsModel* model = [self _generateSettingsModel];
    
    NSMutableString *message = [NSMutableString stringWithString:@"\n * DEBUG SCREEN DATA * * * * * * \n * "];
    
    [message appendFormat:@"Version:        %@\n", [NSObject an_safeString:model.version]];
    [message appendFormat:@"First Name:     %@\n", [NSObject an_safeString:model.firstName]];
    [message appendFormat:@"Last Name:      %@\n", [NSObject an_safeString:model.lastName]];
    [message appendFormat:@"Phone:          %@\n", [NSObject an_safeString:model.phoneNumber]];
    [message appendFormat:@"Debug mode:     %@\n", model.isDebugEnabled ? @"ON" : @"OFF"];
    [message appendFormat:@"Server State:   %@\n", [self _serverFormattedStringFromState:model.serverIndex]];
    [message appendFormat:@"Server address: %@\n", [NSObject an_safeString:model.serverURLString]];
    [message appendFormat:@"Dispatch Type: %@\n", ([TBMDispatch dispatchType] == TBMDispatchTypeSDK) ? @"RollBar SDK" : @"Server"];
    
    [message appendString:@"\n * * * * * * * * * * * * * * * * * * * * * * * * \n"];
    
    return message;
}

- (NSString*)_serverFormattedStringFromState:(ZZConfigServerState)state
{
    NSString* string = @"Undefined";
    switch (state)
    {
        case ZZConfigServerStateProduction:
        {
            string = @"Production";
        } break;
        case ZZConfigServerStateDeveloper:
        {
            string = @"Development";
        } break;
        case ZZConfigServerStateCustom:
        {
            string = @"Custom";
        } break;
    }
    return string;
}



#pragma mark - Private

- (ZZSettingsModel*)_generateDebugSettingsModel
{
    ZZSettingsModel* model = [ZZSettingsModel new];
    model.isDebugEnabled = YES;
    model.serverURLString = @"staging.zazoapp.com";
    model.serverIndex = 1;
    model.version = @"1.01";

    model.firstName = @"Anoda";
    model.lastName = @"Mobi";
    model.phoneNumber = @"0 800 777 77 77";
    
    model.sendBrokenVideo = YES;
    model.useRearCamera = YES;
    
    return model;
}

@end
