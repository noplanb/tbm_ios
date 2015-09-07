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
@property (nonatomic, assign) ZZGridCellViewModelState state;
@property (nonatomic, weak) id <ZZGridCellViewModelDelegate> delegate;
@property (nonatomic, strong) NSNumber* badgeNumber;
@property (nonatomic, strong) UIView* playerContainerView;


@property (nonatomic, strong) UIImage* screenShot;
@property (nonatomic, assign) BOOL hasUploadedVideo;



- (void)startRecordingWithView:(UIView*)view;
- (void)stopRecording;
- (void)nudgeSelected;

- (NSArray*)playerVideoURLs;
- (NSString*)firstName;

@end
