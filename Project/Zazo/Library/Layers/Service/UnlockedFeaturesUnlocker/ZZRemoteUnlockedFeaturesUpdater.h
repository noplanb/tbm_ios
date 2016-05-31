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

@property (nonatomic, strong, readonly) NSArray <NSString *> *allFeatureNames; // sorted as ZZGridActionFeatureType
@property (nonatomic, strong, readonly) NSArray <NSString *> *unlockedFeatureNames;

- (void)unlockFeaturesWithMKeys:(NSArray <NSString *> *)keys; // old update way for compatibility
- (void)unlockFeaturesWithNames:(NSArray <NSString *> *)names; // actual way

@end
