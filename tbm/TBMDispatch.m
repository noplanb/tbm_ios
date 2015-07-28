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

// Width for column in dispatch log
#define COLUMN_WIDTH 8

#pragma mark - Dispatch string formatters

NSString* rowForItems(NSArray* items) {
    NSMutableString *row = [NSMutableString new];
    NSString *format = [NSString stringWithFormat:@"%%%ds", COLUMN_WIDTH];
    for (NSString *item in items) {
        NSString *shortItem = item;
        if (shortItem.length > COLUMN_WIDTH) {
            shortItem = [shortItem substringToIndex:COLUMN_WIDTH];
        }
        [row appendFormat:@"| %@ ", [NSString stringWithFormat:format, shortItem.UTF8String]];
    }
    [row appendString:@"|"];
    return row;
}

NSString* rowItemForString(NSString* string) {
    return string?string:@"";
}

NSString* titleForTable(NSString* string, int columnsCount) {
    int titleWidth = (COLUMN_WIDTH+2)*columnsCount+(columnsCount-3);
    NSString *format = [NSString stringWithFormat:@"| %%-%d.%ds |", titleWidth, titleWidth];
    return [NSString stringWithFormat:format, string.UTF8String];
}

#pragma mark - Dispatch categories

#pragma mark -- TBMFriend

@interface TBMFriend (Dispatch)

- (NSString *)dispatchRowStr;

@end

@implementation TBMFriend (Dispatch)

+ (NSArray *)dispatchHeaderItems {
    NSMutableArray *items = [NSMutableArray new];
    [items addObject:@"Name"];
    [items addObject:@"ID"];
    [items addObject:@"Has app"];
    [items addObject:@"OV ID"];
    [items addObject:@"OV status"];
    [items addObject:@"Last event"];
    [items addObject:@"Has thumb"];
    [items addObject:@"Download"];
    return items;
}

+ (int)dispatchColumnsCount {
    return (int)[self dispatchHeaderItems].count;
}

+ (NSString *)dispatchTitlerStr {
    return titleForTable(@"Friends", (int)[self dispatchColumnsCount]);
}

+ (NSString *)dispatchHeaderStr {
    
    return rowForItems([self dispatchHeaderItems]);
}

- (NSString *)dispatchRowStr {
    
    NSMutableArray *items = [NSMutableArray new];
    // format according to COLUMN_WIDTH
    [items addObject:[self fullName]];
    [items addObject:rowItemForString(self.idTbm)];
    [items addObject:boolToStr(self.hasApp)];
    [items addObject:rowItemForString(self.outgoingVideoId)];
    [items addObject:intToStr(self.outgoingVideoStatus)];
    item = @"IN";
    if (self.lastVideoStatusEventType == OUTGOING_VIDEO_STATUS_EVENT_TYPE) {
        item = @"OUT";
    }
    [items addObject:item];
    [items addObject:boolToStr(![self isThumbNoPic])];
    [items addObject:boolToStr(![self hasDownloadingVideo])];
    
    return rowForItems(items);
}

@end

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

+ (NSString *)stateString {
    NSArray *objects = [TBMFriend all];
    
    NSMutableString *stateString = [NSMutableString new];
    [stateString appendFormat:@"%@\n", [TBMFriend dispatchTitlerStr]];
    [stateString appendFormat:@"%@\n", [TBMFriend dispatchHeaderStr]];
    for (TBMFriend *object in objects) {
        [stateString appendFormat:@"%@\n", [object dispatchRowStr]];
    }

    NSLog(@"%@", stateString);
    
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

#pragma mark - Helpers

+ (NSInteger)columnWidthForItems:(NSArray *)items {
    NSInteger maxWidth = 0;
    
    for (NSString *item in items) {
        if (maxWidth < item.length) {
            maxWidth = item.length;
        }
    }
    
    return maxWidth;
}

@end
