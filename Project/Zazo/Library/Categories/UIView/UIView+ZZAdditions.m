//
// Created by Rinat on 05/04/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "UIView+ZZAdditions.h"


@implementation UIView (ZZAdditions)

- (UIImage *)zz_renderToImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, self.opaque, 0.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end