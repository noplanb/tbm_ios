//
//  ZZGridCollectionCell.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCell.h"
#import "ZZFriendDomainModel.h"
#import "ZZGridCellViewModel.h"
#import "UIImage+PDF.h"
#import "TBMVideoRecorder.h"
#import "ZZVideoRecorder.h"
#import "ZZGridStateView.h"

#import "ZZGridStateViewNudge.h"
#import "ZZGridStateViewRecord.h"
#import "ZZGridStateViewPreview.h"

@interface ZZGridCell ()

@property (nonatomic, strong) ZZGridCellViewModel* model;
@property (nonatomic, strong) UIImageView* plusImageView;
@property (nonatomic, strong) UIGestureRecognizer* plusRecognizer;
@property (nonatomic, strong) ZZGridStateView* stateView;

@end

@implementation ZZGridCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor orangeColor];
        [self plusImageView];
    }
    return self;
}

- (void)prepareForReuse
{
    [self.model updateVideoPlayingStateTo:NO];
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    ANDispatchBlockToMainQueue(^{
       
        self.model = model;
    
        switch (model.state)
        {
            case ZZGridCellViewModelStateFriendHasApp:
            {
                self.stateView = [ZZGridStateViewRecord new];
            } break;
            case ZZGridCellViewModelStateFriendHasNoApp:
            {
                self.stateView = [ZZGridStateViewNudge new];
            } break;
            case ZZGridCellViewModelStateIncomingVideoViewed:
            case ZZGridCellViewModelStateIncomingVideoNotViewed:
            case ZZGridCellViewModelStateOutgoingVideo:
            {
                self.stateView = [ZZGridStateViewPreview new];
            } break;
            default:
            {
                [self.stateView removeFromSuperview];
            } break;
        }
    });
}


#pragma mark - Delegate

- (void)setStateView:(ZZGridStateView*)stateView
{
    if (_stateView != stateView)
    {
        [_stateView removeFromSuperview];
        _stateView = stateView;
    }
    [self.contentView addSubview:stateView];
    [stateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.contentView);
    }];
}


#pragma mark - Animation part

- (void)showContainFriendAnimation
{
    [self.stateView showContainFriendAnimation];
}

- (void)showUploadVideoAnimationWithCount:(NSInteger)count
{
    [self.stateView showDownloadAnimationWithNewVideoCount:count];
}

- (UIImageView*)plusImageView
{
    if (!_plusImageView)
    {
        _plusImageView = [UIImageView new];
        _plusImageView.image = [[UIImage imageWithPDFNamed:@"icon_plus" atHeight:50]
                                an_imageByTintingWithColor:[UIColor whiteColor]];
        _plusImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_plusImageView];
        [self sendSubviewToBack:_plusImageView];
        
        [_plusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _plusImageView;
}

@end
