//
//  ANSystemSettingsManager.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 3/18/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

@interface ANStoredSettingsManager : NSObject

typedef NS_ENUM(NSUInteger, TBMConfigServerState) {
    TBMServerStateProduction = 0,
    TBMServerStateDeveloper = 1,
    TBMServerStateCustom = 2,
};

//global settings
@property (nonatomic, assign) BOOL isSkipedIntro;

+ (instancetype)shared;
- (void)cleanSettings;

- (void)saveSereverUrlString:(NSString* )serverUrl;
- (void)saveDebugMode:(BOOL)debug;
- (void)saveCurrentServerIndex:(NSInteger)index;

- (NSString *)serverUrl;
- (NSInteger)serverIndex;
- (NSNumber*)isDebugEnabled;

@end
