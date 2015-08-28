//
//  ZZSecretScreenInteractor.m
//  Zazo
//
//  Created by ANODA on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretScreenInteractor.h"
#import "ZZStoredSettingsManager.h"
#import "ZZSettingsModel.h" // TODO: if remove settingsAssembly - rename this model
#import "NSObject+ANSafeValues.h"
//TODO: temp
#import "TBMDispatch.h"
#import "TBMUser.h"

@interface ZZSecretScreenInteractor ()

@end

@implementation ZZSecretScreenInteractor

- (void)loadData
{
    ZZSettingsModel* model = [self _generateSettingsModel];
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
}


#pragma mark - Private

- (ZZSettingsModel*)_generateSettingsModel
{
    ZZStoredSettingsManager* manager = [ZZStoredSettingsManager shared];
    ZZSettingsModel* model = [ZZSettingsModel new];
    model.isDebugEnabled = manager.debugModeEnabled;
    model.serverURLString = manager.serverURLString;
    model.serverIndex = manager.serverEndpointState;
    NSString* version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString* buildNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    model.version = [NSString stringWithFormat:@"%@(%@)", [NSObject an_safeString:version], [NSObject an_safeString:buildNumber]];
    
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

@end
