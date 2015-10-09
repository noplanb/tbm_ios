//
//  ZZFeatureEventStrategyRegisteredUser.m
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFeatureEventStrategyRegisteredUser.h"

@implementation ZZFeatureEventStrategyRegisteredUser

- (void)handleBothCameraFeatureWithModel:(ZZGridCellViewModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock
{
    NSInteger kUnlockFeatureCounterValue = 1;
   
    BOOL isFeatureEnabled = NO;
 
    if (![ZZGridActionStoredSettings shared].frontCameraHintWasShown)
    {
        NSInteger sendMessageCounter = [[NSUserDefaults standardUserDefaults] integerForKey:kSendMessageCounterKey];
       
        if (sendMessageCounter == kUnlockFeatureCounterValue)
        {
            isFeatureEnabled = YES;
        }
        else if (sendMessageCounter == 0)
        {
            sendMessageCounter++;
            [[NSUserDefaults standardUserDefaults] setInteger:sendMessageCounter forKey:kSendMessageCounterKey];
            isFeatureEnabled = YES;
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
        NSInteger kBeforeUnlockAbortFeatureMessagesCount = 1;
        
        NSInteger sendMessageCounter = [[NSUserDefaults standardUserDefaults] integerForKey:kSendMessageCounterKey];
        NSString* lastAddedUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kFriendIdDefaultKey];
       
        if (![model.item.relatedUser.idTbm isEqualToString:lastAddedUserId] && sendMessageCounter == kBeforeUnlockAbortFeatureMessagesCount)
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
