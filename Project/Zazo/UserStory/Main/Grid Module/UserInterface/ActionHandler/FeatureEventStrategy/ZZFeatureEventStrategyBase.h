//
//  ZZFeatureEventStrategyBase.h
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridCellViewModel.h"
#import "ZZGridActionStoredSettings.h"

@interface ZZFeatureEventStrategyBase : NSObject

@property (nonatomic, assign) BOOL featureUnlocked;

- (void)handleBothCameraFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock;

- (void)handleAbortRecordingFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock;

- (void)handleDeleteFriendFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock;

- (void)handleEarpieceFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock;

- (void)handleSpinWheelFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL isFeatureEnabled))completionBlock;

- (void)handleFullscreenFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock;

- (void)handlePlaybackControlsFeatureWithModel:(ZZFriendDomainModel *)model withCompletionBlock:(void (^)(BOOL))completionBlock;

- (BOOL)isFeatureEnabledWithModel:(ZZFriendDomainModel *)model beforeUnlockFeatureSentCount:(NSInteger)sentCount;

@end
