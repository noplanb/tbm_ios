//
//  ZZGridCollectionCellBaseStateView+Animation.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridStateView+Animation.h"
#import "ZZGridUIConstants.h"
#import "ANAnimator.h"

@implementation ZZGridStateView (Animation)

#pragma mark - Upload Animation

- (void)_showUploadAnimation
{
//    [self _hideDownloadViews];
//    [self _showUploadViews];
    
    [self hideAllAnimationViews];
    
    [self _updateUploadViewsToDefaultState];
    
    CGFloat animValue = CGRectGetWidth(self.frame) - [self _indicatorCalculatedWidth];
    [UIView animateWithDuration:0.4 animations:^{
   
        self.leftUploadIndicatorConstraint.offset = animValue;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.uploadBarView.hidden = YES;
    }];
}


#pragma mark - Upload Views Show / Hide state

- (void)_updateUploadViewsToDefaultState
{
    [self _hideUploadViews];
    self.leftUploadIndicatorConstraint.offset = 0.0;
    [self layoutIfNeeded];
    [self _showUploadViews];
}

- (void)_showUploadViews
{
    self.leftUploadIndicatorConstraint.offset = 0;
//    self.uploadingIndicator.image = [UIImage imageNamed:@"icon-uploading-1x"];
    self.uploadBarView.hidden = NO;
    self.uploadingIndicator.hidden = NO;
}

- (void)_hideUploadViews
{
    self.uploadingIndicator.hidden = YES;
    self.uploadBarView.hidden = YES;
    self.leftUploadIndicatorConstraint.offset = 0;
}


- (void)_showUploadIconWithoutAnimation
{
    self.uploadingIndicator.hidden = NO;
    CGFloat animValue = CGRectGetWidth(self.presentedView.frame) - [self _indicatorCalculatedWidth];
    self.leftUploadIndicatorConstraint.offset = animValue;
}

- (CGFloat)_indicatorCalculatedWidth
{
    return fminf(kLayoutConstIndicatorMaxWidth, kLayoutConstIndicatorFractionalWidth * CGRectGetWidth(self.presentedView.frame));
}


#pragma mark - Download Animation part

- (void)_showDownloadAnimationWithNewVideoCount:(NSInteger)count
{
    [self _updateDownloadViewsToDefaultState];
    
    CGFloat animValue = CGRectGetWidth(self.presentedView.frame) - CGRectGetWidth(self.downloadIndicator.frame);
    
    [UIView animateWithDuration:0.6 animations:^{
        self.rightDownloadIndicatorConstraint.offset = -animValue;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self _hideDownloadViews];
            [self _showVideoCountLabelWithCount:count];
        });
    }];
}

- (void)_updateDownloadViewsToDefaultState
{
    [self hideAllAnimationViews];
    CGFloat animValue = CGRectGetWidth(self.presentedView.frame) - CGRectGetWidth(self.downloadIndicator.frame);
    self.rightDownloadIndicatorConstraint.offset = animValue;
    [self layoutIfNeeded];
    [self _showUploadViews];
}


- (void)_showDownloadAnimationWithCompletionBlock:(void (^)())completionBlock
{
    [self _hideAllAnimationViews];
    
    CGFloat animValue = CGRectGetWidth(self.presentedView.frame) - [self _indicatorCalculatedWidth];
    self.rightDownloadIndicatorConstraint.offset = 0.0;
    [self _showDownloadViews];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ANAnimator animateConstraint:self.rightDownloadIndicatorConstraint newOffset:-animValue key:@"download" delay:1.6 bouncingRate:0];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completionBlock)
            {
                [self _hideDownloadViews];
                completionBlock();
            }
            
        });
    });
}

#pragma mark - Download Views Show/Hide

- (void)_showDownloadViews
{
    self.downloadIndicator.hidden = NO;
    self.downloadBarView.hidden = NO;
}

- (void)_hideDownloadViews
{
    self.rightDownloadIndicatorConstraint.offset = 0;
    self.downloadBarView.hidden = YES;
    self.downloadIndicator.hidden = YES;
    self.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
    self.videoCountLabel.hidden = YES;
}

- (void)_showVideoCountLabelWithCount:(NSInteger)count
{
    [self _hideAllAnimationViews];
    self.videoCountLabel.hidden = NO;
    self.videoCountLabel.text = [NSString stringWithFormat:@"%li",(long)count];
    self.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
}

- (void)_hideVideoCountLabel
{
    self.videoCountLabel.hidden = YES;
}

- (void)_hideAllAnimationViews
{
    [self _hideDownloadViews];
    [self _hideUploadViews];
    [self _hideVideoCountLabel];
    self.videoViewedView.hidden = YES;
}

@end
