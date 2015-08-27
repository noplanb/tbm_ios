//
//  ZZUserNotLoggedGridView.m
//  Zazo
//
//  Created by ANODA on 14/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//


#import "ZZUserRecorderGridView.h"
#import "ZZFriendDomainModel.h"
#import "ZZUserRecorderGridView+AnimationExtension.h"
#import "ZZVideoPlayer.h"


static CGFloat const kSidePadding = 2;
static CGFloat const kUserNameScaleValue = 5;
static CGFloat const kLayoutConstIndicatorMaxWidth = 40;
static CGFloat const kLayoutConstIndicatorFractionalWidth = 0.15;
static CGFloat const kDownloadBarHeight = 2;
static CGFloat const kVideoCountLabelWidth = 23;

@interface ZZUserRecorderGridView () <ZZVideoPlayerDelegate>

@property (nonatomic, weak) UIView <ZZUserRecorderGridViewDelegate>* presentedView;
@property (nonatomic, strong) UIButton* nudgeButton;
@property (nonatomic, strong) UILabel* recordView;
@property (nonatomic, strong) UILabel* userNameLabel;
@property (nonatomic, strong) UILongPressGestureRecognizer* recordRecognizer;
@property (nonatomic, weak) ZZFriendDomainModel* friendModel;
@property (nonatomic, assign) CGFloat nudgeButtonHeight;
@property (nonatomic, assign) CGFloat recordViewHeight;
@property (nonatomic, strong) ZZVideoPlayer* videoPlayer;

@end

@implementation ZZUserRecorderGridView

- (instancetype)initWithPresentedView:(UIView <ZZUserRecorderGridViewDelegate> *)presentedView
                      withFriendModel:(ZZFriendDomainModel *)friendModel
{
    if (self = [super init])
    {
        self.backgroundColor = [UIColor grayColor];
        self.friendModel = friendModel;
        self.presentedView = presentedView;
        
        self.recordRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(recordPressed:)];
        self.recordRecognizer.minimumPressDuration = .5;
        
        [self presentSelf];
        [self configureElementHeightDependsOnAuthType];
        [self userNameLabel];
        [self recordView];
        [self nudgeButton];
        [self uploadingIndicator];
        [self uploadBarView];
        [self downloadIndicator];
        [self downloadBarView];
        [self videoCountLabel];
        self.videoPlayer = [[ZZVideoPlayer alloc] initWithVideoPalyerView:self];
        [self bringSubviewToFront:self.userNameLabel];
    }
    
    return self;
}

- (void)presentSelf
{
    [self.presentedView addSubview:self];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.presentedView);
    }];
}

- (void)configureElementHeightDependsOnAuthType
{
    if (self.friendModel.hasApp)
    {
        self.nudgeButtonHeight = 0;
        self.recordViewHeight =
        CGRectGetHeight(self.presentedView.frame) -
        CGRectGetHeight(self.presentedView.frame) / kUserNameScaleValue - kSidePadding;
    }
    else
    {
        self.nudgeButtonHeight =
        ((CGRectGetHeight(self.presentedView.frame) -
        CGRectGetHeight(self.presentedView.frame) / kUserNameScaleValue)/2) - kSidePadding;
        self.recordViewHeight = self.nudgeButtonHeight;
    }
}

- (UIButton *)nudgeButton
{
    if (!_nudgeButton)
    {
        _nudgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nudgeButton.hidden = !self.nudgeButtonHeight > 0;
        [_nudgeButton.titleLabel setFont:[UIFont an_boldFontWithSize:16]];
        [_nudgeButton setTitle:NSLocalizedString(@"grid-controller.nudge.title", nil) forState:UIControlStateNormal];
        [_nudgeButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        [_nudgeButton addTarget:self action:@selector(nudge) forControlEvents:UIControlEventTouchUpInside];
        _nudgeButton.backgroundColor = [UIColor blackColor];
        [self addSubview:_nudgeButton];
        
        [_nudgeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).with.offset(kSidePadding);
            make.left.equalTo(self).with.offset(kSidePadding);
            make.right.equalTo(self).with.offset(-kSidePadding);
            make.height.equalTo(@(self.nudgeButtonHeight));
        }];
    }
    return _nudgeButton;
}

