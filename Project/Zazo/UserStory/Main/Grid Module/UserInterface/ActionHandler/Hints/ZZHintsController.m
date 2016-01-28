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


static CGFloat const kDelayBeforeHintHidden = 3.5;

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
        focusFrame = CGRectMake(SCREEN_WIDTH - kEditFriendsButtonWidth, 0, kEditFriendsButtonWidth,kGridHeaderViewHeight);
    }
    
    [viewModel updateFocusFrame:focusFrame];
    
    [self.hintsView updateWithHintsViewModel:viewModel andIndex:index];
    
    [[self.delegate hintPresentedView] addSubview:self.hintsView];
    [self _removeViewAfterDelayIfNeededWithType:type];
    
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
        ANDispatchBlockAfter(kDelayBeforeHintHidden, ^{
            if (self.hintsView)
            {
                [self.hintsView removeFromSuperview];
                self.hintsView = nil;
            }
        });
    }
    if (type == ZZHintsTypeSentHint)
    {
        ANDispatchBlockAfter(kDelayBeforeHintHidden, ^{
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

//
//- (void)showHintWithModel:(ZZHintsDomainModel*)model forFocusFrame:(CGRect)focusFrame
//{
//    [self _clearView];
//    ZZHintsViewModel* viewModel = [ZZHintsViewModel viewModelWithItem:model];
//    [viewModel updateFocusFrame:focusFrame];
//    self.hintModel = model;
//    [self.hintsView updateWithHintsViewModel:viewModel];
//}
//
//#pragma mark - Private
//
//- (void)_clearView
//{
//    [_hintsView removeFromSuperview];
//    _hintsView = nil;
//}
//
//#pragma mark - Lazy Load
//
//- (ZZHintsView*)hintsView
//{
//    if (!_hintsView)
//    {
//        _hintsView = [[ZZHintsView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//        [[[UIApplication sharedApplication] keyWindow] addSubview:_hintsView];
//    }
//    return _hintsView;
//}

@end
