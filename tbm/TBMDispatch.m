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
#import "TBMHttpManager.h"
#import "TBMUser.h"
#import "TBMConfig.h"
#import <Rollbar.h>

// Dispatch type (via server or direct to rollbar)
typedef enum {
    TBMDispatchTypeServer = 0,
    TBMDispatchTypeApp = 1
} TBMDispatchType;

// Dispatch logging level
typedef enum {
    TBMDispatchLevelDebug = 0,
    TBMDispatchLevelInfo = 1,
    TBMDispatchLevelWarning = 2,
    TBMDispatchLevelError = 3,
    TBMDispatchLevelCritical = 4
} TBMDispatchLevel;

static TBMDispatchType TBMDispatchSelectedType = TBMDispatchTypeApp;

static BOOL TBMDispatchEnabled = NO;

@implementation TBMDispatch

+ (void)initialize{
    DebugLog(@"Dispatch initialize");
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(receivedError:)
                                                 name: OBLoggerErrorNotification object:nil];
}

// Change dispatching type
+ (void)setDispatchType:(TBMDispatchType)type {
    TBMDispatchSelectedType = type;
}

+ (void)enable{
    TBMDispatchEnabled = YES;
}

+ (void)disable{
    TBMDispatchEnabled = NO;
}

+ (void) receivedError:(NSNotification *)notification{
    if (TBMDispatchEnabled && [TBMUser getUser].isRegistered)
        [TBMDispatch dispatch: [TBMDispatch message:notification.object] logLevel:TBMDispatchLevelError];
}

+ (void) dispatch: (NSString *)msg {
    [self dispatch:msg logLevel:TBMDispatchLevelDebug];
}

+ (void) dispatch:(NSString *)msg logLevel:(TBMDispatchLevel)logLevel {
    if (TBMDispatchSelectedType == TBMDispatchTypeServer) {
        [self dispatchViaServer:msg];
    } else {
        NSString *level = dispatchLevelStringFromDispatchLevel(logLevel);
        [Rollbar logWithLevel:level message:msg];
    }
}

+ (void) dispatchViaServer:(NSString *)msg {
    [[TBMHttpManager manager] POST:@"dispatch/post_dispatch"
                        parameters:@{SERVER_PARAMS_DISPATCH_MSG_KEY: msg,
                                     SERVER_PARAMS_DISPATCH_DEVICE_MODEL_KEY: [[UIDevice currentDevice] model],
                                     SERVER_PARAMS_DISPATCH_OS_VERSION_KEY: [[UIDevice currentDevice] systemVersion],
                                     SERVER_PARAMS_DISPATCH_ZAZO_VERSION_KEY: CONFIG_VERSION_STRING,
                                     SERVER_PARAMS_DISPATCH_ZAZO_VERSION_NUMBER_KEY: CONFIG_VERSION_NUMBER}
                           success:nil
                           failure:nil];
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

+ (void)startRollBar {
    RollbarConfiguration *config = [RollbarConfiguration configuration];
    config.crashLevel = @"critical";
    TBMConfigServerState serverState = [TBMConfig serverState];
    NSString *env = @"development";
    switch (serverState) {
        case TBMServerStateProduction:
            env = @"production";
            break;
        case TBMServerStateDeveloper:
            env = @"staging";
            break;
        default:
            break;
    }
    config.environment = env;
    TBMUser *user = [TBMUser getUser];
    [self setRollBarUser:user forConfig:config];
    [Rollbar initWithAccessToken:@"0ac2aee23dc449309b0c0bf6a46b4d59" configuration:config];
}

+ (void)setRollBarUser:(TBMUser *)user forConfig:(RollbarConfiguration *)config {
    NSString *personId = user.idTbm;
    NSString *username = [NSString stringWithFormat:@"%@ %@", user.firstName, user.lastName];
    NSString *email = user.mobileNumber;
    [config setPersonId:personId username:username email:email];
}

+ (void)setRollBarUser:(TBMUser *)user {
    RollbarConfiguration *config = [Rollbar currentConfiguration];
    [self setRollBarUser:user forConfig:config];
}

@end
