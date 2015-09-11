//
//  TBMDispatch.m
//  tbm
//
//  Created by Sani Elfishawy on 1/6/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//
//  Used to dispatch messages (mostly error messages)from the client to the server.
//

#import "TBMDispatch.h"
#import "OBLogger.h"
#import <Rollbar.h>
#import "TBMConfig.h"

#import "NSString+NSStringExtensions.h"

#import "TBMUser.h"
#import "TBMFriend.h"
#import "TBMStateDataSource.h"
#import "TBMFriendVideosInformation.h"
#import "TBMVideoObject.h"

#import "TBMStateStringGenerator.h"
#import "ZZStoredSettingsManager.h"
#import "NSObject+ANSafeValues.h"
#import "ZZUserDataProvider.h"
#import "ZZUserDomainModel.h"
#import "ZZCommonNetworkTransportService.h"

static NSString *ROLLBAR_TOKEN = @"0ac2aee23dc449309b0c0bf6a46b4d59";

// Dispatch logging level
typedef enum {
    TBMDispatchLevelDebug    = 0,
    TBMDispatchLevelInfo     = 1,
    TBMDispatchLevelWarning  = 2,
    TBMDispatchLevelError    = 3,
    TBMDispatchLevelCritical = 4
} TBMDispatchLevel;

static NSString *TBMDispatchRollBarEnvDevelopment = @"development";
static NSString *TBMDispatchRollBarEnvProduction = @"production";
static NSString *TBMDispatchRollBarEnvStaging = @"staging";

static TBMDispatchType tbmDispatchSelectedType = TBMDispatchTypeSDK;

static BOOL TBMDispatchEnabled = NO;

@implementation TBMDispatch

+ (void)initialize
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedError:)
                                                 name:OBLoggerErrorNotification object:nil];
}

+ (void)setupDispatchType:(TBMDispatchType)type {
    tbmDispatchSelectedType = type;
}

+ (TBMDispatchType)dispatchType {
    return tbmDispatchSelectedType;
}

+ (void)enable{
    TBMDispatchEnabled = YES;
}

+ (void)disable{
    TBMDispatchEnabled = NO;
}

+ (void) receivedError:(NSNotification *)notification
{
    ZZUserDomainModel* me = [ZZUserDataProvider authenticatedUser];
    if (TBMDispatchEnabled && me.isRegistered)
    {
        [TBMDispatch dispatch: [TBMDispatch message:notification.object] logLevel:TBMDispatchLevelError];
    }
}

+ (void) dispatch: (NSString *)msg {
    [self dispatch:msg logLevel:TBMDispatchLevelDebug];
}

+ (void) dispatch:(NSString *)msg logLevel:(TBMDispatchLevel)logLevel {
    NSString *log = [msg stringByAppendingFormat:@"\n%@", [TBMStateStringGenerator stateString]];
    if (tbmDispatchSelectedType == TBMDispatchTypeServer) {
        [self dispatchViaServer:log];
    } else {
        NSString *level = dispatchLevelStringFromDispatchLevel(logLevel);
        [Rollbar logWithLevel:level message:log];
    }
}

+ (void) dispatchViaServer:(NSString *)msg
{
    [[ZZCommonNetworkTransportService logMessage:msg] subscribeNext:^(id x) {}];
}

+ (NSString *) message:(NSString *)error{
    return [NSString stringWithFormat:@"%@\n\n\n%@", error, [TBMDispatch logString]];
}

+ (NSString *)logString{
    NSArray *logLines = [[OBLogger instance] logLines];
    NSString *line;
    NSString *r = @"";

    for (line in logLines){
        r = [r stringByAppendingString:line];
        r = [r stringByAppendingString:@"\n"];
    }
    return r;
}

NSString* dispatchLevelStringFromDispatchLevel(TBMDispatchLevel logLevel) {
    NSString *logLevelString = nil;
    switch (logLevel) {
        case TBMDispatchLevelDebug:
            logLevelString = @"debug";
            break;
        case TBMDispatchLevelInfo:
            logLevelString = @"info";
            break;
        case TBMDispatchLevelWarning:
            logLevelString = @"warning";
            break;
        case TBMDispatchLevelError:
            logLevelString = @"error";
            break;
        case TBMDispatchLevelCritical:
            logLevelString = @"critical";
            break;
        default:
            break;
    }
    return logLevelString;
}

#pragma mark - RollBar

+ (void)startRollBar
{
    RollbarConfiguration *config = [RollbarConfiguration configuration];
    config.crashLevel = @"critical";
    ZZConfigServerState serverState = [ZZStoredSettingsManager shared].serverEndpointState;
    NSString *env = TBMDispatchRollBarEnvDevelopment;
    
    switch (serverState)
    {
        case ZZConfigServerStateProduction:
            env = TBMDispatchRollBarEnvStaging;
            break;
        case ZZConfigServerStateDeveloper:
            env = TBMDispatchRollBarEnvStaging;
            break;
        default: break;
    }
    config.environment = env;
    ZZUserDomainModel* me = [ZZUserDataProvider authenticatedUser];
    [self setRollBarUser:me forConfig:config];
    [Rollbar initWithAccessToken:ROLLBAR_TOKEN configuration:config];
}

+ (void)setRollBarUser:(ZZUserDomainModel*)user forConfig:(RollbarConfiguration *)config
{
    NSString *personId = user.idTbm;
    NSString *username = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    NSString *email = user.mobileNumber;
    [config setPersonId:personId username:username email:email];
}

+ (void)updateRollBarUserWithItemID:(NSString*)itemID
                          username:(NSString*)username
                        phoneNumber:(NSString*)phoneNumber
{
    RollbarConfiguration *config = [Rollbar currentConfiguration];
    [config setPersonId:itemID username:username email:phoneNumber];
}

@end
