//
//  ZZGridCellViewModel.h
//  Zazo
//
//  Created by ANODA on 01/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridDomainModel.h"

@class ZZGridCellViewModel;

@protocol ZZGridCellViewModelDelegate <NSObject>

- (void)recordingStateUpdatedToState:(BOOL)isEnabled viewModel:(ZZGridCellViewModel*)viewModel;
- (void)playingStateUpdatedToState:(BOOL)isEnabled viewModel:(ZZGridCellViewModel*)viewModel;
- (void)nudgeSelectedWithUserModel:(id)userModel;

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
@property (nonatomic, strong) NSNumber* badgeNumber;
@property (nonatomic, strong) NSNumber* prevBadgeNumber;
@property (nonatomic, strong) UIView* playerContainerView;
@property (nonatomic, assign) BOOL hasUploadedVideo;
@property (nonatomic, assign) BOOL isUploadedVideoViewed;


- (void)updateRecordingStateTo:(BOOL)isRecording;
- (void)nudgeSelected;

- (NSArray*)playerVideoURLs;
- (NSString*)firstName;

- (UIImage*)videoThumbnailImage;

- (void)updateVideoPlayingStateTo:(BOOL)isPlaying;

- (ZZGridCellViewModelState)state;

@end
