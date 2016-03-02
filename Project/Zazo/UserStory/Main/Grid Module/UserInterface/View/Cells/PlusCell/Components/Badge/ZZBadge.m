//
// Created by Rinat on 02/03/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZBadge.h"
#import "ZZGridUIConstants.h"

static CGFloat ZZBadgeAnimationDuration = 0.3f;

@interface ZZBadge ()

@property (nonatomic, weak, readonly) CAShapeLayer *shapeLayer;
@property (nonatomic, weak, readonly) CATextLayer *textLayer;

@end

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


        CATextLayer *textLayer = [CATextLayer layer];
        _textLayer = textLayer;
        [self.layer addSublayer:textLayer];
        
        textLayer.foregroundColor = [UIColor whiteColor].CGColor;
        textLayer.alignmentMode = kCAAlignmentCenter;
        textLayer.fontSize = 18;
        textLayer.font = CFBridgingRetain([UIFont zz_regularFontWithSize:18]);
        textLayer.contentsScale = [[UIScreen mainScreen] scale];
        textLayer.frame = CGRectMake(0, 1, kVideoCountLabelWidth, kVideoCountLabelWidth);
        
        self.hidden = YES;
        self.layer.delegate = self;
        self.count = NSUIntegerMax; // Skip initial count setting animation
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
}

- (void)animate
{
    BOOL delay = NO;
    if (self.hidden)
    {
        self.transform = CGAffineTransformMakeScale(0.01, 0.01);
        self.hidden = NO;
        delay = YES;
    }
    else
    {
        self.transform = CGAffineTransformMakeScale(0.75, 0.75);
    }

    ANCodeBlock animations = ^{
        self.transform = CGAffineTransformIdentity;
    };

    if (delay)
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ZZBadgeAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            animations();
        });
    }
    else
    {
        animations();
    }
}

- (void)setCount:(NSUInteger)count
{
    if (count > _count)
    {
        [self animate];
    }

    _count = count;

    {
        self.textLayer.string = [NSString stringWithFormat:@"%li", (long)count];
    }
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

        animation.mass = 1;
        animation.damping = 10;
        animation.stiffness = 100;
        animation.initialVelocity = 10;
        return animation;
    }

    return nil;
}

@end