//
//  TBMTextField.m
//  tbm
//
//  Created by Sani Elfishawy on 11/4/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMTextField.h"

@implementation TBMTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.layer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
        self.layer.cornerRadius = 4.0;
        self.layer.masksToBounds = YES;
        self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.4].CGColor;
        self.layer.borderWidth = 1.0;
    }
    return self;
}

- (void)drawPlaceholderInRect:(CGRect)rect
{
    [[self placeholder] drawInRect:CGRectInset(rect, 0, (rect.size.height - self.font.lineHeight) / 2.0)
                    withAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : self.font}];
}

@end
