//
//  ZZFeatureEventStrategyBase.m
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFeatureEventStrategyBase.h"


typedef NS_ENUM(NSInteger, ZZFeatureUnlockKeys) {
    ZZFeatureUnlockNone = 0,
    ZZFeatureUnlockBothCameraKey = 2,
    ZZFeatureUnlockAbortRecordingKey,
    ZZFeatureUnlockDeleteFriendskey,
    ZZFeatureUnlockEarpiecekey,
    ZZFeatureUnlockSpinWheelKey
};


@implementation ZZFeatureEventStrategyBase

- (void)handleBothCameraFeatureWithModel:(ZZFriendDomainModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock
{
    //TODO: make assert this is base class!
}

- (void)handleAbortRecordingFeatureWithModel:(ZZFriendDomainModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (void)handleDeleteFriendFeatureWithModel:(ZZFriendDomainModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (void)handleEarpieceFeatureWithModel:(ZZFriendDomainModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (void)handleSpinWheelFeatureWithModel:(ZZFriendDomainModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (BOOL)isFeatureEnabledWithModel:(ZZFriendDomainModel*)model beforeUnlockFeatureSentCount:(NSInteger)sentCount
{
    BOOL isFeatureEnabled = NO;
    
    NSInteger sendMessageCounter = [[NSUserDefaults standardUserDefaults] integerForKey:kSendMessageCounterKey];

    if (![self _isFeatureUnlockWithModel:model] &&
        sendMessageCounter < sentCount &&
        !model.isCreator)
    {
        sendMessageCounter++;
        [[NSUserDefaults standardUserDefaults] setInteger:sendMessageCounter forKey:kSendMessageCounterKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        isFeatureEnabled = YES;
        self.isFeatureShowed = YES;
    }
    
    return isFeatureEnabled;
}

- (BOOL)_isFeatureUnlockWithModel:(ZZFriendDomainModel*)vieModel
{
    BOOL isUnlock = NO;
    NSArray* userIdsArray = [[NSUserDefaults standardUserDefaults] objectForKey:kUsersIdsArrayKey];
    if (!userIdsArray)
    {
        userIdsArray = @[vieModel.mKey];
        [[NSUserDefaults standardUserDefaults] setObject:userIdsArray forKey:kUsersIdsArrayKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        isUnlock = NO;
    }
    else
    {
        isUnlock = [userIdsArray containsObject:vieModel.mKey];
        if (!isUnlock && !ANIsEmpty(vieModel.mKey))
        {
            NSMutableArray* userIdsArrayCopy = [userIdsArray mutableCopy];
            [userIdsArrayCopy addObject:vieModel.mKey];
            [[NSUserDefaults standardUserDefaults] setObject:userIdsArrayCopy forKey:kUsersIdsArrayKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    return isUnlock;
}

- (void)updateFeatureUnlockIdsWithModel:(ZZFriendDomainModel*)model
{
    NSArray* userIdsArray = [[NSUserDefaults standardUserDefaults] objectForKey:kUsersIdsArrayKey];
    if (!model.isCreator)
    {
        if (!userIdsArray && !ANIsEmpty(model))
        {
            userIdsArray = @[model.mKey];
            [[NSUserDefaults standardUserDefaults] setObject:userIdsArray forKey:kUsersIdsArrayKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else if (![userIdsArray containsObject:model.mKey] && userIdsArray)
        {
            NSMutableArray* userIdsArrayCopy = [userIdsArray mutableCopy];
            [userIdsArrayCopy addObject:model.mKey];
            [[NSUserDefaults standardUserDefaults] setObject:userIdsArrayCopy forKey:kUsersIdsArrayKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}


#pragma mark - Remote feature update

- (void)updateFeaturesWithRemoteFriendsMkeys:(NSArray*)friendMkeys
{
    NSMutableArray* everSentMkeys = [friendMkeys mutableCopy];
    [self _cleanArray:&everSentMkeys];
    
    NSArray* userIdsArray = [[NSUserDefaults standardUserDefaults] objectForKey:kUsersIdsArrayKey];
    if (!userIdsArray)
    {
        if (everSentMkeys && everSentMkeys.count > 0)
        {
            userIdsArray = [NSArray arrayWithArray:everSentMkeys];
            
            [[NSUserDefaults standardUserDefaults] setInteger:everSentMkeys.count forKey:kSendMessageCounterKey];
            [[NSUserDefaults standardUserDefaults] setObject:userIdsArray forKey:kUsersIdsArrayKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self _updateFeaturesWithMkeys:everSentMkeys];
        }
    }
    else
    {
        NSMutableArray* userIdsArrayCopy = [userIdsArray mutableCopy];
        [everSentMkeys enumerateObjectsUsingBlock:^(NSString* _Nonnull mkey, NSUInteger idx, BOOL * _Nonnull stop) {
            if (![userIdsArrayCopy containsObject:mkey])
            {
                [userIdsArrayCopy addObject:mkey];
            }
        }];
        
        if (userIdsArrayCopy.count > userIdsArray.count)
        {
            [self _updateFeaturesWithMkeys:everSentMkeys];
        }
        
        [[NSUserDefaults standardUserDefaults] setInteger:everSentMkeys.count forKey:kSendMessageCounterKey];
        [[NSUserDefaults standardUserDefaults] setObject:userIdsArrayCopy forKey:kUsersIdsArrayKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


- (void)_cleanArray:(NSMutableArray**)inspectedArray
{
    [*inspectedArray removeObject:@""];
    [*inspectedArray removeObject:[NSNull null]];
}

- (void)_updateFeaturesWithMkeys:(NSArray*)mkeys
{
    
    NSDictionary* configurationDictionary = [self _unlockFeaturesConfigurationDictionary];
    
    NSInteger unlockType = mkeys.count <= ZZFeatureUnlockSpinWheelKey ? mkeys.count : ZZFeatureUnlockSpinWheelKey;
    
    if (unlockType != ZZFeatureUnlockNone)
    {
        NSArray* unlockFeaturesKeys = [configurationDictionary objectForKey:@(unlockType)];
        
        if (!ANIsEmpty(unlockFeaturesKeys))
        {
            [unlockFeaturesKeys enumerateObjectsUsingBlock:^(NSString*  _Nonnull propertyKey, NSUInteger idx, BOOL * _Nonnull stop) {
                [[ZZGridActionStoredSettings shared] setValue:@(YES) forKey:propertyKey];
            }];
//            [self _showLastUnlockFeatureDialogAfterRemoteUpdateWithMkeys:mkeys withLastUnlockFeatureKey:[unlockFeaturesKeys lastObject]];
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


// if needed to show last unlock feature after remote update, now turn off.
- (void)_showLastUnlockFeatureDialogAfterRemoteUpdateWithMkeys:(NSArray*)mkeys
                                      withLastUnlockFeatureKey:(NSString*)lastFeaturekey
                                                   friendModel:(ZZFriendDomainModel*)model
{
    [[ZZGridActionStoredSettings shared] setValue:@(NO) forKey:lastFeaturekey];
    ANDispatchBlockToMainQueue(^{
        [self.delegate showLastUnlockFeatureWithFeatureType:[self _unlockFeatureTypesWithKey:mkeys.count] friendModel:model];
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
