//
//  ZZGridCollectionCellPreviewView.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridStateViewPreview.h"
#import "ZZGridUIConstants.h"
#import "ZZVideoRecorder.h"

static CGFloat const kThumbnailBorderWidth = 2;

@interface ZZGridStateViewPreview ()

@property (nonatomic, assign) BOOL isVideoPlaying;

@end

@implementation ZZGridStateViewPreview


- (instancetype)initWithPresentedView:(UIView *)presentedView
{
    self = [super initWithPresentedView:presentedView];
    if (self)
    {
        [self thumbnailImageView];
        [self userNameLabel];
        [self containFriendView];
        [self videoViewedView];
    }
    
    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    ANDispatchBlockToMainQueue(^{
        [super updateWithModel:model];
        UIImage* thumbImage = [model videoThumbnailImage];
        if (!thumbImage)
        {
            self.thumbnailImageView.contentMode = UIViewContentModeCenter;
            CGSize size = CGSizeMake(20, 20);
            thumbImage = [UIImage imageWithPDFNamed:@"contacts-placeholder" atSize:size];
        }
        else
        {
            self.thumbnailImageView.contentMode = UIViewContentModeScaleToFill;
        }
        self.thumbnailImageView.image = thumbImage;
        [self updateBadgeWithModel:model];
    });
}

- (void)updateBadgeWithModel:(ZZGridCellViewModel*)model
{
    if ([model.badgeNumber integerValue] > 0)
    {
//        [self hideAllAnimationViews];
//        self.videoCountLabel.hidden = NO;
        self.userNameLabel.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
        self.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
//        [self showDownloadAnimationWithNewVideoCount:[model.badgeNumber integerValue]];
        [self _showThumbnailGreenBorder];
    }
}

- (void)_showThumbnailGreenBorder
{
    self.thumbnailImageView.layer.borderColor = [ZZColorTheme shared].gridCellLayoutGreenColor.CGColor;
    self.thumbnailImageView.layer.borderWidth = kThumbnailBorderWidth;
}

- (void)_hideThumbnailGreenBorder
{
    self.thumbnailImageView.layer.borderColor = [UIColor clearColor].CGColor;
    self.thumbnailImageView.layer.borderWidth = 0.0;
}

- (void)_startVideo:(UITapGestureRecognizer *)recognizer
{
    if (!self.superview.isHidden)
    {
        [self hideAllAnimationViews];
        [self _hideThumbnailGreenBorder];
        self.userNameLabel.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
        [self.model updateVideoPlayingStateTo:YES];
    }
}


#pragma mark - Lazy Load

- (UIImageView*)thumbnailImageView
{
    if (!_thumbnailImageView)
    {
        _thumbnailImageView = [UIImageView new];
//        _thumbnailImageView.backgroundColor = [UIColor clearColor];
        _thumbnailImageView.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
//        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFit;
        _thumbnailImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer* tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(_startVideo:)];
        [_thumbnailImageView addGestureRecognizer:tap];
        [self addSubview:_thumbnailImageView];
        
        [_thumbnailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self);
        }];
    }
    return _thumbnailImageView;
}

@end
