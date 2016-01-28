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
       
        __block MASViewAttribute* previousLineViewAttribute = self.mas_top;
        
        NSMutableArray* items = [NSMutableArray new];
        
        UIView* view = nil;
        
        for (NSInteger line = 0; line < numberOfLines; line++)
        {
            __block MASViewAttribute* previousViewAttribute = self.mas_left;
            
            CGFloat leftOffset = (CGRectGetWidth([UIScreen mainScreen].bounds) - (itemSize.width * 3) - (paddingBetweenItems * 2))/2;  //0;
            
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
                        make.top.equalTo(self);
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

@end
