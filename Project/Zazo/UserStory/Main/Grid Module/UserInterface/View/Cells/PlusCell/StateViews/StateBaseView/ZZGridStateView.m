//
//  ZZGridCollectionCellBaseView.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridStateView.h"
#import "ZZGridStateView+Animation.h"
#import "ZZVideoPlayer.h"
#import "ZZGridUIConstants.h"
#import "UIImage+PDF.h"
#import "ZZVideoRecorder.h"
#import "ZZStoredSettingsManager.h"
#import "ZZFriendDataProvider.h"
#import "TBMFriend.h"
#import "ZZGridActionStoredSettings.h"


@interface ZZGridStateView ()

@end

@implementation ZZGridStateView

- (instancetype)initWithPresentedView:(UIView*)presentedView
{
    self = [super init];
    if (self)
    {
        self.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
        self.presentedView = presentedView;
    }
    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    ANDispatchBlockToMainQueue(^{
        self.model = model;
        
        // upload video animation
        if (self.model.state & ZZGridCellViewModelStateVideoWasUploaded)
        {
            [self showUploadIconWithoutAnimation];
        }
        
        model.playerContainerView = self;
        
        // Upload video was viewed
        if (self.model.state & ZZGridCellViewModelStateVideoWasViewed)
        {
            [self hideAllAnimationViews];
            self.videoViewedView.hidden = NO;
        }
        
        //download video animation
        [self _setupDownloadAnimationsWithModel:model];
        
        model.usernameLabel = self.userNameLabel;
        [self.model reloadDebugVideoStatus];
    });
}


#pragma mark - Downloaded Animation behavior

- (void)_setupDownloadAnimationsWithModel:(ZZGridCellViewModel*)model
{
    if (self.model.state & ZZGridCellViewModelStateVideoDownloading)
    {
        [self _setupBadgeWithModel:model];
        [self _setupDownloadingState];
    }
    else if (self.model.state & ZZGridCellViewModelStateVideoDownloaded)
    {
        [self _setupDownloadedStateWithModel:model];
    }
    else
    {
        [self _setupBadgeWithModel:model];
    }
}

- (void)_setupDownloadingState
{
    [self hideAllAnimationViews];
    [self showDownloadViews];
}

- (void)_setupDownloadedStateWithModel:(ZZGridCellViewModel*)model
{
    self.userNameLabel.backgroundColor =
    [model.badgeNumber  integerValue] > 0 ? [ZZColorTheme shared].gridCellLayoutGreenColor : [ZZColorTheme shared].gridCellGrayColor;
    self.model.isDownloadAnimationPlayed = YES;
    [self showDownloadAnimationWithCompletionBlock:^{
        self.userNameLabel.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
        self.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
        [self _setupBadgeWithModel:model];
    }];
}

- (void)_setupBadgeWithModel:(ZZGridCellViewModel*)model
{
    [self hideDownloadViews];
    
    if (model.state & ZZGridCellViewModelStateVideoDownloadedAndVideoCountOne)
    {
        self.userNameLabel.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
        self.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
        [self updateBadgeWithNumber:model.badgeNumber];
    }
    else if (model.state & ZZGridCellViewModelStateVideoCountMoreThatOne)
    {
        self.userNameLabel.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
        self.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
        [self updateBadgeWithNumber:model.badgeNumber];
    }
}


#pragma mark - Setup Recognizer

- (void)checkIsCancelRecordingWithRecognizer:(UILongPressGestureRecognizer*)recognizer
{
   
    if ([ZZGridActionStoredSettings shared].abortRecordHintWasShown)
    {
        UIView* recordView = recognizer.view;
        CGPoint location = [recognizer locationInView:recordView];
        if (!CGRectContainsPoint(recordView.frame,location))
        {
            [[ZZVideoRecorder shared] cancelRecordingWithReason:NSLocalizedString(@"record-dragged-finger-away", nil)];
        }
    }
}


