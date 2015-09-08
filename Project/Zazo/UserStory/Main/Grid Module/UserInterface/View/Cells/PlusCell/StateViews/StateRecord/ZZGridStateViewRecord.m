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

@property (nonatomic, strong) UILabel* userNameLabel;
@property (nonatomic, strong) UILabel* recordView;

@end

@implementation ZZGridStateViewRecord

- (instancetype)init
{
    self = [super init];
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
    }
    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    self.userNameLabel.text = [model firstName];
    [self updateBadgeWithNumber:model.badgeNumber];
    if (model.hasUploadedVideo)
    {
        [self showUploadIconWithoutAnimation];
    }
}


#pragma mark - Private

- (void)_recordPressed:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.model updateRecordingStateTo:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded)
    {
        [self.model updateRecordingStateTo:NO];
        [self showUploadAnimation];
    }
}

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
            make.height.equalTo(self).dividedBy(kUserNameScaleValue / 2).offset(-kSidePadding);
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
        
        UILongPressGestureRecognizer* press = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(_recordPressed:)];
        press.minimumPressDuration = .5;
        
        [_recordView addGestureRecognizer:press];
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
