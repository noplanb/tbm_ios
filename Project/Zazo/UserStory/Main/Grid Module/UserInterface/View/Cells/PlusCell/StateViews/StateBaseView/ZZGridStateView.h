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

@class ZZGridCellViewModel, ZZLoadingAnimationView, ZZCellEffectView, ZZHoldIndicator, ZZGridCell, ZZSentBadge;
@class ZZNumberBadge;

static CGFloat const kUserNameFontSize = 18;

@interface ZZGridStateView : UIView <ANModelTransfer>

@property (nonatomic, strong) ZZGridCellViewModel *model;
@property (nonatomic, strong) UIView *uploadBarView;

@property (nonatomic, strong) UIView *downloadBarView;
@property (nonatomic, strong) ZZNumberBadge *numberBadge;
@property (nonatomic, strong) ZZSentBadge *sentBadge;

@property (nonatomic, strong) ZZGridCell *presentedView;
@property (nonatomic, strong) ZZUserNameLabel *userNameLabel;
@property (nonatomic, strong) UIButton *overflowButton;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *backGradientView;
@property (nonatomic, strong) ZZLoadingAnimationView *animationView;
@property (nonatomic, strong) ZZCellEffectView *effectView;

//@property (nonatomic, strong) ZZHoldIndicator *holdIndicatorView;

- (instancetype)initWithPresentedView:(ZZGridCell *)presentedView;
- (void)updateBadgeWithNumber:(NSInteger)badgeNumber;
- (void)showUploadAnimationWithCompletionBlock:(void (^)())completionBlock;
- (void)showDownloadAnimationWithCompletionBlock:(void (^)())completionBlock;
- (void)showAppearAnimation;
- (void)updateSendBadgePosition;

@end
