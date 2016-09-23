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
@property (nonatomic, strong, readonly) UILabel *textLabel; // Displayed above cell when dim view is shown
@property (nonatomic, weak, readonly) UIGestureRecognizer *dimTapRecognizer;

@end

@implementation ZZGridContainerView

- (instancetype)initWithSegmentsCount:(NSInteger)segmentsCount
{
    self = [super init];
    if (self)
    {
        CGSize itemSize = kGridItemSize();

        NSInteger numberOfItemsInRow = 3;
        NSInteger numberOfLines = 3;

        NSMutableArray *items = [NSMutableArray new];

        UIView *view = nil;

        for (NSInteger line = 0; line < numberOfLines; line++)
        {
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
                }];

                [items addObject:view];
            }
        }
        self.items = [items copy];
    }
    return self;
}

- (void)layoutSublayersOfLayer:(CALayer *)layer
{
    [self.touchObserver placeCells];
}

@end
