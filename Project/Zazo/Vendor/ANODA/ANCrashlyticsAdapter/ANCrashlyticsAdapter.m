//
//  ANCrashlyticsWrapper.m
//  Zazo
//
//  Created by ANODA on 22/12/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANCrashlyticsAdapter.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@implementation ANCrashlyticsAdapter

+ (instancetype)shared
{
    static id _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [self new];
    });
    return _sharedClient;
}

+ (void)start
{
    if (![[[NSBundle mainBundle] infoDictionary][@"CFBundleIdentifier"] isEqualToString:@"com.zazo.Zazo"])
    {
        return; // Avoid creating app accounts in Fabric when CFBundleIdentifier temporary changed
    }

    [Fabric with:@[CrashlyticsKit]];

    // Setup listening log notifications
    [[NSNotificationCenter defaultCenter] addObserver:[ANCrashlyticsAdapter shared]
                                             selector:@selector(_logEvent:)
                                                 name:OBLoggerEventNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:[ANCrashlyticsAdapter shared]
                                             selector:@selector(_logError:)
                                                 name:OBLoggerErrorNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:[ANCrashlyticsAdapter shared]
                                             selector:@selector(_logWarn:)
                                                 name:OBLoggerWarnNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:[ANCrashlyticsAdapter shared]
                                             selector:@selector(_logInfo:)
                                                 name:OBLoggerInfoNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:[ANCrashlyticsAdapter shared]
                                             selector:@selector(_logDebug:)
                                                 name:OBLoggerDebugNotification
                                               object:nil];

}

+ (void)updateUserDataWithID:(NSString *)userID username:(NSString *)username email:(NSString *)email
{
    [self updateUserIdentifier:userID];
    [[Crashlytics sharedInstance] setUserName:username];
    [[Crashlytics sharedInstance] setUserEmail:email];
}

+ (void)updateUserDataWithDictionary:(NSDictionary *)data
{
    if (data && [data isKindOfClass:[NSDictionary class]])
    {
        [data.allKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            [[Crashlytics sharedInstance] setObjectValue:data[key] forKey:key];
        }];
    }
}

+ (void)updateUserIdentifier:(NSString *)userID
{
    [[Crashlytics sharedInstance] setUserIdentifier:userID];
}

- (void)_logDebug:(NSNotification *)notification
{
    [self _log:@" DEBUG " message:notification];
}

- (void)_logInfo:(NSNotification *)notification
{
    [self _log:@" INFO " message:notification];
}

- (void)_logWarn:(NSNotification *)notification
{
    [self _log:@" WARN " message:notification];
}

- (void)_logError:(NSNotification *)notification
{
    [self _log:@" ERROR " message:notification];
}

- (void)_logEvent:(NSNotification *)notification
{
    [self _log:@" EVENT " message:notification];
}

- (void)_log:(NSString *)prefix message:(NSNotification *)notification
{
    if ([notification.object isKindOfClass:[NSString class]])
    {
        NSString *message = notification.object;
        CLSLog(@"[%@] : %@", prefix, message);
    }
}

@end
