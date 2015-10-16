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
#import "TBMFriend.h"

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
        [self _setupThumbnailWithModel:model];
        self.userNameLabel.hidden = NO;
    });
}


#pragma mark - Private

- (void)_setupThumbnailWithModel:(ZZGridCellViewModel*)model
{
    UIImage* thumbImage = [model videoThumbnailImage];
    
    if (!thumbImage)
    {
        self.thumbnailImageView.contentMode = UIViewContentModeCenter;
        self.thumbnailImageView.backgroundColor = [ZZColorTheme shared].gridStatusViewThumbnailDefaultColor;
        CGSize size = CGSizeMake(30, 30);
        thumbImage = [[UIImage imageWithPDFNamed:@"contacts-placeholder-withoutborder2" atSize:size]
                      an_imageByTintingWithColor:[ZZColorTheme shared].menuTextColor];
    }
    else
    {
        self.thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.thumbnailImageView.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
    }
    
    self.thumbnailImageView.image = thumbImage;
    
    if ([model.badgeNumber integerValue] > 0
        && self.model.item.relatedUser.lastIncomingVideoStatus != INCOMING_VIDEO_STATUS_DOWNLOADING)
    {
        [self _showThumbnailGreenBorder];
    }
    else
    {
        [self _hideThumbnailGreenBorder];
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
    if (!self.superview.isHidden && [self.model isEnablePlayingVideo])
    {
        [self hideAllAnimationViews];
        [self _hideThumbnailGreenBorder];
        self.userNameLabel.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
        self.userNameLabel.hidden = YES;
        [self.model updateVideoPlayingStateTo:YES];
    }
}


#pragma mark - Lazy Load

- (UIImageView*)thumbnailImageView
{
    if (!_thumbnailImageView)
    {
        _thumbnailImageView = [UIImageView new];
        _thumbnailImageView.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
        _thumbnailImageView.userInteractionEnabled = YES;
        _thumbnailImageView.clipsToBounds = YES;
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
