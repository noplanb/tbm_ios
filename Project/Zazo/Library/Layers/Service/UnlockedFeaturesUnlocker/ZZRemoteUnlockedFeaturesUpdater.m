//
//  ZZRemoteUnlockedFeaturesUpdater.m
//  Zazo
//
//  Created by Rinat on 31/05/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZRemoteUnlockedFeaturesUpdater.h"
#import "ZZGridActionStoredSettings.h"

NSString * const ZZSwitchCameraFeatureName = @"SWITCH_CAMERA";
NSString * const ZZAbortRecordingFeatureName = @"ABORT_RECORDING";
NSString * const ZZDeleteFriendFeatureName = @"DELETE_FRIEND";
NSString * const ZZEarpieceFeatureName = @"EARPIECE";
NSString * const ZZSpinWheelFeatureName = @"CAROUSEL";
NSString * const ZZFullscreenFeatureName = @"PLAY_FULLSCREEN";
NSString * const ZZPlaybackControlsFeatureName = @"PAUSE_PLAYBACK";

typedef NS_ENUM(NSInteger, ZZFeatureUnlockKeys)
{
    ZZFeatureUnlockNone = 0,
    ZZFeatureUnlockBothCameraKey = 2,
    ZZFeatureUnlockAbortRecordingKey,
    ZZFeatureUnlockDeleteFriendskey,
    ZZFeatureUnlockEarpieceKey,
    ZZFeatureUnlockSpinWheelKey
};

@interface ZZRemoteUnlockedFeaturesUpdater ()

@property (nonatomic, strong, readonly) NSArray <NSString *> *keyValuesForLegacyFeatureUnlocking; // old feature order
@property (nonatomic, strong, readonly) NSArray <NSString *> *keyValuesForFeatureUnlocking;

@end

@implementation ZZRemoteUnlockedFeaturesUpdater

@dynamic allFeatureNames;
@dynamic unlockedFeatureNames;
@dynamic keyValuesForFeatureUnlocking;
@dynamic keyValuesForLegacyFeatureUnlocking;

+ (instancetype)sharedInstance
{
    static id instance;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    
    return instance;
}

- (void)unlockFeaturesWithMKeys:(NSArray <NSString *> *)keys
{    
    
    NSInteger count = keys.count;
    
    if (count > self.keyValuesForFeatureUnlocking.count)
    {
        count = self.keyValuesForFeatureUnlocking.count;
    }
    
    if (count == 0)
    {
        return;
    }
    
    NSArray *unlockFeaturesKeys = [self.keyValuesForLegacyFeatureUnlocking subarrayWithRange:NSMakeRange(0, count - 1)];
    
    [unlockFeaturesKeys enumerateObjectsUsingBlock:^(NSString *_Nonnull propertyKey, NSUInteger idx, BOOL *_Nonnull stop) {
        [[ZZGridActionStoredSettings shared] setValue:@(YES) forKey:propertyKey];
    }];

}

- (NSArray<NSString *> *)allFeatureNames
{
    static NSArray<NSString *> *array;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        array = @[
                  ZZSwitchCameraFeatureName,
                  ZZAbortRecordingFeatureName,
                  ZZDeleteFriendFeatureName,
                  ZZFullscreenFeatureName,
                  ZZPlaybackControlsFeatureName,
                  ZZEarpieceFeatureName,
                  ZZSpinWheelFeatureName,
                  ];
    });
    
    return array;
}

- (NSArray<NSString *> *)keyValuesForLegacyFeatureUnlocking
{
    static NSArray<NSString *> *array;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        array = @[@"switchCameraFeatureEnabled",
                  @"abortRecordingFeatureEnabled",
                  @"deleteFriendFeatureEnabled",
                  @"earpieceFeatureEnabled",
                  @"carouselFeatureEnabled"];
    });
    
    return array;
}

- (NSArray<NSString *> *)keyValuesForFeatureUnlocking
{
    static NSArray<NSString *> *array;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        array = @[@"switchCameraFeatureEnabled",
                  @"abortRecordingFeatureEnabled",
                  @"deleteFriendFeatureEnabled",
                  @"fullscreenFeatureEnabled",
                  @"playbackControlsFeatureEnabled",
                  @"earpieceFeatureEnabled",
                  @"carouselFeatureEnabled"];
    });
    
    return array;

}

- (void)unlockFeaturesWithNames:(NSArray<NSString *> *)names
{
    for (NSString *name in names)
    {
        if (ANIsEmpty(name))
        {
            continue;
        }
        
        ZZGridActionFeatureType feature = [self.allFeatureNames indexOfObject:name];
        
        if (feature == NSNotFound)
        {
            return;
        }
        
        if (feature > self.keyValuesForFeatureUnlocking.count - 1)
        {
            return;
        }
        
        NSString *propertyKey = self.keyValuesForFeatureUnlocking[feature];
        
        [[ZZGridActionStoredSettings shared] setValue:@(YES) forKey:propertyKey];
    }
}

- (NSArray<NSString *> *)unlockedFeatureNames
{
    return [self.allFeatureNames.rac_sequence filter:^BOOL(NSString *featureName) {
        
        ZZGridActionFeatureType feature = [self.allFeatureNames indexOfObject:featureName];
        
        NSString *key = self.keyValuesForFeatureUnlocking[feature];
        
        return [[[ZZGridActionStoredSettings shared] valueForKey:key] boolValue];

    }].array;
}

@end
