//
//  ZZFeatureEventStrategyBase.m
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFeatureEventStrategyBase.h"


typedef NS_ENUM(NSInteger, ZZFeatureUnlockKeys) {
    ZZFeatureUnlockBothCameraKey = 2,
    ZZFeatureUnlockAbortRecordingKey,
    ZZFeatureUnlockDeleteFriendskey,
    ZZFeatureUnlockEarpiecekey,
    ZZFeatureUnlockSpinWheelKey
};


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
        userIdsArray = @[vieModel.item.relatedUser.mKey];
        [[NSUserDefaults standardUserDefaults] setObject:userIdsArray forKey:kUsersIdsArrayKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        isUnlock = NO;
    }
    else
    {
        isUnlock = [userIdsArray containsObject:vieModel.item.relatedUser.mKey];
        if (!isUnlock && !ANIsEmpty(vieModel.item.relatedUser.mKey))
        {
            NSMutableArray* userIdsArrayCopy = [userIdsArray mutableCopy];
            [userIdsArrayCopy addObject:vieModel.item.relatedUser.mKey];
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
        userIdsArray = @[model.item.relatedUser.mKey];
        [[NSUserDefaults standardUserDefaults] setObject:userIdsArray forKey:kUsersIdsArrayKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if (![userIdsArray containsObject:model.item.relatedUser.mKey] && userIdsArray)
    {
        NSMutableArray* userIdsArrayCopy = [userIdsArray mutableCopy];
        [userIdsArrayCopy addObject:model.item.relatedUser.mKey];
        [[NSUserDefaults standardUserDefaults] setObject:userIdsArrayCopy forKey:kUsersIdsArrayKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


#pragma mark - Remote feature update

- (void)updateFeaturesWithRemoteFriendsMkeys:(NSArray*)friendMkeys
{
    NSArray* userIdsArray = [[NSUserDefaults standardUserDefaults] objectForKey:kUsersIdsArrayKey];
    if (!userIdsArray)
    {
        if (friendMkeys && friendMkeys.count > 0)
        {
            userIdsArray = [NSArray arrayWithArray:friendMkeys];
            
            [[NSUserDefaults standardUserDefaults] setInteger:friendMkeys.count forKey:kSendMessageCounterKey];
            [[NSUserDefaults standardUserDefaults] setObject:userIdsArray forKey:kUsersIdsArrayKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self _updateFeaturesWithMkeys:friendMkeys];
        }
    }
    else
    {
        NSMutableArray* userIdsArrayCopy = [userIdsArray mutableCopy];
        [friendMkeys enumerateObjectsUsingBlock:^(NSString* _Nonnull mkey, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![userIdsArrayCopy containsObject:mkey])
            {
                [userIdsArrayCopy addObject:mkey];
            }
        }];
        
        if (userIdsArrayCopy.count > userIdsArray.count)
        {
            [self _updateFeaturesWithMkeys:friendMkeys];
        }
        
        [[NSUserDefaults standardUserDefaults] setInteger:friendMkeys.count forKey:kSendMessageCounterKey];
        [[NSUserDefaults standardUserDefaults] setObject:userIdsArrayCopy forKey:kUsersIdsArrayKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)_updateFeaturesWithMkeys:(NSArray*)mkeys
{
    
    NSDictionary* configurationDictionary = [self _unlockFeaturesConfigurationDictionary];
    
    if (mkeys.count <= ZZFeatureUnlockSpinWheelKey)
    {
        NSArray* unlockFeaturesKeys = [configurationDictionary objectForKey:@(mkeys.count)];
        
        if (!ANIsEmpty(unlockFeaturesKeys))
        {
            [unlockFeaturesKeys enumerateObjectsUsingBlock:^(NSString*  _Nonnull propertyKey, NSUInteger idx, BOOL * _Nonnull stop) {
                [[ZZGridActionStoredSettings shared] setValue:@(YES) forKey:propertyKey];
            }];
            [self _showLastUnlockFeatureDialogAfterRemoteUpdateWithMkeys:mkeys withLastUnlockFeatureKey:[unlockFeaturesKeys lastObject]];
        }
    }
}

- (NSDictionary*)_unlockFeaturesConfigurationDictionary
{
    return @{
             
             @(ZZFeatureUnlockBothCameraKey) : @[@"frontCameraHintWasShown"],
              
              @(ZZFeatureUnlockAbortRecordingKey) : @[@"frontCameraHintWasShown",
                                                      @"abortRecordHintWasShown"],
              
              @(ZZFeatureUnlockDeleteFriendskey) : @[@"frontCameraHintWasShown",
                                                     @"abortRecordHintWasShown",
                                                     @"deleteFriendHintWasShown"],
              
              @(ZZFeatureUnlockEarpiecekey): @[@"frontCameraHintWasShown",
                                               @"abortRecordHintWasShown",
                                               @"deleteFriendHintWasShown",
                                               @"earpieceHintWasShown"],
              
              @(ZZFeatureUnlockSpinWheelKey) : @[@"frontCameraHintWasShown",
                                                 @"abortRecordHintWasShown",
                                                 @"deleteFriendHintWasShown",
                                                 @"earpieceHintWasShown",
                                                 @"spinHintWasShown"]
              };
}

- (void)_showLastUnlockFeatureDialogAfterRemoteUpdateWithMkeys:(NSArray*)mkeys
                                      withLastUnlockFeatureKey:(NSString*)lastFeaturekey
{
    [[ZZGridActionStoredSettings shared] setValue:@(NO) forKey:lastFeaturekey];
    ANDispatchBlockToMainQueue(^{
        [self.delegate showLastUnlockFeatureWithFeatureType:[self _unlockFeatureTypesWithKey:mkeys.count]];
    });
}

- (ZZGridActionFeatureType)_unlockFeatureTypesWithKey:(ZZFeatureUnlockKeys)unlockKey
{
    ZZGridActionFeatureType type = ZZGridActionEventTypeNone;
    switch (unlockKey) {
        case ZZFeatureUnlockBothCameraKey:
        {
            type = ZZGridActionFeatureTypeSwitchCamera;
        } break;
        case ZZFeatureUnlockAbortRecordingKey:
        {
            type = ZZGridActionFeatureTypeAbortRec;
        } break;
        case ZZFeatureUnlockDeleteFriendskey:
        {
            type = ZZGridActionFeatureTypeDeleteFriend;
        } break;
        case ZZFeatureUnlockEarpiecekey:
        {
            type = ZZGridActionFeatureTypeEarpiece;
        } break;
        case ZZFeatureUnlockSpinWheelKey:
        {
            type = ZZGridActionFeatureTypeSpinWheel;
        } break;
        default:
        {
        } break;
    }
    
    return type;
}

@end
