//
//  ZZFeatureEventStrategyBase.m
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFeatureEventStrategyBase.h"

@implementation ZZFeatureEventStrategyBase

- (void)handleBothCameraFeatureWithModel:(ZZGridCellViewModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock
{
    //TODO: make assert this is base class!
}

- (void)handleAbortRecordingFeatureWithModel:(ZZGridCellViewModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (void)handleDeleteFriendFeatureWithModel:(ZZGridCellViewModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (void)handleEarpieceFeatureWithModel:(ZZGridCellViewModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (void)handleSpinWheelFeatureWithModel:(ZZGridCellViewModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (BOOL)isFeatureEnabledWithModel:(ZZGridCellViewModel*)model beforeUnlockFeatureSentCount:(NSInteger)sentCount
{
    BOOL isFeatureEnabled = NO;
    
    NSInteger sendMessageCounter = [[NSUserDefaults standardUserDefaults] integerForKey:kSendMessageCounterKey];
    NSString* lastAddedUserId = [[NSUserDefaults standardUserDefaults] objectForKey:kFriendIdDefaultKey];
    
    if (![model.item.relatedUser.idTbm isEqualToString:lastAddedUserId] && sendMessageCounter < sentCount)
    {
        sendMessageCounter++;
        [[NSUserDefaults standardUserDefaults] setInteger:sendMessageCounter forKey:kSendMessageCounterKey];
        [[NSUserDefaults standardUserDefaults] setObject:model.item.relatedUser.idTbm forKey:kFriendIdDefaultKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        isFeatureEnabled = YES;
    }
    
    return isFeatureEnabled;
}

@end
