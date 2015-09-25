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

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.hintsView];
    }
    return self;
}

- (void)showHintWithModel:(ZZHintsDomainModel*)model forFocusFrame:(CGRect)focusFrame
{
    ZZHintsViewModel* viewModel = [ZZHintsViewModel viewModelWithItem:model];
    [viewModel updateFocusFrame:focusFrame];
    self.hintModel = model;
    //[self _destroyHintView];
    [self.hintsView updateWithHintsViewModel:viewModel];
}

#pragma mark - Private
- (void)_destroyHintView
{
    [self.hintsView removeFromSuperview];
    self.hintsView = nil;
}

#pragma mark - Lazy Load

- (ZZHintsView*)hintsView
{
    if (!_hintsView)
    {
        _hintsView = [[ZZHintsView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _hintsView;
}

@end
