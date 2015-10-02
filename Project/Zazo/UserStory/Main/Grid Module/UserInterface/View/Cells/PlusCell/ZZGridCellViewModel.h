//
//  ZZGridCellViewModel.h
//  Zazo
//
//  Created by ANODA on 01/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridDomainModel.h"

@class ZZGridCellViewModel;

@protocol ZZGridCellVeiwModelAnimationDelegate <NSObject>

- (void)showUploadAnimation;

@end

@protocol ZZGridCellViewModelDelegate <NSObject>

- (void)recordingStateUpdatedToState:(BOOL)isEnabled
                           viewModel:(ZZGridCellViewModel*)viewModel
                 withCompletionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock;

- (void)playingStateUpdatedToState:(BOOL)isEnabled
                         viewModel:(ZZGridCellViewModel*)viewModel;

- (void)nudgeSelectedWithUserModel:(id)userModel;
- (BOOL)isVideoPlaying;

- (void)addUserToItem:(ZZGridCellViewModel*)model;

@end

typedef NS_ENUM(NSInteger, ZZGridCellViewModelState)
{
    ZZGridCellViewModelStateAdd,
    ZZGridCellViewModelStateFriendHasApp,
    ZZGridCellViewModelStateFriendHasNoApp,
    ZZGridCellViewModelStateIncomingVideoNotViewed,
    ZZGridCellViewModelStateIncomingVideoViewed,
    ZZGridCellViewModelStateOutgoingVideo
};

@interface ZZGridCellViewModel : NSObject

@property (nonatomic, strong) ZZGridDomainModel* item;
@property (nonatomic, weak) id <ZZGridCellViewModelDelegate> delegate;
@property (nonatomic, weak) id <ZZGridCellVeiwModelAnimationDelegate> animationDelegate;
@property (nonatomic, strong) NSNumber* badgeNumber;
@property (nonatomic, strong) NSNumber* prevBadgeNumber;
@property (nonatomic, strong) UIView* playerContainerView;
@property (nonatomic, assign) BOOL hasUploadedVideo;
@property (nonatomic, assign) BOOL isUploadedVideoViewed;
@property (nonatomic, assign) BOOL isNeedToShowDownloadAnimation;
@property (nonatomic, assign) BOOL hasDownloadedVideo;
@property (nonatomic, assign) BOOL isDownloadAnimationPlayed;
@property (nonatomic, weak) UILabel* usernameLabel;

- (void)updateRecordingStateTo:(BOOL)isRecording
           withCompletionBlock:(void(^)(BOOL isRecordingSuccess))completionBlock;

- (void)nudgeSelected;
- (void)itemSelected;

- (NSArray*)playerVideoURLs;
- (NSString*)firstName;

- (UIImage*)videoThumbnailImage;

- (void)updateVideoPlayingStateTo:(BOOL)isPlaying;
- (ZZGridCellViewModelState)state;

- (void)setupRecorderRecognizerOnView:(UIView*)view
                withAnimationDelegate:(id <ZZGridCellVeiwModelAnimationDelegate>)animationDelegate;

- (NSString*)videoStatus;
- (void)reloadDebugVideoStatus;

@end
