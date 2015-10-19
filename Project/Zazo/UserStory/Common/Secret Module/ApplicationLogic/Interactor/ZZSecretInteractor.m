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
#import "ZZVideoRecorder.h"
#import "ZZGridInteractor.h"
#import "ZZRollbarAdapter.h"
#import "ZZContentDataAcessor.h"
#import "ZZApplicationStateInfoGenerator.h"

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
    [[ZZRollbarAdapter shared] logMessage:message level:ZZDispatchLevelError];// TODO: check it in previous versions
    //BADABOOOOOOM!
    exit(0);
}

- (void)resetHints
{
    [[ZZGridActionStoredSettings shared] reset];
}

- (void)updateAllFeaturesToEnabled
{
    BOOL isEnabled = YES;
    [ZZGridActionStoredSettings shared].frontCameraHintWasShown = isEnabled;
    [ZZGridActionStoredSettings shared].abortRecordHintWasShown = isEnabled;
    [ZZGridActionStoredSettings shared].deleteFriendHintWasShown = isEnabled;
    [ZZGridActionStoredSettings shared].earpieceHintWasShown = isEnabled;
    [ZZGridActionStoredSettings shared].spinHintWasShown = isEnabled;
}

- (void)removeAllDanglingFiles
{
    //TODO:
}

- (void)removeAllUserData
{
    //TODO: move it to data updaters
    NSManagedObjectContext* context = [ZZContentDataAcessor contextForCurrentThread];
    [TBMFriend MR_truncateAllInContext:context];
    [TBMVideo MR_truncateAllInContext:context];
    [context MR_saveToPersistentStoreAndWait];
    
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
    [ZZStoredSettingsManager shared].shouldUseRollBarSDK = isEnabled;
}


#pragma mark - Private

- (ZZDebugSettingsStateDomainModel*)_generateDebugSettingsModel
{
    ZZDebugSettingsStateDomainModel* model = [ZZDebugSettingsStateDomainModel new];
    model.isDebugEnabled = YES;
    model.serverURLString = @"staging.zazoapp.com";
    model.serverIndex = 1;
    model.version = @"1.01";

    model.firstName = @"Anoda";
    model.lastName = @"Mobi";
    model.phoneNumber = @"0 800 777 77 77";
    
    model.useRearCamera = YES;
    
    return model;
}

@end
