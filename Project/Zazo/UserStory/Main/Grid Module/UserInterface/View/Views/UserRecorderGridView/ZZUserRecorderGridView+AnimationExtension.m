//
//  ZZUserRecorderGridView+AnimationExtension.m
//  Zazo
//
//  Created by ANODA on 18/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZUserRecorderGridView+AnimationExtension.h"

@implementation ZZUserRecorderGridView (AnimationExtension)

#pragma mark - Upload Animation

- (void)_showUploadAnimation
{
    [self _hideDownloadViews];
    [self _showUploadViews];
    
    CGFloat animValue = CGRectGetWidth(self.frame) - CGRectGetWidth(self.uploadingIndicator.frame);
    [UIView animateWithDuration:0.4 animations:^{
        self.leftUploadIndicatorConstraint.offset = animValue;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.uploadBarView.hidden = YES;
        [self showDownloadAnimationWithNewVideoCount:1];
    }];
}

#pragma mark - Upload Views Show/Hide state

- (void)_showUploadViews
{
    self.leftUploadIndicatorConstraint.offset = 0;
    self.uploadingIndicator.image = [UIImage imageNamed:@"icon-uploading-1x"];
    self.uploadBarView.hidden = NO;
    self.uploadingIndicator.hidden = NO;
}

- (void)_hideUploadViews
{
    self.uploadingIndicator.hidden = YES;
    self.uploadBarView.hidden = YES;
    self.leftUploadIndicatorConstraint.offset = 0;
}


#pragma mark - Download Animation part


- (void)_showDownloadAnimationWithNewVideoCount:(NSInteger)count
{
    [self _hideUploadViews];
    [self _showDownloadViews];
    
    CGFloat animValue = CGRectGetWidth(self.frame) - CGRectGetWidth(self.downloadIndicator.frame);
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
    self.backgroundColor = [UIColor an_colorWithHexString:kLayoutConstGreenColor];

}

- (void)_hideVieoCountLabel
{
    self.videoCountLabel.hidden = YES;
}

@end
