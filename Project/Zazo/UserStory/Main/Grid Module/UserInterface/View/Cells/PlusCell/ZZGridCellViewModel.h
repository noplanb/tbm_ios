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
- (void)stopRecording;
- (void)nudgeSelectedWithUserModel:(id)userModel;

@end

@interface ZZGridCellViewModel : NSObject

@property (nonatomic, weak) id <ZZGridCellViewModelDelegate> delegate;
@property (nonatomic, strong) ZZGridDomainModel* item;
@property (nonatomic, strong) NSNumber* badgeNumber;
@property (nonatomic, strong) UIImage* screenShot;
@property (nonatomic, assign) BOOL hasUploadedVideo;

- (void)startRecordingWithView:(UIView *)view;
- (void)stopRecording;
- (void)nudgeSelected;

@end
