//
//  ZZRemoteUnlockedFeaturesUpdater.m
//  Zazo
//
//  Created by Rinat on 31/05/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZSettingsManager.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZUserDataProvider.h"
#import "ZZRemoteStorageTransportService.h"

NSString * const ZZSwitchCameraFeatureName = @"SWITCH_CAMERA";
NSString * const ZZAbortRecordingFeatureName = @"ABORT_RECORDING";
NSString * const ZZDeleteFriendFeatureName = @"DELETE_FRIEND";
NSString * const ZZEarpieceFeatureName = @"EARPIECE";
NSString * const ZZSpinWheelFeatureName = @"CAROUSEL";
NSString * const ZZFullscreenFeatureName = @"PLAY_FULLSCREEN";
NSString * const ZZPlaybackControlsFeatureName = @"PAUSE_PLAYBACK";

NSString * const ZZUnlockingWithEverSentDisabled = @"ZZUnlockingWithEverSentDisabled";

typedef NS_ENUM(NSInteger, ZZFeatureUnlockKeys)
{
    ZZFeatureUnlockNone = 0,
    ZZFeatureUnlockBothCameraKey = 2,
    ZZFeatureUnlockAbortRecordingKey,
    ZZFeatureUnlockDeleteFriendskey,
    ZZFeatureUnlockEarpieceKey,
    ZZFeatureUnlockSpinWheelKey
};

@interface ZZSettingsManager ()

@property (nonatomic, strong, readonly) NSArray <NSString *> *keyValuesForLegacyFeatureUnlocking; // old feature order
@property (nonatomic, strong, readonly) NSArray <NSString *> *keyValuesForFeatureUnlocking;

@property (nonatomic, assign) BOOL unlockingWithEverSentDisabled;
@property (nonatomic, assign) BOOL shouldPushSettingAfterFetching;

@end

@implementation ZZSettingsManager

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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _unlockingWithEverSentDisabled =
            [[NSUserDefaults standardUserDefaults] boolForKey:ZZUnlockingWithEverSentDisabled];
    }
    return self;
}

- (void)setunlockingWithEverSentDisabled:(BOOL)unlockingWithEverSentDisabled
{
    _unlockingWithEverSentDisabled = unlockingWithEverSentDisabled;
    
    [[NSUserDefaults standardUserDefaults] setBool:unlockingWithEverSentDisabled
                                            forKey:ZZUnlockingWithEverSentDisabled];
}

- (void)unlockFeaturesWithEverSentCount:(NSUInteger)count
{
    if (self.unlockingWithEverSentDisabled)
    {
        return;
    }
    
    if (count > self.keyValuesForLegacyFeatureUnlocking.count)
    {
        count = self.keyValuesForLegacyFeatureUnlocking.count;
    }
    
    if (count == 0)
    {
        return;
    }
    
    NSArray *unlockFeaturesKeys = [self.keyValuesForLegacyFeatureUnlocking subarrayWithRange:NSMakeRange(0, count - 1)];
    
    [unlockFeaturesKeys enumerateObjectsUsingBlock:^(NSString *_Nonnull propertyKey, NSUInteger idx, BOOL *_Nonnull stop) {
        [[ZZGridActionStoredSettings shared] setValue:@(YES) forKey:propertyKey];
    }];
    
    if (count > 0)
    {
        self.shouldPushSettingAfterFetching = YES; // We need to push after polling because some features were unlocked via EverSent count.
    }
    
    self.unlockingWithEverSentDisabled = YES;

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

- (void)_updateSettingsWithDictionary:(NSDictionary *)settings
{
    if (![settings isKindOfClass:[NSDictionary class]])
    {
        return;
    }
    
    NSArray *openedFeatures = settings[@"openedFeatures"];
    
    if (ANIsEmpty(openedFeatures))
    {
        return;
    }
    
    openedFeatures = [openedFeatures filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"length > 0"]];
    
    [[ZZSettingsManager sharedInstance] unlockFeaturesWithNames:openedFeatures];
}

- (void)fetchSettings
{
    ZZUserDomainModel *currentUser = [ZZUserDataProvider authenticatedUser];
    
    [[ZZRemoteStorageTransportService loadSettingsForUserMKey:currentUser.mkey] subscribeNext:^(id x) {
        
        if ([x isKindOfClass:[NSDictionary class]])
        {
            [self _updateSettingsWithDictionary:x];
        }
        
        if (self.shouldPushSettingAfterFetching)
        {
            [self pushSettings];
        }
    }];
}

- (void)pushSettings
{
    ZZUserDomainModel *currentUser = [ZZUserDataProvider authenticatedUser];
    
    NSDictionary *settings = @{@"openedFeatures": [ZZSettingsManager sharedInstance].unlockedFeatureNames};
    
    [[ZZRemoteStorageTransportService updateRemoteSettings:settings
                                               forUserMkey:currentUser.mkey] subscribeNext:^(id x) {
        
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


@end
