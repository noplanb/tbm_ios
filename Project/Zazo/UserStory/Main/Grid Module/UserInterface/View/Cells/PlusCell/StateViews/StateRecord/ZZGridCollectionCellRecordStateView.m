//
//  ZZGridCollectionCellRecordView.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridCollectionCellRecordStateView.h"

@interface ZZGridCollectionCellRecordStateView ()

@property (nonatomic, strong) UILabel* userNameLabel;
@property (nonatomic, strong) UILabel* recordView;
@property (nonatomic, strong) UILongPressGestureRecognizer* recordRecognizer;

@end

@implementation ZZGridCollectionCellRecordStateView

- (instancetype)initWithPresentedView:(UIView<ZZGridCollectionCellBaseStateViewDelegate> *)presentedView
                            withModel:(ZZGridCellViewModel *)cellViewModel
{
    self = [super initWithPresentedView:presentedView withModel:cellViewModel];
    if (self)
    {
        [self _setupRecognizer];
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

- (UILabel*)userNameLabel
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
            make.bottom.equalTo(self.userNameLabel.mas_top).with.offset(-kSidePadding);
            make.left.equalTo(self).with.offset(kSidePadding);
            make.right.equalTo(self).with.offset(-kSidePadding);
            make.top.equalTo(self).with.offset(kSidePadding);
        }];
    }
    return _recordView;
}

- (void)_setupRecognizer
{
    self.recordRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(recordPressed:)];
    self.recordRecognizer.minimumPressDuration = .5;
}


- (void)_updateViewStateWithModel:(ZZGridCellViewModel *)cellViewModel
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
