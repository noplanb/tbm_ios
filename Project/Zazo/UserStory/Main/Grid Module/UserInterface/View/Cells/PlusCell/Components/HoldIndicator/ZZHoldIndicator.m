//
// Created by Rinat on 29/02/16.
// Copyright (c) 2016 No Plan B. All rights reserved.
//

#import "ZZHoldIndicator.h"

@interface ZZHoldIndicator ()

@property (strong, nonatomic, readonly) CAShapeLayer *shapeLayer;

@end

@implementation ZZHoldIndicator {

}

@dynamic shapeLayer;

- (instancetype)init {
    self = [super init];
    if (self) {
        [self makeCircle];
        self.layer.delegate = self;
    }

    return self;
}

- (void)makeCircle
{
    self.shapeLayer.fillColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.shapeLayer.path = [UIBezierPath bezierPathWithOvalInRect:self.bounds].CGPath;
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(50, 50);
}

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (CAShapeLayer *)shapeLayer
{
    return (id)self.layer;
}

- (id <CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
{
    if([event isEqualToString:@"opacity"])
    {
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.fromValue = @(self.layer.opacity);
        animation.duration = 0.2f;
        return animation;
    }
    return nil;
}

@end