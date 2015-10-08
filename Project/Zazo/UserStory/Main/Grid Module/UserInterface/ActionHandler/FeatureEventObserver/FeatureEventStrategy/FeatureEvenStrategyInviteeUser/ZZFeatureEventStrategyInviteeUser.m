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
    
    NSInteger kUnlockFeatureCounterValue = 2;
    NSInteger kOnceUnlockCounterValue = 1;
    
    NSInteger sendMessageCounter = [[NSUserDefaults standardUserDefaults] integerForKey:kSendMessageCounterKey];
    NSString* lastAddedUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kFriendIdDefaultKey];
    
    BOOL isFeatureEnabled = NO;
    
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
    
    if (completionBlock)
    {
        completionBlock(isFeatureEnabled);
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
