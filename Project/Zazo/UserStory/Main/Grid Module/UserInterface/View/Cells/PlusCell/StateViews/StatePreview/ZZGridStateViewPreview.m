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

@property (nonatomic, strong) UIImageView* thumbnailImageView;
@property (nonatomic, strong) UILabel* userNameLabel;
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
    [super updateWithModel:model];
    UIImage* thumbImage = [model videoThumbnailImage];
    self.thumbnailImageView.image = thumbImage;
    self.userNameLabel.text = [model firstName];
    [self updateBadgeWithModel:model];

}

- (void)updateBadgeWithModel:(ZZGridCellViewModel*)model
{
    if ([model.badgeNumber integerValue] > 0)
    {
        [self hideAllAnimationViews];
        self.videoCountLabel.hidden = NO;
        self.userNameLabel.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
        self.backgroundColor = [ZZColorTheme shared].gridCellLayoutGreenColor;
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
        _thumbnailImageView.backgroundColor = [UIColor whiteColor];
        _thumbnailImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer* tap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(_startVideo:)];
        
        UILongPressGestureRecognizer* press =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(_recordPressed:)];
        press.minimumPressDuration = .5;
        [_thumbnailImageView addGestureRecognizer:press];
        [_thumbnailImageView addGestureRecognizer:tap];
        [self addSubview:_thumbnailImageView];
        
        [_thumbnailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self);
        }];
    }
    return _thumbnailImageView;
}

- (UILabel*)userNameLabel
{
    if (!_userNameLabel)
    {
        _userNameLabel = [UILabel new];
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        _userNameLabel.textColor = [UIColor whiteColor];
        _userNameLabel.backgroundColor = [ZZColorTheme shared].gridCellGrayColor;
        _userNameLabel.font = [UIFont an_regularFontWithSize:kUserNameFontSize];
        [self addSubview:_userNameLabel];
        
        [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.equalTo(self).dividedBy(kUserNameScaleValue);
        }];
    }
    return _userNameLabel;
}

#pragma mark - Private

- (void)_recordPressed:(UILongPressGestureRecognizer *)recognizer
{
    
    [self checkIsCancelRecordingWithRecognizer:recognizer];
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.model updateRecordingStateTo:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        if (![ZZVideoRecorder shared].didCancelRecording)
        {
            self.model.hasUploadedVideo = YES;
            [self showUploadAnimationWithCompletionBlock:^{
                [self updateWithModel:self.model];
            }];
        }
        [self.model updateRecordingStateTo:NO];
    }
}

@end
