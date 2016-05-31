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
    BOOL isFeatureEnabled = NO;

    if (![ZZGridActionStoredSettings shared].frontCameraHintWasShown)
    {
        ZZUserDomainModel *user = [ZZUserDataProvider authenticatedUser];

        NSInteger kUnlockFeatureCounterValue = 2;
        NSInteger kOnceUnlockCounterValue = 1;
        
        EverSentHelper *helper = [EverSentHelper sharedInstance];
        NSInteger sendMessageCounter = helper.everSentCount;

        BOOL shouldUnlockToInvitee = user.isInvitee && sendMessageCounter == 0 &&
                !model.isCreator;

        if (shouldUnlockToInvitee)
        {
            isFeatureEnabled = [self isFeatureEnabledWithModel:model beforeUnlockFeatureSentCount:kUnlockFeatureCounterValue];
        }
        else if (sendMessageCounter == 0 &&
                !model.isCreator)
        {
            [helper addToEverSent:model.mKey];
        }
        else if (sendMessageCounter == kOnceUnlockCounterValue)
        {
            isFeatureEnabled = [self isFeatureEnabledWithModel:model beforeUnlockFeatureSentCount:kUnlockFeatureCounterValue];
        }

    }

    if (completionBlock)
    {
        completionBlock(isFeatureEnabled);
    }
}


#pragma mark - Abort Recording

- (void)handleAbortRecordingFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{
    BOOL isFeatureEnabled = NO;

    if (![ZZGridActionStoredSettings shared].abortRecordHintWasShown && [ZZGridActionStoredSettings shared].frontCameraHintWasShown)
    {
        NSInteger kBeforeUnlockAbortFeatureMessagesCount = 3;
        isFeatureEnabled = [self isFeatureEnabledWithModel:model beforeUnlockFeatureSentCount:kBeforeUnlockAbortFeatureMessagesCount];
    }

    if (completionBlock)
    {
        completionBlock(isFeatureEnabled);
    }

}


#pragma mark - Delete Friend

- (void)handleDeleteFriendFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{
    BOOL isFeatureEnabled = NO;

    if (![ZZGridActionStoredSettings shared].deleteFriendHintWasShown && [ZZGridActionStoredSettings shared].abortRecordHintWasShown)
    {
        NSInteger kBeforeUnlockDeleteFriendFeatureMessageCount = 4;
        isFeatureEnabled = [self isFeatureEnabledWithModel:model beforeUnlockFeatureSentCount:kBeforeUnlockDeleteFriendFeatureMessageCount];
    }

    if (completionBlock)
    {
        completionBlock(isFeatureEnabled);
    }
}


#pragma mark - Earpiece

- (void)handleEarpieceFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{

    BOOL isFeatureEnabled = NO;

    if (![ZZGridActionStoredSettings shared].earpieceHintWasShown && [ZZGridActionStoredSettings shared].deleteFriendHintWasShown)
    {
        NSInteger kBeforeUnlockEarpieceMessageCount = 5;
        isFeatureEnabled = [self isFeatureEnabledWithModel:model beforeUnlockFeatureSentCount:kBeforeUnlockEarpieceMessageCount];
    }

    if (completionBlock)
    {
        completionBlock(isFeatureEnabled);
    }
}


#pragma mark - Speen Wheel

- (void)handleSpinWheelFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{
    BOOL isFeatureEnabled = NO;

    if (![ZZGridActionStoredSettings shared].spinHintWasShown && [ZZGridActionStoredSettings shared].earpieceHintWasShown)
    {
        NSInteger kBeforeUnlockSpinMessageCount = 6;
        isFeatureEnabled = [self isFeatureEnabledWithModel:model beforeUnlockFeatureSentCount:kBeforeUnlockSpinMessageCount];
    }

    if (completionBlock)
    {
        completionBlock(isFeatureEnabled);
    }
}

@end
