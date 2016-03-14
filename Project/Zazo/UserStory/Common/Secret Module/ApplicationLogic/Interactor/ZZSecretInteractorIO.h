//
//  ZZSecretInteractorIO.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/12/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class ZZDebugSettingsStateDomainModel;

@protocol ZZSecretInteractorInput <NSObject>

- (void)loadData;

- (void)forceCrash;
- (void)dispatchData;
- (void)resetHints;
- (void)removeAllUserData;
- (void)clearCache;
- (void)removeAllDanglingFiles;
- (void)shouldDuplicateNextUpload;
- (void)updateAllFeaturesToEnabled;
- (void)updateDebugStateTo:(BOOL)isEnabled;
- (void)updateShouldUserSDKForLogging:(BOOL)isEnabled;

- (void)updateServerStateTo:(NSInteger)state;
- (void)updateCustomServerEnpointValueTo:(NSString *)value;
- (void)updatePushNotificationStateTo:(BOOL)isEnabled;
- (void)updateIncorrectFileSizeStateTo:(BOOL)isEnabled;

@end


@protocol ZZSecretInteractorOutput <NSObject>

- (void)dataLoaded:(ZZDebugSettingsStateDomainModel*)model;
- (void)serverEndpointValueUpdatedTo:(NSString*)value;

@end