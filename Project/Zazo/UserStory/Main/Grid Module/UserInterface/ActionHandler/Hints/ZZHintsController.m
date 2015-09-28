//
//  ZZHintsController.m
//  Zazo
//
//  Created by ANODA on 9/21/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZHintsController.h"
#import "ZZHintsView.h"
#import "ZZHintsViewModel.h"
#import "ZZHintsDomainModel.h"

@interface ZZHintsController ()

@property (nonatomic, strong) ZZHintsView* hintsView;

@end

@implementation ZZHintsController

- (void)showHintWithModel:(ZZHintsDomainModel*)model forFocusFrame:(CGRect)focusFrame
{
    [self _clearView];
    ZZHintsViewModel* viewModel = [ZZHintsViewModel viewModelWithItem:model];
    [viewModel updateFocusFrame:focusFrame];
    self.hintModel = model;
    [self.hintsView updateWithHintsViewModel:viewModel];
}

#pragma mark - Private

- (void)_clearView
{
    [_hintsView removeFromSuperview];
    _hintsView = nil;
}

#pragma mark - Lazy Load

- (ZZHintsView*)hintsView
{
    if (!_hintsView)
    {
        _hintsView = [[ZZHintsView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        [[[UIApplication sharedApplication] keyWindow] addSubview:_hintsView];
    }
    return _hintsView;
}

@end
