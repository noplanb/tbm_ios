//
//  ZZGridCollectionCell.m
//  Zazo
//
//  Created by ANODA on 12/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZGridCell.h"
#import "ZZGridStateView.h"
#import "ZZRecordButtonView.h"
#import "ZZGridStateViewRecord.h"
#import "ZZGridStateViewPreview.h"
#import "ZZAddContactButton.h"
#import "ZZSentBadge.h"
#import "ZZNumberBadge.h"
#import "ZZLoadingAnimationView.h"

@class ZZAddContactButton;

static CGFloat ZZCellCornerRadius = 4.0f;
static CGFloat ZZCellBorderWidth = 4.0f;

@interface ZZGridCell () <ZZGridCellViewModelAnimationDelegate>

@property (nonatomic, strong) ZZGridCellViewModel *model;
@property (nonatomic, strong) ZZAddContactButton *plusButton;
@property (nonatomic, strong) ZZGridStateView *stateView;
@property (nonatomic, strong) ZZFriendDomainModel *cellFriendModel;
@property (nonatomic, assign) ZZCellState currentFriendState;
@property (nonatomic, assign) ZZCellVideoState currentVideoState;

@end

@implementation ZZGridCell

- (instancetype)init
{
    if (self = [super init])
    {
        self.backgroundColor = [ZZColorTheme shared].gridCellBorderColor;
        self.clipsToBounds = NO;
        self.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.layer.cornerRadius = ZZCellCornerRadius;
        self.layer.shadowColor = [ZZColorTheme shared].gridCellShadowColor.CGColor;
        self.layer.shadowRadius = 2.0f;
        self.layer.shadowOffset = CGSizeZero;
        self.layer.shadowOpacity = 1.0f;

        self.currentFriendState = ZZCellStateNone;
        self.currentVideoState = ZZCellVideoStateNone;
        
        [self plusButton];
    }
    return self;
}

- (void)updateWithModel:(ZZGridCellViewModel *)model
{
    ANDispatchBlockToMainQueue(^{
        self.model = model;
        [self reloadStateViewIfNeeded];
        [self.stateView updateWithModel:self.model];
        [self storeCurrentState];
        [self _showBorderIfNeeded];
    });
}

- (void)storeCurrentState
{
    self.currentFriendState = self.model.friendState;
    self.currentVideoState = self.model.videoState;
    self.cellFriendModel = self.model.item.relatedUser;
}

- (void)_showBorderIfNeeded
{
    [self _setBorderHidden:self.model.badgeNumber == 0];
}

- (void)reloadStateViewIfNeeded
{
    if (![self _needsToReloadBaseView])
    {
        return;
    }
    
    switch (self.model.friendState)
    {
        case ZZCellStateHasApp:
        case ZZCellStateHasNoApp:
            self.stateView = [[ZZGridStateViewRecord alloc] initWithPresentedView:self];
            break;
            
        case ZZCellStatePreview:
            self.stateView = [[ZZGridStateViewPreview alloc] initWithPresentedView:self];
            break;
            
        default:
            [self clearCell];
            break;
    }
    
    [self _setupRecordRecognizerWithModel:self.model];
    //        [self _configureActiveBorderIfNeededWithModel:model];

}

- (void)clearCell
{
    [self _updatePlusButtonImage];
    
    if (self.stateView)
    {
        self.currentFriendState = ZZCellStateNone;
        self.currentVideoState = ZZCellVideoStateNone;
        [self.stateView removeFromSuperview];
    }
}

- (void)setBadgesHidden:(BOOL)hidden
{
    CGFloat alpha = hidden ? 0 : 1;
    self.stateView.sentBadge.alpha = alpha;
    self.stateView.numberBadge.alpha = alpha;
    
    if (hidden)
    {
        [self _setBorderHidden:YES];
    }
    else
    {
        [self _showBorderIfNeeded];
    }
}

