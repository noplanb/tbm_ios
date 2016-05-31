//
//  ZZFeatureEventStrategyBase.m
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZFeatureEventStrategyBase.h"


typedef NS_ENUM(NSInteger, ZZFeatureUnlockKeys)
{
    ZZFeatureUnlockNone = 0,
    ZZFeatureUnlockBothCameraKey = 2,
    ZZFeatureUnlockAbortRecordingKey,
    ZZFeatureUnlockDeleteFriendskey,
    ZZFeatureUnlockEarpiecekey,
    ZZFeatureUnlockSpinWheelKey
};


@implementation ZZFeatureEventStrategyBase

- (void)handleBothCameraFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock
{
    //TODO: make assert this is base class!
}

- (void)handleAbortRecordingFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (void)handleDeleteFriendFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (void)handleEarpieceFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (void)handleSpinWheelFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock
{
    NSLog(@"base class");
}

- (BOOL)isFeatureEnabledWithModel:(ZZFriendDomainModel *)viewModel beforeUnlockFeatureSentCount:(NSInteger)sentCount
{
    if (viewModel.isCreator)
    {
        return NO; // don't count this event if creator are not we
    }
    
    EverSentHelper *helper = [EverSentHelper sharedInstance];

    if (![helper isEverSentToFriend:viewModel.mKey] &&
         helper.everSentCount < sentCount)
    {
        self.isFeatureShowed = YES;
    }

    [helper addToEverSent:viewModel.mKey];
    
    return self.isFeatureShowed;
}


#pragma mark - Remote feature update

- (void)updateFeaturesWithRemoteFriendsMkeys:(NSArray *)friendMkeys
{
    EverSentHelper *helper = [EverSentHelper sharedInstance];
    
    NSMutableArray *everSentMkeys = [friendMkeys mutableCopy];
    
    [everSentMkeys removeObject:@""];
    
    [everSentMkeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSString class]])
        {
            [helper addToEverSent:obj];
        }
    }];

    [self _updateFeaturesWithMkeys:everSentMkeys];
}

- (void)_updateFeaturesWithMkeys:(NSArray *)mkeys
{

    NSDictionary *configurationDictionary = [self _unlockFeaturesConfigurationDictionary];

    NSInteger unlockType = mkeys.count <= ZZFeatureUnlockSpinWheelKey ? mkeys.count : ZZFeatureUnlockSpinWheelKey;

    if (unlockType != ZZFeatureUnlockNone)
    {
        NSArray *unlockFeaturesKeys = [configurationDictionary objectForKey:@(unlockType)];

        if (!ANIsEmpty(unlockFeaturesKeys))
        {
            [unlockFeaturesKeys enumerateObjectsUsingBlock:^(NSString *_Nonnull propertyKey, NSUInteger idx, BOOL *_Nonnull stop) {
                [[ZZGridActionStoredSettings shared] setValue:@(YES) forKey:propertyKey];
            }];
            
//            [self _showLastUnlockFeatureDialogAfterRemoteUpdateWithMkeys:mkeys withLastUnlockFeatureKey:[unlockFeaturesKeys lastObject]];
        }
    }
}

- (NSDictionary *)_unlockFeaturesConfigurationDictionary
{
    return @{

            @(ZZFeatureUnlockBothCameraKey) : @[@"switchCameraFeatureEnabled"],

            @(ZZFeatureUnlockAbortRecordingKey) : @[@"switchCameraFeatureEnabled",
                    @"abortRecordingFeatureEnabled"],

            @(ZZFeatureUnlockDeleteFriendskey) : @[@"switchCameraFeatureEnabled",
                    @"abortRecordingFeatureEnabled",
                    @"deleteFriendFeatureEnabled"],

            @(ZZFeatureUnlockEarpiecekey) : @[@"switchCameraFeatureEnabled",
                    @"abortRecordingFeatureEnabled",
                    @"deleteFriendFeatureEnabled",
                    @"earpieceFeatureEnabled"],

            @(ZZFeatureUnlockSpinWheelKey) : @[@"switchCameraFeatureEnabled",
                    @"abortRecordingFeatureEnabled",
                    @"deleteFriendFeatureEnabled",
                    @"earpieceFeatureEnabled",
                    @"carouselFeatureEnabled"]
    };
}

- (ZZGridActionFeatureType)_unlockFeatureTypesWithKey:(ZZFeatureUnlockKeys)unlockKey
{
    ZZGridActionFeatureType type = ZZGridActionEventTypeNone;
    switch (unlockKey)
    {
        case ZZFeatureUnlockBothCameraKey:
        {
            type = ZZGridActionFeatureTypeSwitchCamera;
        }
            break;
        case ZZFeatureUnlockAbortRecordingKey:
        {
            type = ZZGridActionFeatureTypeAbortRec;
        }
            break;
        case ZZFeatureUnlockDeleteFriendskey:
        {
            type = ZZGridActionFeatureTypeDeleteFriend;
        }
            break;
        case ZZFeatureUnlockEarpiecekey:
        {
            type = ZZGridActionFeatureTypeEarpiece;
        }
            break;
        case ZZFeatureUnlockSpinWheelKey:
        {
            type = ZZGridActionFeatureTypeSpinWheel;
        }
            break;
        default:
        {
        }
            break;
    }

    return type;
}

@end
