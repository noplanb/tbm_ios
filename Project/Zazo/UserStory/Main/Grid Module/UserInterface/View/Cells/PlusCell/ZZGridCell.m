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
#import "ZZGridStateView.h"

#import "ZZGridStateViewNudge.h"
#import "ZZGridStateViewRecord.h"
#import "ZZGridStateViewPreview.h"

#import "UIImage+PDF.h"

@interface ZZGridCell () <ZZGridCellVeiwModelAnimationDelegate>

@property (nonatomic, strong) ZZGridCellViewModel* model;
@property (nonatomic, strong) UIButton* plusButton;
@property (nonatomic, strong) UIGestureRecognizer* plusRecognizer;
@property (nonatomic, strong) ZZGridStateView* stateView;
@property (nonatomic, assign) ZZGridCellViewModelState currentViewState;
@property (nonatomic, strong) ZZFriendDomainModel* cellFriendModel; //TODO: domain models should be short lived
@end

@implementation ZZGridCell

- (instancetype)init
{
    if (self = [super init])
    {
        self.backgroundColor = [ZZColorTheme shared].gridCellOrangeColor;
        self.clipsToBounds = NO;
        self.currentViewState = ZZGridCellViewModelStateNone;
        [self plusButton];
    }
    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel*)model
{
    ANDispatchBlockToMainQueue(^{
        self.model = model;
        [self updateStateViewWithModel:model];
    });
}

- (void)updateStateViewWithModel:(ZZGridCellViewModel*)model
{
    ANDispatchBlockToMainQueue(^{
        
        if ([self _isNeedToChangeStateViewWithModel:model])
        {
            if (model.state & ZZGridCellViewModelStateAdd)
            {
                if (self.stateView)
                {
                    self.currentViewState = ZZGridCellViewModelStateNone;
                    [self.stateView removeFromSuperview];
                }
            }
            else if (model.state & ZZGridCellViewModelStateFriendHasApp)
            {
                self.stateView = [[ZZGridStateViewRecord alloc] initWithPresentedView:self];
            }
            else if (model.state & ZZGridCellViewModelStateFriendHasNoApp)
            {
                self.stateView = [[ZZGridStateViewNudge alloc] initWithPresentedView:self];
            }
            else if (model.state & ZZGridCellViewModelStatePreview)
            {
                self.stateView = [[ZZGridStateViewPreview alloc] initWithPresentedView:self];
            }
            else
            {
                [self.stateView removeFromSuperview];
            }
            
            [self _setupRecordRecognizerWithModel:model];
        }
        
        
        if (self.stateView)
        {
            self.currentViewState = model.state;
            [self.stateView updateWithModel:self.model];
        }
        
    });
}

- (BOOL)_isNeedToChangeStateViewWithModel:(ZZGridCellViewModel*)model
{
    BOOL isNeedChange = YES;
    if ([self.cellFriendModel isEqual:model.item.relatedUser] &&
        self.currentViewState != ZZGridCellViewModelStateNone
        && (model.state & self.currentViewState))
    {
        isNeedChange = NO;
    }
    self.cellFriendModel = model.item.relatedUser;
    
    return isNeedChange;
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
        [model removeRecordHintRecognizerFromView:self];
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

- (void)_itemSelectedWithRecognizer:(UILongPressGestureRecognizer*)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        [self _itemSelected];
    }
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
        [_plusButton addTarget:self action:@selector(_itemSelected) forControlEvents:UIControlEventTouchUpInside];
        UILongPressGestureRecognizer* longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(_itemSelectedWithRecognizer:)];
        longPressRecognizer.minimumPressDuration = 0.8;
        [_plusButton addGestureRecognizer:longPressRecognizer];
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
