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

@implementation ZZSecretInteractor

- (void)loadData
{
    ZZDebugSettingsStateDomainModel* model = [ZZApplicationStateInfoGenerator generateSettingsModel];
    [self.output dataLoaded:model];
}

- (void)dispatchData
{
    [[ZZRollbarAdapter shared] logMessage:[ZZApplicationStateInfoGenerator generateSettingsStateMessage]];
}

- (void)forceCrash
{
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
    ANDispatchBlockToMainQueue(^{        
        //TODO: move it to data updaters
        NSManagedObjectContext* context = [ZZContentDataAccessor mainThreadContext];
        [TBMFriend MR_truncateAllInContext:context];
        [TBMVideo MR_truncateAllInContext:context];
        [context MR_saveToPersistentStoreAndWait];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kResetAllUserDataNotificationKey object:nil];
    });
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
    [ZZStoredSettingsManager shared].shouldUseRollBarSDK = isEnabled;
}

- (void)updatePushNotificationStateTo:(BOOL)isEnabled
{
    [ZZStoredSettingsManager shared].isPushNotificatonEnabled = isEnabled;
    
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
