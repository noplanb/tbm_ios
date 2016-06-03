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

- (void)blinkAnimatedTimes:(NSUInteger)times
{
    if (times == 0)
    {
        return;
    }
    
    [self _hideAnimated:^{
        [self _showAnimated:^{
            [self blinkAnimatedTimes:times - 1];
        }];
    }];
}

- (void)_hideAnimated:(ANCodeBlock)completion
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:0
                     animations:^{
                         self.alpha = 0;
                         
                     } completion:^(BOOL finished) {
                         completion();
                     }];
}

- (void)_showAnimated:(ANCodeBlock)completion
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:0
                     animations:^{
                         self.alpha = 1;
                         
                     } completion:^(BOOL finished) {
                         completion();
                     }];
}


@end