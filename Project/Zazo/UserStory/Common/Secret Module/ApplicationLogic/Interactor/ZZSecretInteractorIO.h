//
//  ZZSecretInteractorIO.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZSettingsModel;

@protocol ZZSecretInteractorInput <NSObject>

- (void)loadData;

- (void)forceCrash;
- (void)dispatchData;
- (void)resetHints;
- (void)removeAllUserData;
- (void)removeAllDanglingFiles;
- (void)updateAllFeaturesToEnabled;
- (void)updateDebugStateTo:(BOOL)isEnabled;
- (void)updateShouldUserSDKForLogging:(BOOL)isEnabled;

- (void)updateServerStateTo:(NSInteger)state;
- (void)updateCustomServerEnpointValueTo:(NSString *)value;


@end


@protocol ZZSecretInteractorOutput <NSObject>

- (void)dataLoaded:(ZZSettingsModel*)model;
- (void)serverEndpointValueUpdatedTo:(NSString*)value;

@end