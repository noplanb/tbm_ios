//
//  ZZGridCollectionCellRecordView.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridStateViewRecord.h"
#import "ZZGridUIConstants.h"

@interface ZZGridStateViewRecord ()


@end

@implementation ZZGridStateViewRecord

- (instancetype)initWithPresentedView:(UIView *)presentedView
{
    self = [super initWithPresentedView:presentedView];
    if (self)
    {
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


#pragma mark - Private

- (UILabel*)recordView
{
    if (!_recordView)
    {
        _recordView = [UILabel new];
        _recordView.text = NSLocalizedString(@"grid-controller.record.title", nil);
        _recordView.textColor = [UIColor redColor];
        _recordView.font = [UIFont an_meduimFontWithSize:14];
        _recordView.textAlignment = NSTextAlignmentCenter;
        _recordView.backgroundColor = [ZZColorTheme shared].gridStatusViewBlackColor;
        _recordView.userInteractionEnabled = YES;
        [self addSubview:_recordView];
        
        [_recordView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.userNameLabel.mas_top).with.offset(-kSidePadding);
            make.left.top.equalTo(self).offset(kSidePadding);
            make.right.equalTo(self).offset(-kSidePadding);
        }];
    }
    return _recordView;
}

@end
