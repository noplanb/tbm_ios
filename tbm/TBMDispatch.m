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
#import "TBMHttpManager.h"
#import "TBMConfig.h"

#import "NSString+NSStringExtensions.h"

#import "TBMUser.h"
#import "TBMFriend.h"
#import "TBMStateScreenDataSource.h"
#import "TBMFriendVideosInformation.h"
#import "TBMVideoObject.h"

// Dispatch logging level
typedef enum {
    TBMDispatchLevelDebug    = 0,
    TBMDispatchLevelInfo     = 1,
    TBMDispatchLevelWarning  = 2,
    TBMDispatchLevelError    = 3,
    TBMDispatchLevelCritical = 4
} TBMDispatchLevel;

static TBMDispatchType TBMDispatchSelectedType = TBMDispatchTypeSDK;

static BOOL TBMDispatchEnabled = NO;

@implementation TBMDispatch

+ (void)initialize{
    DebugLog(@"Dispatch initialize");
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(receivedError:)
                                                 name: OBLoggerErrorNotification object:nil];
}

+ (void)setDispatchType:(TBMDispatchType)type {
    TBMDispatchSelectedType = type;
}

+ (TBMDispatchType)dispatchType {
    return TBMDispatchSelectedType;
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
    NSString *log = [msg stringByAppendingFormat:@"\n%@", [self stateString]];
    if (TBMDispatchSelectedType == TBMDispatchTypeServer) {
        [self dispatchViaServer:log];
    } else {
        NSString *level = dispatchLevelStringFromDispatchLevel(logLevel);
        [Rollbar logWithLevel:level message:log];
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

// State info

+ (NSString *)stateString {
    NSMutableString *stateString = [NSMutableString new];
    // Friends
    [stateString appendFormat:@"%@\n", [TBMFriend tbm_dispatchTitlerStr]];
    [stateString appendFormat:@"%@\n", [TBMFriend tbm_dispatchHeaderStr]];
    
    NSMutableString *videosString = [NSMutableString new];
    [videosString appendFormat:@"%@\n", [TBMVideo tbm_dispatchTitlerStr]];
    [videosString appendFormat:@"%@\n", [TBMVideo tbm_dispatchHeaderStr]];
    
    NSArray *friends = [TBMFriend all];
    for (TBMFriend *friend in friends) {
        [stateString appendFormat:@"%@\n", [friend tbm_dispatchRowStr]];
        NSSet *videos = friend.videos;
        for (TBMVideo *video in videos) {
            [videosString appendFormat:@"%@\n", [video tbm_dispatchRowStr]];
        }
    }
    [stateString appendFormat:@"\n%@", videosString];
    
    // Videos
    TBMStateScreenDataSource *data = [[TBMStateScreenDataSource alloc] init];
    [data loadFriendsVideoObjects];
    [data loadVideos];
    [data excludeNonDanglingFiles];
    
    videosString = [NSMutableString new];
    [videosString appendFormat:@"%@\n", [TBMVideoObject tbm_dispatchTitlerStr]];
    [videosString appendFormat:@"%@\n", [TBMVideoObject tbm_dispatchHeaderStr]];
    
    for (TBMFriendVideosInformation *object in data.friendsVideoObjects) {
        // TBMVideoObject
        // Outgoing
        [videosString appendFormat:@"%@\n", [object tbm_dispatchRowStr]];
        for (TBMVideoObject *ovo in object.outgoingObjects) {
            [videosString appendFormat:@"%@\n", [ovo tbm_dispatchRowStr]];
        }
        // Incoming
        for (TBMVideoObject *ivo in object.incomingObjects) {
            [videosString appendFormat:@"%@\n", [ivo tbm_dispatchRowStr]];
        }
    }
    [stateString appendFormat:@"\n%@", videosString];
    
    // Files
    videosString = [NSMutableString new];
    for (NSString *ivf in data.incomingFiles) {
        [videosString appendFormat:@"%@\n", ivf];
    }
    for (NSString *ovf in data.outgoingFiles) {
        [videosString appendFormat:@"%@\n", ovf];
    }
    [stateString appendFormat:@"\n%@", videosString];
    
    return stateString;
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
