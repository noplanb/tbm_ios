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
extern NSString * const ZZEarpieceFeatureName;
extern NSString * const ZZSpinWheelFeatureName;
extern NSString * const ZZFullscreenFeatureName;
extern NSString * const ZZPlaybackControlsFeatureName;

@interface ZZRemoteUnlockedFeaturesUpdater : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong, readonly) NSArray <NSString *> *allFeatureNames; // Sorted as ZZGridActionFeatureType
@property (nonatomic, strong, readonly) NSArray <NSString *> *unlockedFeatureNames;

/**
 *  Old update way for compatibility. Works only once after installation. Next calls will be ignored.
 *
 *  @param count Count of friends with ever sent messages
 */
- (void)unlockFeaturesWithEverSentCount:(NSUInteger)count;

/**
 *  Actual way
 *
 *  @param names Names of features
 */
- (void)unlockFeaturesWithNames:(NSArray <NSString *> *)names;

@end
