//
//  ZZFeatureEventStrategyBase.m
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFeatureEventStrategyBase.h"

static NSString* const kUsersIdsArrayKey = @"usersIdsArrayKey";

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

    if (![self _isFeatureUnlockWithModel:model] && sendMessageCounter < sentCount)
    {
        sendMessageCounter++;
        [[NSUserDefaults standardUserDefaults] setInteger:sendMessageCounter forKey:kSendMessageCounterKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        isFeatureEnabled = YES;
        self.isFeatureShowed = YES;
    }
    
    return isFeatureEnabled;
}

- (BOOL)_isFeatureUnlockWithModel:(ZZGridCellViewModel*)vieModel
{
    BOOL isUnlock = NO;
    NSArray* userIdsArray = [[NSUserDefaults standardUserDefaults] objectForKey:kUsersIdsArrayKey];
    if (!userIdsArray)
    {
        userIdsArray = @[vieModel.item.relatedUser.idTbm];
        [[NSUserDefaults standardUserDefaults] setObject:userIdsArray forKey:kUsersIdsArrayKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        isUnlock = NO;
    }
    else
    {
        isUnlock = [userIdsArray containsObject:vieModel.item.relatedUser.idTbm];
        if (!isUnlock)
        {
            NSMutableArray* userIdsArrayCopy = [userIdsArray mutableCopy];
            [userIdsArrayCopy addObject:vieModel.item.relatedUser.idTbm];
            [[NSUserDefaults standardUserDefaults] setObject:userIdsArrayCopy forKey:kUsersIdsArrayKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return isUnlock;
}

- (void)updateFeatureUnlockIdsWithModel:(ZZGridCellViewModel*)model
{
    NSArray* userIdsArray = [[NSUserDefaults standardUserDefaults] objectForKey:kUsersIdsArrayKey];
    if (!userIdsArray)
    {
        userIdsArray = @[model.item.relatedUser.idTbm];
        [[NSUserDefaults standardUserDefaults] setObject:userIdsArray forKey:kUsersIdsArrayKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if (![userIdsArray containsObject:model.item.relatedUser.idTbm] && userIdsArray)
    {
        NSMutableArray* userIdsArrayCopy = [userIdsArray mutableCopy];
        [userIdsArrayCopy addObject:model.item.relatedUser.idTbm];
        [[NSUserDefaults standardUserDefaults] setObject:userIdsArrayCopy forKey:kUsersIdsArrayKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