#pragma mark - Animation Views

- (CGFloat)_indicatorCalculatedWidth
{
    return fminf(kLayoutConstIndicatorMaxWidth,
                 kLayoutConstIndicatorFractionalWidth * kGridItemSize().width);
}


#pragma mark - Animation part

- (void)hideAllAnimationViews
{
    [self _hideAllAnimationViews];
}

- (void)showUploadAnimationWithCompletionBlock:(void(^)())completionBlock;
{
    [self _showUploadAnimationWithCompletionBlock:completionBlock];
}

- (void)showDownloadAnimationWithCompletionBlock:(void(^)())completionBlock
{
    [self _showDownloadAnimationWithCompletionBlock:completionBlock];
}

- (void)updateBadgeWithNumber:(NSNumber*)badgeNumber
{
    if ([badgeNumber integerValue] > 0)
    {
        [self _showVideoCountLabelWithCount:[badgeNumber integerValue]];
    }
    else
    {
        [self _hideVideoCountLabel];
    }
}

- (void)showUploadIconWithoutAnimation
{
    [self _showUploadIconWithoutAnimation];
}

- (void)showContainFriendAnimation
{
    ANDispatchBlockToMainQueue(^{
        
        [self bringSubviewToFront:self.containFriendView];
        
        [UIView animateWithDuration:kContainFriendAnimationDuration
                              delay:kContainFreindDelayDuration
                            options:UIViewAnimationOptionLayoutSubviews animations:^{
                                self.containFriendView.alpha = 1;
                                
                            } completion:^(BOOL finished) {
                                
                                [self _hideContainFriendAnimation];
                            }];
    });
}

- (void)_hideContainFriendAnimation
{
    ANDispatchBlockToMainQueue(^{
        [UIView animateWithDuration:kContainFriendAnimationDuration animations:^{
            self.containFriendView.alpha = 0;
        }];
    });
}


- (void)showDownloadViews
{
    [self _showDownloadViews];
}

- (void)hideDownloadViews
{
    [self _hideDownloadViews];
}


#pragma mark - Lazy Load

- (UIImageView*)uploadingIndicator
{
    if (!_uploadingIndicator)
    {
        _uploadingIndicator = [UIImageView new];
        
        CGFloat width = [self _indicatorCalculatedWidth];
        CGFloat height = [self _indicatorCalculatedWidth];
        UIImage* image = [UIImage imageWithPDFNamed:@"icon_arrow" atHeight:(height/1.5)];
        _uploadingIndicator.contentMode = UIViewContentModeCenter;
        _uploadingIndicator.image = image;
        _uploadingIndicator.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
        _uploadingIndicator.hidden = YES;
        [self addSubview:_uploadingIndicator];
        CGFloat aspect = width/height;
        
        [_uploadingIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            self.leftUploadIndicatorConstraint = make.left.equalTo(self);
            make.width.equalTo(@([self _indicatorCalculatedWidth]));
            make.height.equalTo(@([self _indicatorCalculatedWidth]/aspect));
        }];
    }
    return _uploadingIndicator;
}

- (UIView*)uploadBarView
{
    if (!_uploadBarView)
    {
        _uploadBarView = [UIView new];
        _uploadBarView.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
        _uploadBarView.hidden = YES;
        [self addSubview:_uploadBarView];
        
        [_uploadBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(self);
            make.height.equalTo(@(kDownloadBarHeight));
            make.right.equalTo(self.uploadingIndicator.mas_left);
        }];
    }
    
    return _uploadBarView;
}

