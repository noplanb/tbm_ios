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
        self.backgroundColor = [ZZColorTheme shared].gridCellOrangeColor;
        [self plusImageView];
    }
    return self;
}

- (void)prepareForReuse
{
    self.model = nil;
    [self.stateView removeFromSuperview];
    [self.model updateVideoPlayingStateTo:NO];
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    ANDispatchBlockToMainQueue(^{
        self.model = model;
        if ([self.model.badgeNumber integerValue] > 0)
        {
            
            if (self.model.prevBadgeNumber == self.model.badgeNumber)
            {
                [self updateStateViewWithModel:self.model];
                [self.stateView updateBadgeWithNumber:self.model.badgeNumber];
            }
            else
            {
                [self updateStateViewWithModel:model];
                [self showDownloadAnimationWithCompletionBlock:^{
                    [self.stateView updateBadgeWithNumber:self.model.badgeNumber];
                    self.model.prevBadgeNumber = self.model.badgeNumber;
                }];
            }
            
        }
        else
        {
            [self updateStateViewWithModel:model];
        }
    });
}

- (void)updateStateViewWithModel:(ZZGridCellViewModel*)model
{
    switch (model.state)
    {
        case ZZGridCellViewModelStateFriendHasApp:
        {
            self.stateView = [[ZZGridStateViewRecord alloc] initWithPresentedView:self.contentView];
            
        } break;
        case ZZGridCellViewModelStateFriendHasNoApp:
        {
            self.stateView = [[ZZGridStateViewNudge alloc] initWithPresentedView:self.contentView];
            
        } break;
        case ZZGridCellViewModelStateIncomingVideoViewed:
        case ZZGridCellViewModelStateIncomingVideoNotViewed:
        case ZZGridCellViewModelStateOutgoingVideo:
        {
            self.stateView = [[ZZGridStateViewPreview alloc] initWithPresentedView:self.contentView];
            
        } break;
        default:
        {
            [self.stateView removeFromSuperview];
            
        } break;
    }
    
    if (self.stateView)
    {
        [self.stateView updateWithModel:self.model];
    }

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

- (void)showDownloadVideoAnimationWithCount:(NSInteger)count
{
    [self.stateView showDownloadAnimationWithNewVideoCount:count];
}

- (void)showDownloadAnimationWithCompletionBlock:(void(^)())completionBlock
{
    [self.stateView showDownloadAnimationWithCompletionBlock:completionBlock];
}

- (UIImageView*)plusImageView
{
    if (!_plusImageView)
    {
        _plusImageView = [UIImageView new];
        _plusImageView.image = [[UIImage imageWithPDFNamed:@"icon_plus" atHeight:50]
                                an_imageByTintingWithColor:[ZZColorTheme shared].gridCellPlusWhiteColor];
        _plusImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:_plusImageView];
        [self sendSubviewToBack:_plusImageView];
        
        [_plusImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _plusImageView;
}

- (void)hideAllAnimations
{
    [self.stateView hideAllAnimationViews];
}

@end