- (UILabel *)recordView
{
    if (!_recordView)
    {
        _recordView = [UILabel new];
        _recordView.text = NSLocalizedString(@"grid-controller.record.title", nil);
        _recordView.textColor = [UIColor redColor];
        _recordView.font = [UIFont an_boldFontWithSize:16];
        _recordView.textAlignment = NSTextAlignmentCenter;
        _recordView.backgroundColor = [UIColor blackColor];
        _recordView.userInteractionEnabled = YES;
        [_recordView addGestureRecognizer:self.recordRecognizer];
        
        [self addSubview:_recordView];
        
        [_recordView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.userNameLabel.mas_top);
            make.left.equalTo(self).with.offset(kSidePadding);
            make.right.equalTo(self).with.offset(-kSidePadding);
            make.height.equalTo(@(self.recordViewHeight));
        }];
    }
    return _recordView;
}

- (UILabel *)userNameLabel
{
    if (!_userNameLabel)
    {
        _userNameLabel = [UILabel new];
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        _userNameLabel.textColor = [UIColor whiteColor];
        _userNameLabel.text = self.friendModel.firstName;
        [self addSubview:_userNameLabel];
        
        [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.equalTo(@(CGRectGetHeight(self.presentedView.frame)/kUserNameScaleValue));
        }];
        
    }
    return _userNameLabel;
}

#pragma mark - Animation View

- (UIImageView *)uploadingIndicator
{
    if (!_uploadingIndicator)
    {
        _uploadingIndicator = [UIImageView new];
        _uploadingIndicator.image = [UIImage imageNamed:@"icon-uploading-1x"];
        [_uploadingIndicator sizeToFit];
        _uploadingIndicator.backgroundColor = [UIColor an_colorWithHexString:kLayoutConstGreenColor];
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

- (float)_indicatorCalculatedWidth
{
    return fminf(kLayoutConstIndicatorMaxWidth, kLayoutConstIndicatorFractionalWidth * CGRectGetWidth(self.presentedView.frame));
}

- (UIView *)uploadBarView
{
    if (!_uploadBarView)
    {
        _uploadBarView = [UIView new];
        _uploadBarView.backgroundColor = [UIColor an_colorWithHexString:kLayoutConstGreenColor];
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

- (UIImageView *)downloadIndicator
{
    if (!_downloadIndicator)
    {
        _downloadIndicator = [UIImageView new];
        _downloadIndicator.image = [UIImage imageNamed:@"icon-downloading-1x"];
        [_downloadIndicator sizeToFit];
        _downloadIndicator.backgroundColor = [UIColor an_colorWithHexString:kLayoutConstGreenColor];
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

- (UIView *)downloadBarView
{
    if (!_downloadBarView)
    {
        _downloadBarView = [UIView new];
        _downloadBarView.backgroundColor = [UIColor an_colorWithHexString:kLayoutConstGreenColor];
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

- (UILabel *)videoCountLabel
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

#pragma mark - VidePlayer Delegate

- (void)videoPlayerStarted
{

}

- (void)videoPlayerStopped
{

}

#pragma mark - Actions

- (void)nudge
{
    [self.presentedView nudgePressed];
}

- (void)recordPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.presentedView startRecording];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self.presentedView stopRecording];
        
        //TODO: add animation after success file download, now only for test:
        [self _showUploadAnimation];
    }
}

- (void)showUploadAnimation
{
    [self _showUploadAnimation];
}

- (void)showDownloadAnimationWithNewVideoCount:(NSInteger)count
{
    [self _showDownloadAnimationWithNewVideoCount:count];
}

@end
