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

- (void)showLastUnlockFeatureWithFeatureType:(ZZGridActionFeatureType)type;

@end


@interface ZZFeatureEventStrategyBase : NSObject

@property (nonatomic, assign) BOOL isFeatureShowed;
@property (nonatomic, weak) id <ZZFeatureEventStrategyDelegate> delegate;


- (void)handleBothCameraFeatureWithModel:(ZZGridCellViewModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock;
- (void)handleAbortRecordingFeatureWithModel:(ZZGridCellViewModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock;
- (void)handleDeleteFriendFeatureWithModel:(ZZGridCellViewModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock;
- (void)handleEarpieceFeatureWithModel:(ZZGridCellViewModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock;
- (void)handleSpinWheelFeatureWithModel:(ZZGridCellViewModel*)model withCompletionBlock:(void(^)(BOOL isFeatureEnabled))completionBlock;

- (BOOL)isFeatureEnabledWithModel:(ZZGridCellViewModel*)model beforeUnlockFeatureSentCount:(NSInteger)sentCount;
- (void)updateFeatureUnlockIdsWithModel:(ZZGridCellViewModel*)model;
- (void)updateFeaturesWithRemoteFriendsMkeys:(NSArray*)friendMkeys;

@end
