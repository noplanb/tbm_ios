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

- (instancetype)initWithPresentedView:(UIView *)presentedView
{
    self = [super initWithPresentedView:presentedView];
    if (self)
    {
        [self backgroundView];
        [self userNameLabel];
        [self recordView];
        [self containFriendView];
//        [self uploadingIndicator];
        [self uploadBarView];
//        [self downloadIndicator];
        [self downloadBarView];
        [self videoCountLabel];
        [self videoViewedView];
    }
    
    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    [super updateWithModel:model];
//    [model removeRecordHintRecognizerFromView:self.recordView];
//    [model setupRecrodHintRecognizerOnView:self.recordView];
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
//            make.bottom.equalTo(self.userNameLabel.mas_top).with.offset(-kSidePadding);
//            make.left.top.equalTo(self).offset(kSidePadding);
//            make.right.equalTo(self).offset(-kSidePadding);
            make.centerX.equalTo(self);
            make.centerY.equalTo(self);
            
        }];
    }
    return _recordView;
}

- (void)animate
{
    [self.recordView animate];
}

@end
