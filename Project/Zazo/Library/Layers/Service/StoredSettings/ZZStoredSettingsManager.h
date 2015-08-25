//
//  ANSystemSettingsManager.h
//  Zazo
//
//  Created by ANODA on 3/18/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

@interface ZZStoredSettingsManager : NSObject

typedef NS_ENUM(NSUInteger, TBMConfigServerState) {
    TBMServerStateProduction = 0,
    TBMServerStateDeveloper = 1,
    TBMServerStateCustom = 2,
};

+ (instancetype)shared;

- (void)cleanSettings;

- (void)saveSereverUrlString:(NSString* )serverUrl;
- (void)saveDebugMode:(BOOL)debug;
- (void)saveCurrentServerIndex:(NSInteger)index;

- (NSString *)serverUrl;
- (NSInteger)serverIndex;
- (NSNumber*)isDebugEnabled;

@end
