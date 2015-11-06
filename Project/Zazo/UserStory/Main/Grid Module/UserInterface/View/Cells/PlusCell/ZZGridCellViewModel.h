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
- (void)cancelRecordingWithReason:(NSString *)reason;

- (void)playingStateUpdatedToState:(BOOL)isEnabled
                         viewModel:(ZZGridCellViewModel*)viewModel;

- (void)nudgeSelectedWithUserModel:(id)userModel;
- (BOOL)isVideoPlaying;
- (BOOL)isGridRotate;
- (void)addUserToItem:(ZZGridCellViewModel*)model;
- (BOOL)isGridCellEnablePlayingVideo:(ZZGridCellViewModel*)model;
- (BOOL)isNetworkEnabled;

@end



typedef NS_OPTIONS(NSInteger, ZZGridCellViewModelState)
{
    //base state
    ZZGridCellViewModelStateNone = 0,
    ZZGridCellViewModelStateAdd = 1 << 1,
    ZZGridCellViewModelStateFriendHasApp = 1 << 2,
    ZZGridCellViewModelStateFriendHasNoApp = 1 << 3,
    ZZGridCellViewModelStatePreview = 1 << 4,
    //additional state
    ZZGridCellViewModelStateVideoWasUploaded = 1 << 5,
    ZZGridCellViewModelStateVideoWasViewed = 1 << 6,
    ZZGridCellViewModelStateVideoDownloading = 1 << 7,
    ZZGridCellViewModelStateVideoDownloaded = 1 << 8,
    ZZGridCellViewModelStateNeedToShowGreenBorder = 1 << 9,
    //badge state
    ZZGridCellViewModelStateVideoDownloadedAndVideoCountOne = 1 << 10,
    ZZGridCellViewModelStateVideoCountMoreThatOne = 1 << 11,
    ZZGridCellViewModelStateVideoFailedPermanently = 1 << 12,
    ZZGridCellViewModelStateVideoFirstVideoDownloading = 1 << 13
};

@interface ZZGridCellViewModel : NSObject

@property (nonatomic, strong) ZZGridDomainModel* item;
@property (nonatomic, weak) id <ZZGridCellViewModelDelegate> delegate;
@property (nonatomic, weak) id <ZZGridCellVeiwModelAnimationDelegate> animationDelegate;
@property (nonatomic, assign) NSInteger badgeNumber;
@property (nonatomic, assign) NSInteger prevBadgeNumber;
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
- (UIImage*)thumbnailPlaceholderImage;

- (void)updateVideoPlayingStateTo:(BOOL)isPlaying;
- (ZZGridCellViewModelState)state;

- (void)setupRecorderRecognizerOnView:(UIView*)view
                withAnimationDelegate:(id <ZZGridCellVeiwModelAnimationDelegate>)animationDelegate;

- (NSString*)videoStatus;
- (void)reloadDebugVideoStatus;
- (BOOL)isEnablePlayingVideo;
- (BOOL)isVideoPlayed;
@end
