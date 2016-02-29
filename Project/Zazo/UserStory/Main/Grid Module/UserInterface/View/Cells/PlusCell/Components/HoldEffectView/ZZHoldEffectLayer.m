//
//  ZZGridStateViewLayer.m
//  Animation
//
//  Created by Rinat on 26/02/16.
//  Copyright © 2016 No plan B. All rights reserved.
//

#import "ZZHoldEffectLayer.h"
#import <UIKit/UIKit.h>
@import QuartzCore;


static CGFloat ZZAnimationDuration = 0.35;

@interface ZZHoldEffectLayer ()

@property (nonatomic, assign) BOOL isAnimating;

@end

@implementation ZZHoldEffectLayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.anchorPoint = CGPointMake(0.5, 0.5);
        self.masksToBounds = YES;
        self.path = [UIBezierPath bezierPathWithOvalInRect:[self _stateA]].CGPath;

    }
    return self;
}

- (void)animate:(ZZCellEffectType)animationType
{
    if (self.isAnimating)
    {
        return;
    }
    
    self.isAnimating = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(ZZAnimationDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isAnimating = NO;
    });

    switch (animationType) {
        case ZZCellEffectTypeWaveIn:
            
            // from:
            self.fillColor = [UIColor colorWithWhite:0 alpha:0].CGColor;
            self.path = [UIBezierPath bezierPathWithOvalInRect:[self _stateB]].CGPath;
            // to:
            self.path = [UIBezierPath bezierPathWithOvalInRect:[self _stateA]].CGPath;
            self.fillColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
            

            break;
            
        case ZZCellEffectTypeWaveOut:
            
            // from:
            self.path = [UIBezierPath bezierPathWithOvalInRect:[self _stateA]].CGPath;
            self.fillColor = [UIColor colorWithWhite:1 alpha:0.5].CGColor;
            // to:
            self.path = [UIBezierPath bezierPathWithOvalInRect:[self _stateB]].CGPath;
            self.fillColor = [UIColor colorWithWhite:0 alpha:0].CGColor;
            
            break;
            
        default:
            break;
    }
}

- (id<CAAction>)actionForKey:(NSString *)key
{
    if ([key isEqualToString:@"path"])
    {
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.fromValue = (id)self.path;
        animation.duration = ZZAnimationDuration;
        animation.removedOnCompletion = YES;
        return animation;
    }
    else if ([key isEqualToString:@"fillColor"])
    {
        CABasicAnimation *animation = [CABasicAnimation animation];
        animation.fromValue = (id)self.fillColor;
        animation.duration = ZZAnimationDuration;
        animation.removedOnCompletion = YES;
        return animation;
    }
    return [super actionForKey:key];
}


- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
}

- (CGSize)_sizeA
{
    return CGSizeMake(1, 1);
}

- (CGSize)_sizeB
{
    return CGSizeMake(300, 300);
}

- (CGRect)_stateA
{
    CGSize frameSize = self.bounds.size;
    CGSize stateSize = [self _sizeA];
    
    return CGRectMake(frameSize.width/2 - stateSize.width/2, frameSize.height/2 - stateSize.height/2, stateSize.width, stateSize.height);
}

- (CGRect)_stateB
{
    CGSize frameSize = self.bounds.size;
    CGSize stateSize = [self _sizeB];
    
    return CGRectMake(frameSize.width/2 - stateSize.width/2, frameSize.height/2 - stateSize.height/2, stateSize.width, stateSize.height);
}



@end
