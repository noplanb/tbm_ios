//
//  ZZGridCollectionCellBaseView.h
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridCellViewModel.h"

static CGFloat const kSidePadding = 2;
static CGFloat const kUserNameScaleValue = 5;
static CGFloat const kLayoutConstIndicatorMaxWidth = 40;
static CGFloat const kLayoutConstIndicatorFractionalWidth = 0.15;
static CGFloat const kDownloadBarHeight = 2;
static CGFloat const kVideoCountLabelWidth = 23;

static CGFloat const kContainFriendAnimationDuration = 0.20;
static CGFloat const kContainFreindDelayDuration = 0.16;
static CGFloat const kShowedingAlphaValue = 1.0;
static CGFloat const kHiddenAlphaValue = 0.0;

@protocol ZZGridCollectionCellBaseStateViewDelegate  <NSObject>

- (void)nudgePressed;
- (void)startRecording;
- (void)stopRecording;
- (void)makeActualScreenShoot;

@end

@interface ZZGridCollectionCellBaseStateView : UIView

@property (nonatomic, strong) UIView* containFriendView;

@property (nonatomic, strong) UIImageView* uploadingIndicator;
@property (nonatomic, strong) MASConstraint* leftUploadIndicatorConstraint;
@property (nonatomic, strong) UIView* uploadBarView;

@property (nonatomic, strong) UIImageView* downloadIndicator;
@property (nonatomic, strong) MASConstraint* rightDownloadIndicatorConstraint;
@property (nonatomic, strong) UIView* downloadBarView;
@property (nonatomic, strong) UILabel* videoCountLabel;

@property (nonatomic, weak) ZZFriendDomainModel* friendModel;

@property (nonatomic, weak) UIView <ZZGridCollectionCellBaseStateViewDelegate>* presentedView;

- (instancetype)initWithPresentedView:(UIView <ZZGridCollectionCellBaseStateViewDelegate> *)presentedView
                            withModel:(ZZGridCellViewModel *)cellViewModel;

- (void)updateBadgeWithNumber:(NSNumber *)badgeNumber;
- (void)showUploadAnimation;
- (void)showDownloadAnimationWithNewVideoCount:(NSInteger)count;
- (void)showContainFriendAnimation;
- (void)setupPlayerWithUrl:(NSURL *)url;
- (void)stopPlayVideo;
- (void)startPlayVideo;
- (BOOL)isVideoPlayerPlaying;
- (void)showUploadIconWithoutAnimation;

@end
