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


static CGFloat const kDelayBeforHintHidden = 3.5;

@interface ZZHintsController () <ZZHintsViewDelegate>

@property (nonatomic, strong) ZZHintsView* hintsView;

@end

@implementation ZZHintsController

- (void)showHintWithType:(ZZHintsType)type focusFrame:(CGRect)focusFrame withIndex:(NSInteger)index formatParameter:(NSString*)parameter
{
    
    if (self.hintsView &&
        [self.hintsView hintModel].hintType == ZZHintsTypeRecrodWelcomeHint &&
        ![ZZGridActionStoredSettings shared].holdToRecordAndTapToPlayWasShown)
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
    
    [[self.delegate hintPresetedView] addSubview:self.hintsView];
    [self _removeViewAfterDelayIfNeededWithType:type];
    
}

- (void)hideHintView
{
    [self.hintsView removeFromSuperview];
    self.hintsView = nil;
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
            if (self.hintsView)
            {
                [self.hintsView removeFromSuperview];
                self.hintsView = nil;
                CGFloat kDelayAfterViewRemoved = 0.3;
                ANDispatchBlockAfter(kDelayAfterViewRemoved, ^{
                    [self.delegate hintWasDissmissedWithType:ZZHintsTypeSentHint];
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
    [self.delegate hintWasDissmissedWithType:type];
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
