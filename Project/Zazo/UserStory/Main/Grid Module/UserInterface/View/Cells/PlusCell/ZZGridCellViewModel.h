//
//  ZZGridCellViewModel.h
//  Zazo
//
//  Created by ANODA on 01/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridDomainModel.h"

@class ZZGridCellViewModel;

@protocol ZZGridCellViewModelAnimationDelegate <NSObject>

- (void)showUploadAnimation;

@end

@protocol ZZGridModelPresenterInterface <NSObject>

- (BOOL)isGridRotate;

- (void)viewModelDidTapOverflowButton:(ZZGridCellViewModel *)viewModel;
- (void)viewModelDidTapCell:(ZZGridCellViewModel *)viewModel;

- (void)viewModel:(ZZGridCellViewModel *)viewModel
didChangeRecordingState:(BOOL)isRecording
       completion:(void (^)(BOOL isRecordingSuccess))completionBlock;

- (void)addUserToItem:(ZZGridCellViewModel *)model;
- (BOOL)isGridCellEnablePlayingVideo:(ZZGridCellViewModel *)model;
- (void)nudgeSelectedWithUserModel:(id)userModel;
- (void)cancelRecordingWithReason:(NSString *)reason;

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
    ZZGridCellViewModelStateNeedToShowBorder = 1 << 9,

    //badge state
            ZZGridCellViewModelStateVideoDownloadedAndVideoCountOne = 1 << 10,
    ZZGridCellViewModelStateVideoCountMoreThatOne = 1 << 11,
    ZZGridCellViewModelStateVideoFailedPermanently = 1 << 12,
    ZZGridCellViewModelStateVideoFirstVideoDownloading = 1 << 13
};

@interface ZZGridCellViewModel : NSObject

@property (nonatomic, strong) ZZGridDomainModel *item;
@property (nonatomic, weak) id <ZZGridModelPresenterInterface> presenter;
@property (nonatomic, weak) id <ZZGridCellViewModelAnimationDelegate> animationDelegate;
@property (nonatomic, assign) NSInteger badgeNumber;
@property (nonatomic, weak) UIView *playerContainerView;
@property (nonatomic, assign) BOOL isUploadedVideoViewed;
@property (nonatomic, assign) BOOL hasUploadedVideo;
@property (nonatomic, assign) BOOL hasDownloadedVideo;
@property (nonatomic, assign) BOOL hasActiveContactIcon;
@property (nonatomic, assign) BOOL hasThumbnail;
@property (nonatomic, assign) BOOL hasMessages;
@property (nonatomic, strong) NSDate *lastMessageDate;
@property (nonatomic, assign, readonly) BOOL isRecording;
@property (nonatomic, weak) UILabel *usernameLabel;

- (NSString *)firstName;

- (UIImage *)videoThumbnailImage;

- (ZZGridCellViewModelState)state;

- (void)setupRecorderRecognizerOnView:(UIView *)view
                withAnimationDelegate:(id <ZZGridCellViewModelAnimationDelegate>)animationDelegate;

- (void)reloadDebugVideoStatus;

- (BOOL)isEnablePlayingVideo;

// MARK: Events

- (void)didChangeRecordingState:(BOOL)isRecording
                     completion:(void (^)(BOOL isRecordingSuccess))completionBlock;
- (void)didTapCell;
- (void)didTapEmptyCell;
- (void)didTapOverflowButton:(UIButton *)button;

@end