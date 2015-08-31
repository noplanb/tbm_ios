//
// Created by Maksim Bazarov on 13/07/15.
// Copyright (c) 2015 Maksim Bazarov. All rights reserved.
//

#import <pop/POPDecayAnimation.h>
#import <pop/POPSpringAnimation.h>
#import "Rotator.h"
#import "Grid.h"
#import "GridHelper.h"
#import "Geometry.h"


@interface Rotator ()

@property (nonatomic, copy) void (^completionBlock)();

/**
* returns frame for cell after applying offset
*/
- (CGRect)frameForCellAtIndex:(NSUInteger)index withOffset:(CGFloat)offset withGrid:(GridHelper *)grid;
@end

@implementation Rotator

- (instancetype)initWithAnimationCompletionBlock:(void(^)())completionBlock
{
    self = [super init];
    if (self)
    {
        self.completionBlock = completionBlock;
    }
    
    return self;
}

- (void)rotateCells:(NSArray *)cells onAngle:(CGFloat)angle withGrid:(GridHelper *)grid {
    NSUInteger index = 0;
    for (UIView *cell in cells) {
        CGRect frame = [self frameForCellAtIndex:index withOffset:angle withGrid:grid];
        [cell setFrame:frame];
        index++;
    }
}

- (void)decayAnimationWithVelocity:(CGFloat)velocity onCarouselView:(Grid *)grid {
    CGFloat angleVelocity = velocity;

    POPDecayAnimation *decayAnimation = [POPDecayAnimation animation];
    decayAnimation.property = [self animatableProperty];
    decayAnimation.velocity = @(angleVelocity);
    decayAnimation.deceleration = self.decelerationValue;
    decayAnimation.name = self.decayAnimationName;
    decayAnimation.delegate = grid;
    [grid pop_addAnimation:decayAnimation forKey:self.decayAnimationName];
}

- (void)bounceAnimationToAngle:(CGFloat)angle onCarouselView:(Grid *)grid {
    [self bounceAnimationToAngle:angle onCarouselView:grid withVelocity:self.velocityOfBounce];
}

- (void)bounceAnimationToAngle:(CGFloat)angle onCarouselView:(Grid *)grid withVelocity:(CGFloat)velocity{
    POPSpringAnimation *springAnimation = [POPSpringAnimation animation];
    springAnimation.property = [self animatableProperty];
    springAnimation.velocity = @(velocity);
    springAnimation.toValue = @(angle);
    [grid pop_addAnimation:springAnimation forKey:self.bounceAnimationName];
    springAnimation.completionBlock =  ^(POPAnimation *anim, BOOL finished) {
        if (finished)
        {
            if (self.completionBlock)
            {
                self.completionBlock();
            }
        }
    };
    
}

- (void)stopDecayAnimationIfNeeded:(POPAnimation *)anim onGrid:(Grid *)grid {
    if ([[anim class] isSubclassOfClass:[POPDecayAnimation class]]) {
        CGFloat velocity = [((POPDecayAnimation *) anim).velocity floatValue];
        if (fabsf(velocity) < grid.rotator.velocityOfBounce * 7.5f) {
            CGFloat angle = [((POPDecayAnimation *) anim).toValue floatValue];
            angle = [Geometry normalizedAngle:angle onGrid:grid];
            if (angle - grid.cellsOffset < M_PI_4) {
                angle = [Geometry nextFixedPositionFrom:angle withDirection:velocity > 0 ? SpinClockwise : SpinCounterClockwise];

                if (angle >= grid.cellsOffset -0.09f || angle <= grid.cellsOffset +0.09f) {
                    [self stopAnimationsOnGrid:grid];
                    [grid.rotator bounceAnimationToAngle:angle onCarouselView:grid withVelocity:velocity];
                }
            }
        }
    }
}

- (void)stopDecayAnimationOnGrid:(Grid *)grid {
    [grid pop_removeAnimationForKey:self.decayAnimationName];
}

- (void)stopBounceAnimationOnGrid:(Grid *)grid {
    [grid pop_removeAnimationForKey:self.bounceAnimationName];
}

- (void)stopAnimationsOnGrid:(Grid *) grid {
    [self stopBounceAnimationOnGrid:grid];
    [self stopDecayAnimationOnGrid:grid];
}

- (BOOL)isDecayAnimationActiveOnGrid:(Grid *)grid {
    return [grid pop_animationForKey:self.decayAnimationName] != nil;
}

- (BOOL)isBounceAnimationActiveOnGrid:(Grid *)grid {
    return [grid pop_animationForKey:self.bounceAnimationName] != nil;
}


- (NSString *)decayAnimationName {
    return @"CarouselViewDecay";
}

- (NSString *)bounceAnimationName {
    return @"CarouselViewBounce";
}


- (CGFloat)decelerationValue {
    return 0.998f;
}

- (CGFloat)velocityOfBounce {
    return 0.2f;
}

#pragma mark - Private

- (CGRect)frameForCellAtIndex:(NSUInteger)index withOffset:(CGFloat)offset withGrid:(GridHelper *)grid {
    CGRect frame = CGRectZero;

    frame.size = [grid cellSize];
    CGPoint center = [grid centerOfCellWithIndex:index];
    if (index != 8) {
        [grid moveCellCenter:&center byAngle:offset];
    }

    frame.origin = CGPointMake(center.x - frame.size.width / 2, center.y - frame.size.height / 2);

    return frame;
}

- (POPAnimatableProperty *)animatableProperty {
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"com.artolkov.carousel.cellsOffset"
                                                              initializer:^(POPMutableAnimatableProperty *local_prop) {
                                                                  // read value
                                                                  local_prop.readBlock = ^(id obj, CGFloat values[]) {
                                                                      values[0] = [obj cellsOffset];
                                                                  };
                                                                  // write value
                                                                  local_prop.writeBlock = ^(id obj, const CGFloat values[]) {
                                                                      [obj setCellsOffset:values[0]];
                                                                  };
                                                                  // dynamics threshold
                                                                  local_prop.threshold = 0.01;
                                                              }];

    return prop;
}

@end