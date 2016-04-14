//
//  ZZHintsController.m
//  Zazo
//
//  Created by ANODA on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//


#import "ZZHintsController.h"
#import "ZZHintsView.h"
#import "ZZHintsModelGenerator.h"
#import "ZZHintsViewModel.h"
#import "ZZHintsDomainModel.h"
#import "ZZGridUIConstants.h"
#import "ZZGridActionStoredSettings.h"
#import "ZZFriendDataHelper.h"


static CGFloat const kDelayBeforHintHidden = 3.5;

@interface ZZHintsController () <ZZHintsViewDelegate>

@property (nonatomic, strong) ZZHintsView* hintsView;
@property (nonatomic, assign) ZZHintsType showedHintType;


@end

@implementation ZZHintsController

- (void)showHintWithType:(ZZHintsType)type
              focusFrame:(CGRect)focusFrame
               withIndex:(NSInteger)index
               withModel:(ZZFriendDomainModel*)friendModel
         formatParameter:(NSString*)parameter
{
    
    focusFrame = CGRectOffset(focusFrame, self.frameOffset.x, self.frameOffset.y);
    
    self.showedHintType = type;
    
    if (self.hintsView &&
        [self.hintsView hintModel].hintType == ZZHintsTypeRecrodWelcomeHint &&
        ![ZZGridActionStoredSettings shared].holdToRecordAndTapToPlayWasShown &&
        [ZZFriendDataHelper unviewedVideoCountWithFriendID:friendModel.idTbm] > 0)
    {
        [self hideHintView];
        [ZZGridActionStoredSettings shared].holdToRecordAndTapToPlayWasShown = YES;
        type = ZZHintsTypeRecordAndTapToPlay;
    }
    else if  (self.hintsView)
    {
        [self hideHintView];
    }
    
    
    ZZHintsDomainModel *model = [ZZHintsModelGenerator generateHintModelForType:type];
    if (!ANIsEmpty(parameter))
    {
        model.formatParameter = parameter;
    }
    ZZHintsViewModel *viewModel = [ZZHintsViewModel viewModelWithItem:model];
    
    if (model.type == ZZHintsTypeDeleteFriendUsageHint)
    {
        focusFrame = [self _rectForEditFriendsCell];
        [self.delegate showMenuTab];
    }
    
    [viewModel updateFocusFrame:focusFrame];
    
    [self.hintsView updateWithHintsViewModel:viewModel andIndex:index];
    
    [[self.delegate hintPresentedView] addSubview:self.hintsView];
    [self _removeViewAfterDelayIfNeededWithType:type];
    
}

- (CGRect)_rectForEditFriendsCell
{
    CGFloat rowHeight = 44;
    CGFloat headerHeight = 150;
    CGFloat rowIndex = 1;
    CGFloat tableTopInset = 8;
    
    return CGRectMake(0, headerHeight + rowHeight * rowIndex + self.frameOffset.y + tableTopInset, SCREEN_WIDTH, rowHeight);
}

- (void)hideHintView
{
    if (!ANIsEmpty(self.hintsView))
    {
        [self.hintsView removeFromSuperview];
        self.hintsView = nil;
    }
}


#pragma mark - Remove after show 

- (void)_removeViewAfterDelayIfNeededWithType:(ZZHintsType)type
{
    if (type == ZZHintsTypeViewedHint)
    {
        ANDispatchBlockAfter(kDelayBeforHintHidden, ^{
            if (self.hintsView)
            {
                [self.hintsView removeFromSuperview];
                self.hintsView = nil;
            }
        });
    }
    if (type == ZZHintsTypeSentHint)
    {
        ANDispatchBlockAfter(kDelayBeforHintHidden, ^{
            if (self.hintsView && self.showedHintType == ZZHintsTypeSentHint)
            {
                [self.hintsView removeFromSuperview];
                self.hintsView = nil;
                CGFloat kDelayAfterViewRemoved = 0.3;
                ANDispatchBlockAfter(kDelayAfterViewRemoved, ^{
                    [self.delegate hintWasDismissedWithType:ZZHintsTypeSentHint];
                });
            }
        });
    }
}


#pragma mark - Lazy Load

- (ZZHintsView*)hintsView
{
    if (!_hintsView)
    {
        _hintsView = [[ZZHintsView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _hintsView.delegate = self;
    }
    return _hintsView;
}

#pragma mark - HintView Delegate

- (void)hintViewHiddenWithType:(ZZHintsType)type
{
    self.hintsView = nil;
    [self.delegate hintWasDismissedWithType:type];
}

@end
