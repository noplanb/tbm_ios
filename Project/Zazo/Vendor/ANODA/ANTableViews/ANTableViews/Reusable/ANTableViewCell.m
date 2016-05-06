//
//  ANTableViewCell.m
//
//  Created by Oksana Kovalchuk on 4/11/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANTableViewCell.h"

static UIColor *kANCellSelectionColor = nil;

@implementation ANTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        /*
         self.contentView.backgroundColor = [UIColor whiteColor];
         SETTING background color for cell will overlaps table cell separator,
         if you need to set color - do it for cell self.backgroundColor = [UIColor redColor];
         */

        if (kANCellSelectionColor)
        {
            self.selectionColor = kANCellSelectionColor;
        }
    }
    return self;
}

+ (void)updateDefaultSelectionColor:(UIColor *)color
{
    kANCellSelectionColor = color;
}

- (void)updateWithModel:(id)model
{
    if ([model isKindOfClass:[NSString class]])
    {
        self.textLabel.text = model;
    }
}

@end