- (UIImageView*)downloadIndicator
{
    if (!_downloadIndicator)
    {
        _downloadIndicator = [UIImageView new];
        
        CGFloat width = [self _indicatorCalculatedWidth];
        CGFloat height = [self _indicatorCalculatedWidth];
        UIImage* image = [UIImage imageWithPDFNamed:@"home-page-arrow-left" atHeight:(height/1.5)];
        _downloadIndicator.contentMode = UIViewContentModeCenter;
        _downloadIndicator.image = image;
        _downloadIndicator.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
        _downloadIndicator.hidden = YES;
        [self addSubview:_downloadIndicator];
        CGFloat aspect = width/height;
        
        [_downloadIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            self.rightDownloadIndicatorConstraint = make.right.equalTo(self).offset(0);
            make.width.equalTo(@([self _indicatorCalculatedWidth]));
            make.height.equalTo(@([self _indicatorCalculatedWidth]/aspect));
        }];
    }
    return _downloadIndicator;
}

- (UIView*)downloadBarView
{
    if (!_downloadBarView)
    {
        _downloadBarView = [UIView new];
        _downloadBarView.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
        _downloadBarView.hidden = YES;
        [self addSubview:_downloadBarView];
        
        [_downloadBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.equalTo(self);
            make.height.equalTo(@(kDownloadBarHeight));
            make.left.equalTo(self.downloadIndicator.mas_right);
        }];
    }
    return _downloadBarView;
}

- (UILabel*)videoCountLabel
{
    if (!_videoCountLabel)
    {
        _videoCountLabel = [UILabel new];
        _videoCountLabel.backgroundColor = [UIColor redColor];
        _videoCountLabel.layer.cornerRadius = kVideoCountLabelWidth/2;
        _videoCountLabel.clipsToBounds = YES;
        _videoCountLabel.hidden = YES;
        _videoCountLabel.textColor = [UIColor whiteColor];
        _videoCountLabel.textAlignment = NSTextAlignmentCenter;
        _videoCountLabel.font = [UIFont an_regularFontWithSize:11];
        [self addSubview:_videoCountLabel];
        
        [_videoCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(3);
            make.top.equalTo(self).offset(-4);
            make.height.equalTo(@(kVideoCountLabelWidth));
            make.width.equalTo(@(kVideoCountLabelWidth));
        }];
    }
    return _videoCountLabel;
}

- (UIView*)containFriendView
{
    if (!_containFriendView)
    {
        _containFriendView = [UIView new];
        _containFriendView.alpha = 0;
        _containFriendView.backgroundColor = [UIColor yellowColor];
        [self addSubview:_containFriendView];
        
        [_containFriendView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _containFriendView;
}

- (UIImageView *)videoViewedView
{
    if (!_videoViewedView)
    {
        _videoViewedView = [UIImageView new];
        CGFloat width = [self _indicatorCalculatedWidth];
        CGFloat height = [self _indicatorCalculatedWidth];
        
        UIImage* image = [UIImage imageWithPDFNamed:@"home-page-view" atHeight:(height/2)];
        _videoViewedView.contentMode = UIViewContentModeCenter;
        _videoViewedView.image = image;
        _videoViewedView.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
        _videoViewedView.hidden = YES;
        [self addSubview:_videoViewedView];
        CGFloat aspect = width/height;
       
        [_videoViewedView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            self.rightDownloadIndicatorConstraint = make.right.equalTo(self);
            make.width.equalTo(@([self _indicatorCalculatedWidth]));
            make.height.equalTo(@(([self _indicatorCalculatedWidth]/aspect)));
        }];
    }

    return _videoViewedView;
}

- (ZZUserNameLabel*)userNameLabel
{
    if (!_userNameLabel)
    {
        _userNameLabel = [ZZUserNameLabel new];
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        _userNameLabel.textColor = [ZZColorTheme shared].gridStatusViewUserNameLabelColor;
        _userNameLabel.font = [UIFont an_regularFontWithSize:kUserNameFontSize];
        _userNameLabel.backgroundColor = [[ZZColorTheme shared].gridCellGrayColor colorWithAlphaComponent:0.8];
        [self addSubview:_userNameLabel];

        [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.equalTo(self);
            make.height.equalTo(@(kLayoutConstNameLabelHeight));
        }];
    }
    return _userNameLabel;
}

@end
