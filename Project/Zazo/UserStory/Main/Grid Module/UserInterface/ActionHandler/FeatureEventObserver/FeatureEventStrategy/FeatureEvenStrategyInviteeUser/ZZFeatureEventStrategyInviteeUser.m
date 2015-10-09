//
//  ZZFeatureEventStrategyInviteeUser.m
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFeatureEventStrategyInviteeUser.h"

@implementation ZZFeatureEventStrategyInviteeUser

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

- (void)handleAbortRecordingFeatureWithModel:(ZZGridCellViewModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{
    BOOL isFeatureEnabled = NO;
    
    if (![ZZGridActionStoredSettings shared].abortRecordHintWasShown && [ZZGridActionStoredSettings shared].frontCameraHintWasShown)
        
    {
        NSInteger kBeforeUnlockAbortFeatureMessagesCount = 3;
        
        NSInteger sendMessageCounter = [[NSUserDefaults standardUserDefaults] integerForKey:kSendMessageCounterKey];
        NSString* lastAddedUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kFriendIdDefaultKey];
        
        if (![model.item.relatedUser.idTbm isEqualToString:lastAddedUserId] && sendMessageCounter < kBeforeUnlockAbortFeatureMessagesCount)
        {
            sendMessageCounter++;
            [[NSUserDefaults standardUserDefaults] setInteger:sendMessageCounter forKey:kSendMessageCounterKey];
            [[NSUserDefaults standardUserDefaults] setObject:model.item.relatedUser.idTbm forKey:kFriendIdDefaultKey];
            isFeatureEnabled = NO;
        }
        else if (![model.item.relatedUser.idTbm isEqualToString:lastAddedUserId] && sendMessageCounter == kBeforeUnlockAbortFeatureMessagesCount)
        {
            sendMessageCounter++;
            [[NSUserDefaults standardUserDefaults] setInteger:sendMessageCounter forKey:kSendMessageCounterKey];
            [[NSUserDefaults standardUserDefaults] setObject:model.item.relatedUser.idTbm forKey:kFriendIdDefaultKey];
            isFeatureEnabled = YES;
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    if (completionBlock)
    {
        completionBlock(isFeatureEnabled);
    }

}

@end