- (void)_setBorderHidden:(BOOL)flag
{
    if (flag)
    {
        self.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        self.backgroundColor = [ZZColorTheme shared].tintColor;
    }
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
}

- (void)setDownloadProgress:(CGFloat)progress
{
    self.stateView.animationView.downloadProgress = progress;
}

- (BOOL)_needsToReloadBaseView
{
    if (![self.cellFriendModel isEqual:self.model.item.relatedUser])
    {
        return YES;
    }
    
    if (self.currentFriendState == ZZCellStateNone)
    {
        return YES;
    }

    if (self.model.friendState != self.currentFriendState)
    {
        return YES;
    }

    return NO;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
}

#pragma mark - Record recognizer;

- (void)_setupRecordRecognizerWithModel:(ZZGridCellViewModel *)model
{
    if ([self.stateView isKindOfClass:[ZZGridStateViewRecord class]])
    {
        ZZGridStateViewRecord *recordStateView = (ZZGridStateViewRecord *)self.stateView;
        [model setupRecorderRecognizerOnView:recordStateView withAnimationDelegate:self];
    }
    else if ([self.stateView isKindOfClass:[ZZGridStateViewPreview class]])
    {
        ZZGridStateViewPreview *previewStateView = (ZZGridStateViewPreview *)self.stateView;
        [model setupRecorderRecognizerOnView:previewStateView.thumbnailImageView withAnimationDelegate:self];
    }
}

#pragma mark - Delegate

- (void)setStateView:(ZZGridStateView *)stateView
{
    if (_stateView != stateView)
    {
        [_stateView removeFromSuperview];
        _stateView = stateView;
    }
    [self addSubview:stateView];
    [stateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets([self _defaultInsets]);
    }];

    [stateView layoutIfNeeded];

}

#pragma mark - Animation part

- (void)showContainFriendAnimation
{
    [self.stateView showAppearAnimation];
}

- (void)_itemSelected:(id)r
{
    [self.model didTapEmptyCell];
}

- (ZZAddContactButton *)plusButton
{
    if (!_plusButton)
    {
        _plusButton = [ZZAddContactButton new];

        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_itemSelected:)];

        [_plusButton addGestureRecognizer:recognizer];
        
        UILongPressGestureRecognizer *longPressRecognizer =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(_itemSelected:)];
        
        longPressRecognizer.minimumPressDuration = 0.8;
        [self addGestureRecognizer:longPressRecognizer];
        
        [self addSubview:_plusButton];
        [self sendSubviewToBack:_plusButton];

        [_plusButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).with.insets([self _defaultInsets]);
        }];
    }
    return _plusButton;
}

- (void)_hidePlusButtonAnimated
{
    [self.plusButton setPlusViewHidden:YES
                              animated:YES
                            completion:nil];
}

- (void)hideAllAnimations
{
//    [self.stateView hideAllAnimationViews];
    [self.model reloadDebugVideoStatus];
}

- (void)_updatePlusButtonImage
{
    //TODO: not very good solution:

    static ZZGridCell *activeCell;

    if (self.model.hasActiveContactIcon && activeCell.model.item.index != self.model.item.index)
    {
        activeCell.plusButton.isActive = NO;
        activeCell = self;
    }

    // end TODO

    self.plusButton.isActive = self.model.hasActiveContactIcon;
}

- (UIEdgeInsets)_defaultInsets
{
    return UIEdgeInsetsMake(ZZCellBorderWidth, ZZCellBorderWidth, ZZCellBorderWidth, ZZCellBorderWidth);
}

#pragma mark - Aniamtion Delegate Methods

- (void)showUploadAnimation
{
    [self.stateView showUploadAnimationWithCompletionBlock:^{
        [self.model reloadDebugVideoStatus];
    }];
}

- (void)showSentAnimation
{
    [self.stateView showUploadAnimationWithCompletionBlock:^{
       
    }];
}

@end
