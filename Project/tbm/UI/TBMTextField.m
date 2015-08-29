//
//  TBMTextField.m
//  tbm
//
//  Created by Sani Elfishawy on 11/4/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMTextField.h"
#import <QuartzCore/QuartzCore.h>

@implementation TBMTextField
@synthesize nextField;

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    self.layer.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
    self.layer.cornerRadius = 4.0;
    self.layer.masksToBounds = YES;
    self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.4].CGColor;
    self.layer.borderWidth = 1.0;
}

- (void)drawPlaceholderInRect:(CGRect)rect {
    [[self placeholder] drawInRect:CGRectInset(rect, 0, (rect.size.height - self.font.lineHeight) / 2.0)
                    withAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : self.font}];
}

@end
