//
//  ZZGridCollectionCellBaseStateView+Animation.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridStateView+Animation.h"
#import "ZZGridUIConstants.h"


@implementation ZZGridStateView (Animation)

#pragma mark - Upload Animation

- (void)_showUploadAnimation
{
    [self _hideDownloadViews];
    [self _showUploadViews];
    
    CGFloat animValue = CGRectGetWidth(self.frame) - [self _indicatorCalculatedWidth];
    [UIView animateWithDuration:0.4 animations:^{
   
        self.leftUploadIndicatorConstraint.offset = animValue;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.uploadBarView.hidden = YES;
    }];
}


#pragma mark - Upload Views Show / Hide state

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
    [self _hideUploadViews];
    [self _showDownloadViews];
    
    CGFloat animValue = CGRectGetWidth(self.presentedView.frame) - CGRectGetWidth(self.downloadIndicator.frame);
    [UIView animateWithDuration:0.4 animations:^{
        self.rightDownloadIndicatorConstraint.offset = -animValue;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self _hideDownloadViews];
        [self _showVideoCountLabelWithCount:count];
    }];
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
    self.backgroundColor = [UIColor grayColor];
    self.videoCountLabel.hidden = YES;
}

- (void)_showVideoCountLabelWithCount:(NSInteger)count
{
    self.videoCountLabel.hidden = NO;
    self.videoCountLabel.text = [NSString stringWithFormat:@"%li",(long)count];
    self.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
}

- (void)_hideVideoCountLabel
{
    self.videoCountLabel.hidden = YES;
}

@end
