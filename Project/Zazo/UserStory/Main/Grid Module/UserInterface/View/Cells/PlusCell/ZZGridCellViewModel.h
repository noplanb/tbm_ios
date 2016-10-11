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

typedef NS_ENUM(NSUInteger, ZZCellState) {
    ZZCellStateNone,
    ZZCellStateAdd,
    ZZCellStateHasNoApp,
    ZZCellStateHasApp,
    ZZCellStatePreview
};

typedef NS_ENUM(NSUInteger, ZZCellVideoState) {
    ZZCellVideoStateNone,
    ZZCellVideoStateUploaded,
    ZZCellVideoStateViewed,
    ZZCellVideoStateDownloading,
    ZZCellVideoStateDownloaded,
    ZZCellVideoStateFailed
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
@property (nonatomic, assign) BOOL hasMessages;
@property (nonatomic, strong) NSDate *lastMessageDate;
@property (nonatomic, assign, readonly) BOOL isRecording;
@property (nonatomic, weak) UILabel *usernameLabel;
@property (nonatomic, strong) UIImage *thumbnail;

- (NSString *)firstName;

- (ZZCellState)friendState;
- (ZZCellVideoState)videoState;

- (void)reloadDebugVideoStatus;
- (BOOL)isEnablePlayingVideo;

- (void)setupRecorderRecognizerOnView:(UIView *)view
                withAnimationDelegate:(id <ZZGridCellViewModelAnimationDelegate>)animationDelegate;

// MARK: Events

- (void)didChangeRecordingState:(BOOL)isRecording
                     completion:(void (^)(BOOL isRecordingSuccess))completionBlock;
- (void)didTapCell;
- (void)didTapEmptyCell;
- (void)didTapOverflowButton:(UIButton *)button;

- (void)recordPressed:(UILongPressGestureRecognizer *)recognizer;
- (void)stopVideoRecording;

@end
