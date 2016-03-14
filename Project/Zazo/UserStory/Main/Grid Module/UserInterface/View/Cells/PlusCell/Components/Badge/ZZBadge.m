//
// Created by Rinat on 02/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZBadge.h"
#import "ZZGridUIConstants.h"

static CGFloat ZZBadgeAnimationDuration = 1.0f;

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
    if (self.hidden)
    {
        self.layer.transform = CATransform3DMakeScale(0.01, 0.01, 1);
        self.hidden = NO;
    }
    else
    {
        self.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1);
    }

    self.layer.transform = CATransform3DIdentity;

}

- (nullable id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
    if (self.hidden)
    {
        return nil;
    }
    
    if ([event isEqualToString:@"transform"])
    {
        CASpringAnimation *animation = [CASpringAnimation animation];
        animation.fromValue = [NSValue valueWithCATransform3D:layer.transform];
        animation.duration = ZZBadgeAnimationDuration;

//        animation.duration = 10
        animation.mass = 1;
        animation.damping = 5;
        animation.stiffness = 100;
        animation.initialVelocity = 0;
        
        return animation;
    }

    return nil;
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