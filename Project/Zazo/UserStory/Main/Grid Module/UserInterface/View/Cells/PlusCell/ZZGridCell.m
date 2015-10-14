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
#import "TBMFriend.h"

@interface ZZGridCell () <ZZGridCellVeiwModelAnimationDelegate>

@property (nonatomic, strong) ZZGridCellViewModel* model;
@property (nonatomic, strong) UIButton* plusButton;
@property (nonatomic, strong) UIGestureRecognizer* plusRecognizer;
@property (nonatomic, strong) ZZGridStateView* stateView;

@end

@implementation ZZGridCell

- (instancetype)init
{
    if (self = [super init])
    {
        self.backgroundColor = [ZZColorTheme shared].gridCellOrangeColor;
        self.clipsToBounds = NO;
        [self plusButton];
    }
    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    ANDispatchBlockToMainQueue(^{
        self.model = model;
        [self updateStateViewWithModel:model];
        [self _setupRecordRecognizerWithModel:model];
    });
}

- (void)updateStateViewWithModel:(ZZGridCellViewModel*)model
{
    ANDispatchBlockToMainQueue(^{
        switch (model.state)
        {
            case ZZGridCellViewModelStateFriendHasApp:
            {
                self.stateView = [[ZZGridStateViewRecord alloc] initWithPresentedView:self];
                
            } break;
            case ZZGridCellViewModelStateFriendHasNoApp:
            {
                self.stateView = [[ZZGridStateViewNudge alloc] initWithPresentedView:self];
                
            } break;
            case ZZGridCellViewModelStateIncomingVideoViewed:
            case ZZGridCellViewModelStateIncomingVideoNotViewed:
            case ZZGridCellViewModelStateOutgoingVideo:
            {
                self.stateView = [[ZZGridStateViewPreview alloc] initWithPresentedView:self];
                
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
    });
}


#pragma mark - Record recognizer;

- (void)_setupRecordRecognizerWithModel:(ZZGridCellViewModel *)model
{
    if ([self.stateView isKindOfClass:[ZZGridStateViewNudge class]])
    {
        ZZGridStateViewNudge* nudgeStateView = (ZZGridStateViewNudge*)self.stateView;
        [model setupRecorderRecognizerOnView:nudgeStateView.recordView withAnimationDelegate:self];
    }
    else if ([self.stateView isKindOfClass:[ZZGridStateViewRecord class]])
    {
        ZZGridStateViewRecord* recordStateView = (ZZGridStateViewRecord*)self.stateView;
        [model setupRecorderRecognizerOnView:recordStateView.recordView withAnimationDelegate:self];
    }
    else if ([self.stateView isKindOfClass:[ZZGridStateViewPreview class]])
    {
        ZZGridStateViewPreview* previewStateView = (ZZGridStateViewPreview*)self.stateView;
        [model setupRecorderRecognizerOnView:previewStateView.thumbnailImageView withAnimationDelegate:self];
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
    [self addSubview:stateView];
    [stateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}


#pragma mark - Animation part

- (void)showContainFriendAnimation
{
    [self.stateView showContainFriendAnimation];
}

- (void)showDownloadAnimationWithCompletionBlock:(void(^)())completionBlock
{
    [self.stateView showDownloadAnimationWithCompletionBlock:completionBlock];
}

- (void)_itemSelected
{
    [self.model itemSelected];
}

- (UIButton*)plusButton
{
    if (!_plusButton)
    {
        _plusButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage* image = [[UIImage imageWithPDFNamed:@"icon_plus" atHeight:50]
                                an_imageByTintingWithColor:[ZZColorTheme shared].gridCellPlusWhiteColor];
        
        [_plusButton setImage:image forState:UIControlStateNormal];
        _plusButton.showsTouchWhenHighlighted = NO;
        _plusButton.reversesTitleShadowWhenHighlighted = NO;
        [_plusButton addTarget:self action:@selector(_itemSelected) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_plusButton];
        [self sendSubviewToBack:_plusButton];
        
        [_plusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return _plusButton;
}

- (void)hideAllAnimations
{
    [self.stateView hideAllAnimationViews];
    [self.model reloadDebugVideoStatus];
}


#pragma mark - Aniamtion Delegate Methods

- (void)showUploadAnimation
{
    [self.stateView showUploadAnimationWithCompletionBlock:^{
        if (self.model.badgeNumber > 0)
        {
            [self.stateView updateBadgeWithNumber:self.model.badgeNumber];
        }
        [self.model reloadDebugVideoStatus];
    }];
}

@end
