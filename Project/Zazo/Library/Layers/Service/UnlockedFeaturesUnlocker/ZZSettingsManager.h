//
//  ZZRemoteUnlockedFeaturesUpdater.h
//  Zazo
//
//  Created by Rinat on 31/05/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ZZSwitchCameraFeatureName;
extern NSString * const ZZAbortRecordingFeatureName;
extern NSString * const ZZDeleteFriendFeatureName;
extern NSString * const ZZFullscreenFeatureName;
extern NSString * const ZZPlaybackControlsFeatureName;
extern NSString * const ZZEarpieceFeatureName;
extern NSString * const ZZSpinWheelFeatureName;

/**
 *  Currently settings have only list of unlocked features
 */
@interface ZZSettingsManager : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong, readonly) NSArray <NSString *> *unlockedFeatureNames;
@property (nonatomic, strong, readonly) NSArray <NSString *> *allFeatureNames; // Sorted as ZZGridActionFeatureType

/**
 *  Old update way for compatibility. Works only once after installation. Next calls are ignored.
 *
 *  @param count Count of friends with ever sent messages
 */
- (void)unlockFeaturesWithEverSentCount:(NSUInteger)count;

/**
 *  Fetches remote user setting. It is needed only at the most first call after installation. Next calls are ignored.
 */
- (void)fetchSettingsIfNeeded;

/**
 *  Should be called after every settings change (e.g. after feature unlocking)
 */
- (void)pushSettings;

@end
