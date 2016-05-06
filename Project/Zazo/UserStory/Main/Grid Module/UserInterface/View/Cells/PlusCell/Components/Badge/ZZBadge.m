//
// Created by Rinat on 02/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZBadge.h"
#import "ZZGridUIConstants.h"

//static CGFloat ZZBadgeAnimationDuration = 1.0f;

@implementation ZZBadge

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        [self.layer addSublayer:shapeLayer];
        _shapeLayer = shapeLayer;

        shapeLayer.fillColor = [ZZColorTheme shared].gridCellBadgeColor.CGColor;
        shapeLayer.shadowRadius = 3.0f;
        shapeLayer.shadowOpacity = 0.4f;
        shapeLayer.shadowColor = [UIColor blackColor].CGColor;
        shapeLayer.shadowOffset = CGSizeMake(0, 3);
        shapeLayer.path = CGPathCreateWithEllipseInRect(CGRectMake(0, 0, kVideoCountLabelWidth, kVideoCountLabelWidth), nil);
    }

    return self;
}

- (void)animate
{
    [UIView animateWithDuration:0.2 animations:^{

        self.layer.transform = CATransform3DMakeScale(1.2, 1.2, 1);

    }                completion:^(BOOL finished) {

        [UIView animateWithDuration:0.3 animations:^{
            self.layer.transform = CATransform3DIdentity;
        }];

    }];

}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(kVideoCountLabelWidth, kVideoCountLabelWidth);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self animate];
}

@end