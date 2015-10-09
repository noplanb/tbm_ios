//
//  ZZFeatureEventStrategyInviteeUser.m
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFeatureEventStrategyInviteeUser.h"

@implementation ZZFeatureEventStrategyInviteeUser


#pragma mark - Use Both Cameras

- (void)handleBothCameraFeatureWithModel:(ZZGridCellViewModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{
    BOOL isFeatureEnabled = NO;
    
    if (![ZZGridActionStoredSettings shared].frontCameraHintWasShown)
    {
        NSInteger kUnlockFeatureCounterValue = 2;
        NSInteger kOnceUnlockCounterValue = 1;
        
        NSInteger sendMessageCounter = [[NSUserDefaults standardUserDefaults] integerForKey:kSendMessageCounterKey];
        NSString* lastAddedUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kFriendIdDefaultKey];
        
        
        
        if (sendMessageCounter == kUnlockFeatureCounterValue)
        {
            isFeatureEnabled = YES;
        }
        else if (![model.item.relatedUser.idTbm isEqualToString:lastAddedUserId] && sendMessageCounter == kOnceUnlockCounterValue)
        {
            sendMessageCounter++;
            [[NSUserDefaults standardUserDefaults] setInteger:sendMessageCounter forKey:kSendMessageCounterKey];
            isFeatureEnabled = YES;
        }
        else if (![model.item.relatedUser.idTbm isEqualToString:lastAddedUserId] && sendMessageCounter == 0)
        {
            sendMessageCounter++;
            [[NSUserDefaults standardUserDefaults] setInteger:sendMessageCounter forKey:kSendMessageCounterKey];
            [[NSUserDefaults standardUserDefaults] setObject:model.item.relatedUser.idTbm forKey:kFriendIdDefaultKey];
            isFeatureEnabled = NO;
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    if (completionBlock)
    {
        completionBlock(isFeatureEnabled);
    }
}


#pragma mark - Abort Recording

- (void)handleAbortRecordingFeatureWithModel:(ZZGridCellViewModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
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

- (void)handleDeleteFriendFeatureWithModel:(ZZGridCellViewModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
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

- (void)handleEarpieceFeatureWithModel:(ZZGridCellViewModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
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

- (void)handleSpinWheelFeatureWithModel:(ZZGridCellViewModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
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
