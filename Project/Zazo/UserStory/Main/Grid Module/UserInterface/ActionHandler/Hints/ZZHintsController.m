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
#import "UIView+ZZAdditions.h"

static CGFloat const kDelayBeforHintHidden = 3.5;

@interface ZZHintsController () <ZZHintsViewDelegate>

@property (nonatomic, strong) ZZHintsView *hintsView;
@property (nonatomic, assign) ZZHintsType showedHintType;

@property (nonatomic, weak) PlaybackIndicator *indicator;

@end

@implementation ZZHintsController

- (void)showHintWithType:(ZZHintsType)type
              focusFrame:(CGRect)focusFrame
               withIndex:(NSInteger)index
               withModel:(ZZFriendDomainModel *)friendModel
         formatParameter:(NSString *)parameter
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
    else if (self.hintsView)
    {
        [self hideHintView];
    }

    ZZHintsDomainModel *model = [ZZHintsModelGenerator generateHintModelForType:type];
    
    if (model.type == ZZHintsTypePlaybackControlsUsageHint)
    {
        PlaybackIndicator *indicator = [PlaybackIndicator new];
        
        NSArray *scheme = @[[[PlaybackSegment alloc] initWithType:ZZIncomingEventTypeVideo],
                            [[PlaybackSegment alloc] initWithType:ZZIncomingEventTypeVideo],
                            [[PlaybackSegment alloc] initWithType:ZZIncomingEventTypeVideo]];
        
        indicator.segmentScheme = scheme;
        indicator.segmentProgress = 0.5;
        
        [self.hintsView addSubview:indicator];
        
        [indicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.hintsView);
            make.centerY.equalTo(self.hintsView.mas_bottom).offset(-60);
            make.height.equalTo(@22);
        }];
        
        [self.hintsView layoutIfNeeded];
        
        indicator.userInteractionEnabled = NO;
        [indicator blinkAnimatedTimes:3];
        
        focusFrame = indicator.frame;
        focusFrame.origin.y += 10;
        focusFrame.size.height += 100;
        
        self.indicator = indicator;
    }
    else
    {
        [self.indicator removeFromSuperview];
    }
    
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
    else
    {
        [self.delegate showGridTab];
    }

    [viewModel updateFocusFrame:focusFrame];

    [self.hintsView updateWithHintsViewModel:viewModel andIndex:index];
    
    [[self.delegate hintPresentedView] addSubview:self.hintsView];
    [self _removeViewAfterDelayIfNeededWithType:type];

}

- (CGRect)_rectForEditFriendsCell
{
    CGFloat rowHeight = 44;
    CGFloat headerHeight = 166;
    CGFloat rowIndex = 2;
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

- (ZZHintsView *)hintsView
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
