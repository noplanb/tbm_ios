//
//  ZZSecretInteractor.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZSecretInteractor.h"
#import "ZZDebugSettingsStateDomainModel.h"
#import "ZZStoredSettingsManager.h"
#import "TBMUser.h"
#import "ZZAPIRoutes.h"
#import "ZZNetworkTransport.h"
#import "ZZUserDataProvider.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZFeatureEventStrategyBase.h"
#import "TBMFriend.h"
#import "TBMVideo.h"
#import "MagicalRecord.h"
#import "ZZGridInteractor.h"
#import "ZZRollbarAdapter.h"
#import "ZZContentDataAccessor.h"
#import "ZZApplicationStateInfoGenerator.h"
#import "ZZNotificationsHandler.h"
#import "ZZFriendDataUpdater.h"
#import "ZZVideoDataUpdater.h"

@implementation ZZSecretInteractor

- (void)loadData
{
    ZZDebugSettingsStateDomainModel* model = [ZZApplicationStateInfoGenerator generateSettingsModel];
    [self.output dataLoaded:model];
}

- (void)dispatchData
{
    [[ZZRollbarAdapter shared] logMessage:[ZZApplicationStateInfoGenerator generateSettingsStateMessage] level:ZZDispatchLevelError];
}

- (void)forceCrash
{
    
    //TODO: the message should be dispatched automatically
    NSString* message = [NSString stringWithFormat:@"CRASH BUTTON EXCEPTION: %@",
                         [ZZApplicationStateInfoGenerator generateSettingsStateMessage]];
    [[ZZRollbarAdapter shared] logMessage:message level:ZZDispatchLevelError];
    //BADABOOOOOOM!
    [[NSArray new] objectAtIndex:2];
}

- (void)resetHints
{
    [[ZZGridActionStoredSettings shared] reset];
}

- (void)updateAllFeaturesToEnabled
{
    [[ZZGridActionStoredSettings shared] enableAllFeatures];
}

- (void)removeAllDanglingFiles
{
    //TODO:
}

- (void)removeAllUserData
{
    [ZZFriendDataUpdater deleteAllFriends];
    [ZZVideoDataUpdater deleteAllVideos];
    [[NSNotificationCenter defaultCenter] postNotificationName:kResetAllUserDataNotificationKey object:nil];
}


#pragma mark - Updating Settings

- (void)updateCustomServerEnpointValueTo:(NSString*)value
{
    [ZZStoredSettingsManager shared].serverURLString = value;
    [[ZZNetworkTransport shared] setBaseURL:apiBaseURL() andAPIVersion:@""];
}

- (void)updateDebugStateTo:(BOOL)isEnabled
{
    [ZZStoredSettingsManager shared].debugModeEnabled = isEnabled;
}

- (void)updateServerStateTo:(NSInteger)state
{
    [ZZStoredSettingsManager shared].serverEndpointState = state;
    [[ZZNetworkTransport shared] setBaseURL:apiBaseURL() andAPIVersion:@""];
    [self.output serverEndpointValueUpdatedTo:apiBaseURL()];
}

- (void)updateShouldUserSDKForLogging:(BOOL)isEnabled
{
    [ZZStoredSettingsManager shared].shouldUseServerLogging = !isEnabled;
}

- (void)updatePushNotificationStateTo:(BOOL)isEnabled
{
    [ZZStoredSettingsManager shared].isPushNotificationEnabled = isEnabled;
    
    if (isEnabled)
    {
        [ZZNotificationsHandler registerToPushNotifications];
    }
    else
    {
        [ZZNotificationsHandler disablePushNotifications];
    }
    
}

@end
