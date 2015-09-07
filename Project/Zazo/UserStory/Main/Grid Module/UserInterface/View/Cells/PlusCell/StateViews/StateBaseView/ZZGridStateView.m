//
//  ZZGridCollectionCellBaseView.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridStateView.h"
#import "ZZGridCollectionCellBaseStateView+Animation.h"
#import "ZZVideoPlayer.h"

@interface ZZGridStateView ()

@end

@implementation ZZGridStateView

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    
}

- (instancetype)initWithPresentedView:(UIView <ZZGridCollectionCellBaseStateViewDelegate> *)presentedView
                            withModel:(ZZGridCellViewModel *)cellViewModel;
{
    if (self = [super init])
    {
        self.videoPlayer = [[ZZVideoPlayer alloc] initWithVideoPlayerView:presentedView];
        self.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
        self.friendModel = cellViewModel.item.relatedUser;
        self.presentedView = presentedView;
        
        [self.presentedView addSubview:self];
        //    [self.presentedView sendSubviewToBack:self];
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.presentedView);
        }];
    }
    return self;
}


#pragma mark - Animation Views



- (CGFloat)_indicatorCalculatedWidth
{
    return fminf(kLayoutConstIndicatorMaxWidth,
                 kLayoutConstIndicatorFractionalWidth * CGRectGetWidth(self.presentedView.frame));
}



#pragma mark - Animation part

- (void)showUploadAnimation
{
    [self _showUploadAnimation];
}

- (void)showDownloadAnimationWithNewVideoCount:(NSInteger)count
{
    [self _showDownloadAnimationWithNewVideoCount:count];
}

- (void)updateBadgeWithNumber:(NSNumber *)badgeNumber
{
    if (badgeNumber > 0)
    {
        [self _showVideoCountLabelWithCount:[badgeNumber integerValue]];
    }
    else
    {
        [self _hideVieoCountLabel];
    }
}


- (void)showUploadIconWithoutAnimation
{
    [self _showUploadIconWithoutAnimation];
}

#pragma mark - Video Player Actions

- (void)setupPlayerWithUrl:(NSURL*)url
{
    [self.videoPlayer setupMoviePlayerWithContentUrl:url];
}

- (void)stopPlayVideo
{
    [self.videoPlayer stopVideo];
}

- (void)startPlayVideo
{
    [self.presentedView makeActualScreenShoot];
    [self.videoPlayer playVideo];
}

- (BOOL)isVideoPlayerPlaying
{
    return [self.videoPlayer isPlaying];
}


- (void)showContainFriendAnimation
{
    [UIView animateWithDuration:kContainFriendAnimationDuration
                          delay:kContainFreindDelayDuration
                        options:UIViewAnimationOptionLayoutSubviews animations:^{
                            self.containFriendView.alpha = kShowedingAlphaValue;
                        } completion:^(BOOL finished) {
                            [self _hideContainFriendAnimation];
                        }];
}

- (void)_hideContainFriendAnimation
{
    [UIView animateWithDuration:kContainFriendAnimationDuration animations:^{
        self.containFriendView.alpha = kHiddenAlphaValue;
    }];
}

- (UIImageView*)uploadingIndicator
{
    if (!_uploadingIndicator)
    {
        _uploadingIndicator = [UIImageView new];
        _uploadingIndicator.image = [UIImage imageNamed:@"icon-uploading-1x"];
        [_uploadingIndicator sizeToFit];
        _uploadingIndicator.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
        _uploadingIndicator.hidden = YES;
        [self addSubview:_uploadingIndicator];
        
        CGFloat aspect = CGRectGetWidth(_uploadingIndicator.frame)/CGRectGetHeight(_uploadingIndicator.frame);
        
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
        _downloadIndicator.image = [UIImage imageNamed:@"icon-downloading-1x"];
        [_downloadIndicator sizeToFit];
        _downloadIndicator.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
        _downloadIndicator.hidden = YES;
        [self addSubview:_downloadIndicator];
        
        CGFloat aspect = CGRectGetWidth(_downloadIndicator.frame)/CGRectGetHeight(_downloadIndicator.frame);
        
        [_downloadIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            self.rightDownloadIndicatorConstraint = make.right.equalTo(self);
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
        _videoCountLabel.layer.masksToBounds = YES;
        _videoCountLabel.hidden = YES;
        _videoCountLabel.textColor = [UIColor whiteColor];
        
        _videoCountLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_videoCountLabel];
        [_videoCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).with.offset(3);
            make.top.equalTo(self).with.offset(-3);
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

@end
