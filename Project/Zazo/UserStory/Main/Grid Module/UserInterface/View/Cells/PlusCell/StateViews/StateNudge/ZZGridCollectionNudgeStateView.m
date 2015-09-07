//
//  ZZGridCollectionNudgeView.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridCollectionNudgeStateView.h"

@interface ZZGridCollectionNudgeStateView ()

@property (nonatomic, strong) UIButton* nudgeButton;
@property (nonatomic, strong) UILabel* recordView;
@property (nonatomic, strong) UILabel* userNameLabel;
@property (nonatomic, strong) UILongPressGestureRecognizer* recordRecognizer;

@end

@implementation ZZGridCollectionNudgeStateView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.recordRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_recordPressed:)];
        self.recordRecognizer.minimumPressDuration = .5;
        
        [self nudgeButton];
        [self userNameLabel];
        [self recordView];
        [self containFriendView];
        [self uploadingIndicator];
        [self uploadBarView];
        [self downloadIndicator];
        [self downloadBarView];
        [self videoCountLabel];
    }
    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    self.model = model;
    [self updateBadgeWithNumber:model.badgeNumber];
    if (model.hasUploadedVideo)
    {
        [self showUploadIconWithoutAnimation];
    }
    self.userNameLabel.text = [model firstName];
}

- (instancetype)initWithPresentedView:(UIView<ZZGridCollectionCellBaseStateViewDelegate>*)presentedView
                            withModel:(ZZGridCellViewModel*)cellViewModel
{
    self = [super initWithPresentedView:presentedView withModel:cellViewModel];
    if (self)
    {
//        self.buttonHeight = ((CGRectGetHeight(presentedView.frame) -
//                              CGRectGetHeight(presentedView.frame) / kUserNameScaleValue)/2) - kSidePadding;
        

        
//        [self _updateViewStateWithModel:cellViewModel];
    }
    
    return self;
}


#pragma mark - Actions

- (void)nudge
{
    [self.model nudgeSelected];
}


#pragma mark - Private

- (void)_recordPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.model startRecordingWithView:nil]; // TODO:
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self.model stopRecording];
        [self showUploadAnimation];
    }
}


#pragma mark - Lazy Load

- (UILabel*)userNameLabel
{
    if (!_userNameLabel)
    {
        _userNameLabel = [UILabel new];
        _userNameLabel.textAlignment = NSTextAlignmentCenter;
        _userNameLabel.textColor = [UIColor whiteColor];
        [self addSubview:_userNameLabel];
        
        [_userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.height.equalTo(self).dividedBy(kUserNameScaleValue);
        }];
    }
    return _userNameLabel;
}

- (UIButton*)nudgeButton
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
            make.top.left.equalTo(self).offset(kSidePadding);
            make.right.equalTo(self).offset(-kSidePadding);
            make.height.equalTo(self).dividedBy(kUserNameScaleValue/2).offset(-kSidePadding);
        }];
    }
    return _nudgeButton;
}

- (UILabel*)recordView
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
            make.left.equalTo(self).offset(kSidePadding);
            make.right.equalTo(self).offset(-kSidePadding);
            make.height.equalTo(self).dividedBy(kUserNameScaleValue/2).offset(-kSidePadding);
        }];
    }
    return _recordView;
}

@end
