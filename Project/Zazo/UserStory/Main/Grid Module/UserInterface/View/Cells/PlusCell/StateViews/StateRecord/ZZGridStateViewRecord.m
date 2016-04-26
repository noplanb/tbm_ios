//
//  ZZGridCollectionCellRecordView.m
//  Zazo
//
//  Created by ANODA on 02/09/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZGridStateViewRecord.h"
#import "ZZGridUIConstants.h"
#import "ZZRecordButtonView.h"

@interface ZZGridStateViewRecord ()


@end

@implementation ZZGridStateViewRecord

- (instancetype)initWithPresentedView:(ZZGridCell *)presentedView
{
    self = [super initWithPresentedView:presentedView];
    if (self)
    {
        [self backgroundView];
        [self userNameLabel];
        [self recordView];
        [self uploadBarView];
        [self downloadBarView];
        [self animationView];
        [self numberBadge];
        [self sentBadge];
    }
    
    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    [super updateWithModel:model];
}

#pragma mark - Private

- (ZZRecordButtonView *)recordView
{
    if (!_recordView)
    {
        _recordView = [ZZRecordButtonView new];
        _recordView.userInteractionEnabled = YES;
        [self addSubview:_recordView];
        _recordView.tintColor = self.backgroundView.tintColor;
        
        UITapGestureRecognizer *recognizer =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(animate)];

        [_recordView addGestureRecognizer:recognizer];
        
        [_recordView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.centerY.equalTo(self).offset(-16);
            make.width.equalTo(self.mas_width).multipliedBy(3.0f/4.0f).priorityHigh();
            make.width.lessThanOrEqualTo(@85);
            make.height.equalTo(_recordView.mas_width);
        }];
    }
    return _recordView;
}

- (void)animate
{
    [self.recordView animate];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

@end
