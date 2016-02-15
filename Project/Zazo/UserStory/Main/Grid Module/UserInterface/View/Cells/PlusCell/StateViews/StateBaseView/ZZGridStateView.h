//
//  ZZGridCollectionCellBaseView.h
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridCellViewModel.h"
#import "ANModelTransfer.h"
#import "ZZUserNameLabel.h"

@class ZZGridCellViewModel;

static CGFloat const kUserNameFontSize = 18;

@interface ZZGridStateView : UIView <ANModelTransfer>

@property (nonatomic, strong) UIView* containFriendView;

@property (nonatomic, strong) ZZGridCellViewModel* model;
@property (nonatomic, strong) UIImageView* uploadingIndicator;
@property (nonatomic, strong) MASConstraint* leftUploadIndicatorConstraint;
@property (nonatomic, strong) UIView* uploadBarView;

@property (nonatomic, strong) UIImageView* downloadIndicator;
@property (nonatomic, strong) MASConstraint* rightDownloadIndicatorConstraint;
@property (nonatomic, strong) UIView* downloadBarView;
@property (nonatomic, strong) UILabel* videoCountLabel;
@property (nonatomic, strong) UIView* presentedView;
@property (nonatomic, strong) ZZUserNameLabel* userNameLabel;

@property (nonatomic, strong) UIView *backGradientView;

@property (nonatomic, strong) UIImageView* videoViewedView;

- (instancetype)initWithPresentedView:(UIView*)presentedView;

- (void)updateBadgeWithNumber:(NSInteger)badgeNumber;
- (void)showUploadAnimationWithCompletionBlock:(void(^)())completionBlock;
- (void)showContainFriendAnimation;
- (void)showUploadIconWithoutAnimation;
- (void)hideAllAnimationViews;
- (void)showDownloadAnimationWithCompletionBlock:(void(^)())completionBlock;
- (void)showDownloadViews;
- (void)hideDownloadViews;
@end
