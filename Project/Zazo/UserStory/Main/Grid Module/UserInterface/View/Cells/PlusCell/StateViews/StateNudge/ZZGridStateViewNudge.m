//
//  ZZGridCollectionNudgeView.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridStateViewNudge.h"
#import "ZZGridUIConstants.h"
#import "ZZGridCellViewModel.h"

@interface ZZGridStateViewNudge ()

@property (nonatomic, strong) UIButton* nudgeButton;

@end

@implementation ZZGridStateViewNudge

- (instancetype)initWithPresentedView:(UIView *)presentedView
{
    self = [super initWithPresentedView:presentedView];
    if (self)
    {
        [self nudgeButton];
        [self userNameLabel];
        [self recordView];
        [self containFriendView];
        [self uploadingIndicator];
        [self uploadBarView];
        [self downloadIndicator];
        [self downloadBarView];
        [self videoCountLabel];
        [self videoViewedView];
    }
    
    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    [super updateWithModel:model];
    [model removeRecordHintRecognizerFromView:self.recordView];
    [model setupRecrodHintRecognizerOnView:self.recordView];
}


#pragma mark - Actions

- (void)_nudge
{
    [self.model nudgeSelected];
}


#pragma mark - Private


#pragma mark - Lazy Load

- (UIButton*)nudgeButton
{
    if (!_nudgeButton)
    {
        _nudgeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_nudgeButton.titleLabel setFont:[UIFont an_meduimFontWithSize:15]];
        [_nudgeButton setTitle:NSLocalizedString(@"grid-controller.nudge.title", nil) forState:UIControlStateNormal];
        [_nudgeButton setTitleColor:[ZZColorTheme shared].gridStatusViewNudgeColor forState:UIControlStateNormal];
        [_nudgeButton addTarget:self action:@selector(_nudge) forControlEvents:UIControlEventTouchUpInside];
        _nudgeButton.backgroundColor = [ZZColorTheme shared].gridStatusViewBlackColor;
        [self addSubview:_nudgeButton];
        
        [_nudgeButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.equalTo(self).offset(kSidePadding);
            make.right.equalTo(self).offset(-kSidePadding);
            make.height.equalTo(@((kGridItemSize().height - kLayoutConstNameLabelHeight)/2 - kSidePadding));
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
        _recordView.textColor = [ZZColorTheme shared].gridStatusViewRecordColor;
        _recordView.font = [UIFont an_meduimFontWithSize:14];
        _recordView.textAlignment = NSTextAlignmentCenter;
        _recordView.backgroundColor = [ZZColorTheme shared].gridStatusViewBlackColor;
        _recordView.userInteractionEnabled = YES;
        [self addSubview:_recordView];
        
        [_recordView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.userNameLabel.mas_top);
            make.left.equalTo(self).offset(kSidePadding);
            make.right.equalTo(self).offset(-kSidePadding);
//            make.height.equalTo(self).dividedBy(kUserNameScaleValue/2).offset(-kSidePadding);
            
            make.height.equalTo(@((kGridItemSize().height - kLayoutConstNameLabelHeight)/2 - kSidePadding));
        }];
    }
    return _recordView;
}

@end
