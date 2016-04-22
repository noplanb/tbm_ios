//
//  ANTableView.m
//
//  Created by Oksana Kovalchuk on 4/11/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANTableView.h"
#import "ANDefines.h"
#import "UIColor+ANAdditions.h"

static CGFloat const kDefaultTableViewCellHeight = 44;
static CGFloat const kDefaultTableViewHeaderHeight = 40;

@interface ANTableView ()

@end

@implementation ANTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        self.delaysContentTouches = NO;
        self.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;

        [self setupAppearance];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self layoutTableFooterView];
}

//thanks to Dmitry Nesterenko
- (void)layoutTableFooterView
{
    if (self.bottomStickedFooterView == nil)
        return;
    
    __block CGFloat footerContentMinY, footerContentMaxY;
    [self.tableFooterView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGRect frame = [obj frame];
        if (idx == 0)
        {
            footerContentMinY = CGRectGetMinY(frame);
            footerContentMaxY = CGRectGetMaxY(frame);
        }
        else {
            footerContentMinY = MIN(CGRectGetMinY(frame), footerContentMinY);
            footerContentMaxY = MAX(CGRectGetMaxY(frame), footerContentMaxY);
        }
    }];
    
    // frame
    CGFloat height = MAX(MAX(self.contentSize.height,
                             self.frame.size.height) - self.tableFooterView.frame.origin.y,
                         footerContentMaxY - footerContentMinY + 10.0);
    
    self.tableFooterView.frame = CGRectMake(0,
                                            self.tableFooterView.frame.origin.y,
                                            self.frame.size.width,
                                            height);
}

- (void)setBottomStickedFooterView:(UIView *)bottomStickedFooterView
{
    _bottomStickedFooterView = bottomStickedFooterView;
    self.tableFooterView = bottomStickedFooterView;
}

- (void)setupAppearance
{
    self.rowHeight = kDefaultTableViewCellHeight;
    self.sectionHeaderHeight = kDefaultTableViewHeaderHeight;
    
    self.backgroundColor = [UIColor clearColor];
    self.backgroundView = nil;
    self.separatorColor = [UIColor an_colorWithHexString:@"D7D6DA"];
}

- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
    // Because we set delaysContentTouches = NO, we return YES for UIButtons
    // so that scrolling works correctly when the scroll gesture
    // starts in the UIButtons.
    if ([view isKindOfClass:[UIButton class]])
    {
        return YES;
    }
    
    return [super touchesShouldCancelInContentView:view];
}

@end
