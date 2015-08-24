//
//  ANSystemSettingsManager.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 3/18/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

static NSString* const kIntroSkipped = @"introSkipped";

static NSString *kTBMConfigServerStateKey = @"kTBMConfigServerStateKey";
static NSString *kTBMConfigCustomServerURLKey = @"kTBMConfigCustomServerURLKey";
static NSString *kTBMConfigDeviceDebugModeKey = @"kTBMConfigDeviceDebugModeKey";

#import "ANStoredSettingsManager.h"
#import "NSDate+ANServerAdditions.h"
#import "NSObject+ANUserDefaults.h"

@interface ANStoredSettingsManager ()

@property (nonatomic, strong) NSArray* serverUrls;

@end

@implementation ANStoredSettingsManager

+ (instancetype)shared
{
    static id _sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [self new];
    });
    return _sharedClient;
}


- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self configureSreverUrls];
    }
    return self;
}

- (void)cleanSettings
{
    self.isSkipedIntro = NO;
}


#pragma mark - Configure Server Urls

- (void)configureSreverUrls
{
    self.serverUrls = @[@"http://prod",@"http://dev"];
}


#pragma mark - Intro

- (BOOL)isSkipedIntro
{
    return [[self an_dataSource] boolForKey:kIntroSkipped];
}

- (void)setIsSkipedIntro:(BOOL)isSkipedIntro
{
    [[self an_dataSource] setBool:isSkipedIntro forKey:kIntroSkipped];
    [[self an_dataSource] synchronize];
}

- (void)saveSereverUrlString:(NSString* )serverUrl
{
    [self an_updateObject:serverUrl forKey:kTBMConfigCustomServerURLKey];
}

- (void)saveDebugMode:(BOOL)debug
{
    [self an_updateObject:[NSNumber numberWithBool:debug] forKey:kTBMConfigDeviceDebugModeKey];
}

- (void)saveCurrentServerIndex:(NSInteger)index
{
    [[self an_dataSource] setInteger:index forKey:kTBMConfigServerStateKey];
}

- (NSString *)serverUrl
{
    NSString* serverSrting;
    NSInteger serverState = [[self an_dataSource] integerForKey:kTBMConfigServerStateKey];
    NSString* customServerUrl = [[self an_dataSource] objectForKey:kTBMConfigCustomServerURLKey];
    serverSrting = serverState < TBMServerStateCustom ? self.serverUrls[serverState] : customServerUrl;
    
    return serverSrting;
}

- (NSInteger)serverIndex
{
    return [[self an_dataSource] integerForKey:kTBMConfigServerStateKey];
}
- (NSNumber*)isDebugEnabled
{
    return [[self an_dataSource] objectForKey:kTBMConfigDeviceDebugModeKey];
}

@end
