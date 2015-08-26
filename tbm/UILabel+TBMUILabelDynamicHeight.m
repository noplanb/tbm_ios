//
// Created by Maksim Bazarov on 26/08/15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "UILabel+TBMUILabelDynamicHeight.h"

@implementation UILabel (TBMUILabelDynamicHeight)

- (CGSize)sizeOfMultiLineLabel
{
    NSString *aLabelTextString = [self text];
    UIFont *aLabelFont = [self font];
    CGFloat aLabelSizeWidth = CGRectGetWidth(self.frame);
    NSDictionary *attributes = @{NSFontAttributeName : aLabelFont};
    CGRect labelRect = [aLabelTextString boundingRectWithSize:CGSizeMake(aLabelSizeWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
    return labelRect.size;
}
@end