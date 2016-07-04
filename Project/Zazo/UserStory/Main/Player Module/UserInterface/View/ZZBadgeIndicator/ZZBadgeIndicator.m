//
//  ZZBadgeIndicator.m
//  Zazo
//
//  Created by Rinat on 17/05/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZBadgeIndicator.h"
#import "UIView+ZZAdditions.h"

@interface ZZBadgeIndicator ()

@property (weak, nonatomic) IBOutlet UILabel *badgeLabel;

@end

@implementation ZZBadgeIndicator

+ (ZZBadgeIndicator *)shared
{
    static ZZBadgeIndicator *shared;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[NSBundle mainBundle] loadNibNamed:@"ZZBadgeIndicator"
                                               owner:nil
                                             options:nil].firstObject;

        shared.backgroundColor = [ZZColorTheme shared].tintColor;
    });
    
    return shared;
}

+ (UIImage *)renderWithNumber:(NSInteger)number
                    fontColor:(UIColor *)fontColor
              backgroundColor:(UIColor *)backgroundColor
{
    ZZBadgeIndicator *shared = [self shared];
    
    shared.badgeLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)number];
    shared.backgroundColor = backgroundColor;
    shared.badgeLabel.textColor = fontColor;
    
    UIImage *badge = [[self shared] zz_renderToImage];

    return badge;
}

@end
