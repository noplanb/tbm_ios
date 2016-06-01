//
//  ZZFeatureEventStrategy.m
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFeatureEventStrategy.h"
#import "ZZUserDomainModel.h"
#import "ZZUserDataProvider.h"
#import "ZZUserDomainModel.h"

@implementation ZZFeatureEventStrategy

#pragma mark - Use Both Cameras

- (void)handleBothCameraFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{
    BOOL featureUnlocked = NO;
    
    if (![ZZGridActionStoredSettings shared].switchCameraFeatureEnabled)
    {
        if (model.isCreator)
        {
            return;
        }
        
        ZZUserDomainModel *user = [ZZUserDataProvider authenticatedUser];
        
        NSInteger minimalMessageCount = 2;
        
        EverSentHelper *helper = [EverSentHelper sharedInstance];
        NSInteger messageCount = helper.everSentCount;
        
        BOOL earlyFeatureUnlock = user.isInvitee && messageCount == 0;
        
        if (earlyFeatureUnlock)
        {
            featureUnlocked = [self isFeatureEnabledWithModel:model beforeUnlockFeatureSentCount:minimalMessageCount];
        }
        else if (messageCount == 0)
        {
            [helper addToEverSent:model.mKey];
        }
        else
        {
            featureUnlocked = [self isFeatureEnabledWithModel:model beforeUnlockFeatureSentCount:minimalMessageCount];
        }

    }
    
    if (completionBlock)
    {
        completionBlock(featureUnlocked);
    }
}


#pragma mark - Abort Recording

- (void)handleAbortRecordingFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{
    BOOL featureUnlocked = NO;
    
    if (![ZZGridActionStoredSettings shared].abortRecordingFeatureEnabled && [ZZGridActionStoredSettings shared].switchCameraFeatureEnabled)
    {
        NSInteger minimalMessageCount = 3;
        featureUnlocked = [self isFeatureEnabledWithModel:model beforeUnlockFeatureSentCount:minimalMessageCount];
    }
    
    if (completionBlock)
    {
        completionBlock(featureUnlocked);
    }
}


#pragma mark - Delete Friend

- (void)handleDeleteFriendFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{
    BOOL featureUnlocked = NO;
    
    if (![ZZGridActionStoredSettings shared].deleteFriendFeatureEnabled && [ZZGridActionStoredSettings shared].abortRecordingFeatureEnabled)
    {
        NSInteger minimalMessageCount = 4;
        featureUnlocked = [self isFeatureEnabledWithModel:model beforeUnlockFeatureSentCount:minimalMessageCount];
    }
    
    if (completionBlock)
    {
        completionBlock(featureUnlocked);
    }
}


#pragma mark - Fullscreen

- (void)handleFullscreenFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{
    BOOL featureUnlocked = NO;
    
    if (![ZZGridActionStoredSettings shared].fullscreenFeatureEnabled && [ZZGridActionStoredSettings shared].deleteFriendFeatureEnabled)
    {
        NSInteger minimalMessageCount = 5;
        featureUnlocked = [self isFeatureEnabledWithModel:model beforeUnlockFeatureSentCount:minimalMessageCount];
    }
    
    if (completionBlock)
    {
        completionBlock(featureUnlocked);
    }
    
}

#pragma mark - Playback controls

- (void)handlePlaybackControlsFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{
    BOOL featureUnlocked = NO;
    
    if (![ZZGridActionStoredSettings shared].playbackControlsFeatureEnabled && [ZZGridActionStoredSettings shared].fullscreenFeatureEnabled)
    {
        NSInteger minimalMessageCount = 6;
        featureUnlocked = [self isFeatureEnabledWithModel:model beforeUnlockFeatureSentCount:minimalMessageCount];
    }
    
    if (completionBlock)
    {
        completionBlock(featureUnlocked);
    }
    
}


#pragma mark - Earpiece

- (void)handleEarpieceFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{    
    BOOL featureUnlocked = NO;
    
    if (![ZZGridActionStoredSettings shared].earpieceFeatureEnabled && [ZZGridActionStoredSettings shared].deleteFriendFeatureEnabled)
    {
        NSInteger minimalMessageCount = 7;
        featureUnlocked = [self isFeatureEnabledWithModel:model beforeUnlockFeatureSentCount:minimalMessageCount];
    }
    
    if (completionBlock)
    {
        completionBlock(featureUnlocked);
    }
}


#pragma mark - Speen Wheel

- (void)handleSpinWheelFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{
    BOOL featureUnlocked = NO;
    
    if (![ZZGridActionStoredSettings shared].carouselFeatureEnabled && [ZZGridActionStoredSettings shared].earpieceFeatureEnabled)
    {
        NSInteger minimalMessageCount = 8;
        featureUnlocked = [self isFeatureEnabledWithModel:model beforeUnlockFeatureSentCount:minimalMessageCount];
    }
    
    if (completionBlock)
    {
        completionBlock(featureUnlocked);
    }
}

@end
