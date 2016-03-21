//
//  ZZGridContainerView.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/1/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridContainerView.h"
#import "ZZGridUIConstants.h"
#import "ZZGridCell.h"
#import "ZZGridCenterCell.h"
#import "ZZGridRotationTouchObserver.h"

@interface ZZGridContainerView ()

@property (nonatomic, strong) UIView *dimView;
@property (nonatomic, weak) ZZGridCell *activeCell;

@end

@implementation ZZGridContainerView

- (instancetype)initWithSegmentsCount:(NSInteger)segmentsCount
{
    self = [super init];
    if (self)
    {
        CGSize itemSize = kGridItemSize();
        
        CGFloat paddingBetweenItems = kGridItemSpacing();
        CGFloat paddingBetweenLines = kGridItemSpacing();
        NSInteger numberOfItemsInRow = 3;
        NSInteger numberOfLines = 3;
       
        __block MASViewAttribute* previousLineViewAttribute = nil;
        
        NSMutableArray* items = [NSMutableArray new];
        
        UIView* view = nil;
        
        for (NSInteger line = 0; line < numberOfLines; line++)
        {
            __block MASViewAttribute* previousViewAttribute = self.mas_left;
            
            CGFloat leftOffset = 0;
            
            for (NSInteger row = 0; row < numberOfItemsInRow; row++)
            {
                if ((line == 1) && (row == 1))
                {
                    view = [ZZGridCenterCell new];
                }
                else
                {
                    view = [ZZGridCell new];
                }
                
                view.accessibilityLabel = [NSString stringWithFormat:@"Cell %ld-%ld", (long)line, (long)row];
                
                [self addSubview:view];

                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@(itemSize.width));
                    make.height.equalTo(@(itemSize.height));
                    make.left.equalTo(previousViewAttribute).offset(leftOffset);
                    if (previousLineViewAttribute)
                    {
                        make.top.equalTo(previousLineViewAttribute).offset(paddingBetweenLines);
                    }
                    else
                    {
                        make.top.equalTo(self.mas_top);
                    }
                }];
                
                [items addObject:view];
                previousViewAttribute = view.mas_right;
                leftOffset = paddingBetweenItems;
            }
            previousLineViewAttribute = view.mas_bottom;
        }
        self.items = [items copy];
    }
    return self;
}

- (void)showDimScreenForItemWithIndex:(NSUInteger)index
{
    self.activeCell = (id)self.items[index];
    
    if (![self.activeCell isKindOfClass:[ZZGridCell class]])
    {
        return;
    }
    
    [self bringSubviewToFront:self.dimView];
    [self bringSubviewToFront:self.activeCell];
    
    [self restoreFrames]; // bringSubviewToFront resets cell's frames (why?!)
    
    [UIView animateWithDuration:0.4
                     animations:^{
        _dimView.alpha = 1;
        [self.activeCell setBadgesHidden:YES];
    }];
}

- (void)restoreFrames
{
    [self layoutSubviews]; // placeCells doesn't work without this (why?!)
    [self.touchObserver placeCells];
}

- (void)hideDimScreen
{
    [UIView animateWithDuration:0.4
                     animations:^{
        _dimView.alpha = 0;
        [self.activeCell setBadgesHidden:NO];

    } completion:^(BOOL finished) {

        [self sendSubviewToBack:self.dimView];
        [self restoreFrames];
        
        self.activeCell = nil;
        
    }];
}

- (UIView *)dimView
{
    if (!_dimView)
    {
        _dimView = [UIView new];
        _dimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        _dimView.alpha = 0;
        
        [self addSubview:_dimView];
        
        [_dimView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(-kGridItemSpacing(), -kGridItemSpacing(), -kGridItemSpacing(), -kGridItemSpacing()));
        }];
    }
    
    return _dimView;
}


@end
