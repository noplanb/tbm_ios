//
//  ZZGridCollectionNudgeView.m
//  Zazo
//
//  Created by Dmitriy Frolow on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridCollectionNudgeStateView.h"

@interface ZZGridCollectionNudgeStateView ()

@property (nonatomic, assign) CGFloat buttonHeight;
@property (nonatomic, strong) UIButton* nudgeButton;
@property (nonatomic, strong) UILabel* recordView;
@property (nonatomic, strong) UILabel* userNameLabel;
@property (nonatomic, strong) UILongPressGestureRecognizer* recordRecognizer;

@end

@implementation ZZGridCollectionNudgeStateView

- (instancetype)initWithPresentedView:(UIView<ZZGridCollectionCellBaseStateViewDelegate> *)presentedView withModel:(ZZGridCollectionCellViewModel *)cellViewModel
{
    self = [super initWithPresentedView:presentedView withModel:cellViewModel];
    if (self)
    {
        self.buttonHeight = ((CGRectGetHeight(self.presentedView.frame) -
                              CGRectGetHeight(self.presentedView.frame) / kUserNameScaleValue)/2) - kSidePadding;
        
        [self _setupRecognizer];
        [self nudgeButton];
        [self userNameLabel];
        [self recordView];
        [self containFriendView];
        [self uploadingIndicator];
        [self uploadBarView];
        [self downloadIndicator];
        [self downloadBarView];
        [self videoCountLabel];
        
        [self _updateViewStateWithModel:cellViewModel];
    }
    
    return self;
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

- (UIButton *)nudgeButton
{
    if (!_nudgeButton)
    {
        _nudgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
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
            make.height.equalTo(@(self.buttonHeight));
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
            make.height.equalTo(@(self.buttonHeight));
        }];
    }
    return _recordView;
}

- (void)_setupRecognizer
{
    self.recordRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(recordPressed:)];
    self.recordRecognizer.minimumPressDuration = .5;
}

- (void)_updateViewStateWithModel:(ZZGridCollectionCellViewModel *)cellViewModel
{
    if (cellViewModel.badgeNumber > 0)
    {
        [self updateBadgeWithNumber:cellViewModel.badgeNumber];
    }
    if (cellViewModel.hasUploadedVideo)
    {
        [self showUploadIconWithoutAnimation];
    }
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
        [self showUploadAnimation];
    }
}

@end
