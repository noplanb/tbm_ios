//
//  ZZFeatureEventStrategyBase.h
//  Zazo
//
//  Created by ANODA on 10/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridCellViewModel.h"
#import "ZZGridActionStoredSettings.h"

#pragma mark - Use both camera keys

@protocol ZZFeatureEventStrategyDelegate <NSObject>

- (void)showLastUnlockFeatureWithFeatureType:(ZZGridActionFeatureType)type friendModel:(ZZFriendDomainModel*)model;

@end


@interface ZZFeatureEventStrategyBase : NSObject

@property (nonatomic, assign) BOOL isFeatureShowed;
@property (nonatomic, weak) id <ZZFeatureEventStrategyDelegate> delegate;


- (void)handleBothCameraFeatureWithModel:(ZZFriendDomainModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock;
- (void)handleAbortRecordingFeatureWithModel:(ZZFriendDomainModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock;
- (void)handleDeleteFriendFeatureWithModel:(ZZFriendDomainModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock;
- (void)handleEarpieceFeatureWithModel:(ZZFriendDomainModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock;
- (void)handleSpinWheelFeatureWithModel:(ZZFriendDomainModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock;

- (BOOL)isFeatureEnabledWithModel:(ZZFriendDomainModel*)model beforeUnlockFeatureSentCount:(NSInteger)sentCount;
- (void)updateFeatureUnlockIdsWithModel:(ZZFriendDomainModel*)model;
- (void)updateFeaturesWithRemoteFriendsMkeys:(NSArray*)friendMkeys;

@end
