//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import <pop/POPDecayAnimation.h>
#import <pop/POPSpringAnimation.h>
#import "ZZRotator.h"
#import "ZZMovingGridView.h"
#import "ZZGridHelper.h"
#import "ZZGeometryHelper.h"


@interface ZZRotator ()

@property (nonatomic, copy) void (^completionBlock)();

/**
* returns frame for cell after applying offset
*/
- (CGRect)frameForCellAtIndex:(NSUInteger)index withOffset:(CGFloat)offset withGrid:(ZZGridHelper *)grid;

@end

@implementation ZZRotator

- (instancetype)initWithAnimationCompletionBlock:(void(^)())completionBlock
{
    self = [super init];
    if (self)
    {
        self.completionBlock = completionBlock;
    }
    
    return self;
}

- (void)rotateCells:(NSArray *)cells onAngle:(CGFloat)angle withGrid:(ZZGridHelper *)grid
{
    NSUInteger index = 0;
    for (UIView *cell in cells)
    {
        CGRect frame = [self frameForCellAtIndex:index withOffset:angle withGrid:grid];
        [cell setFrame:frame];
        index++;
    }
}

- (void)decayAnimationWithVelocity:(CGFloat)velocity onCarouselView:(ZZMovingGridView *)grid
{
    CGFloat angleVelocity = velocity;

    self.decayAnimation = [POPDecayAnimation animation];
    self.decayAnimation.property = [self animatableProperty];
    self.decayAnimation.velocity = @(angleVelocity);
    self.decayAnimation.deceleration = self.decelerationValue;
    self.decayAnimation.name = self.decayAnimationName;
    self.decayAnimation.delegate = grid;
    [grid pop_addAnimation:self.decayAnimation forKey:self.decayAnimationName];
}

- (void)bounceAnimationToAngle:(CGFloat)angle onCarouselView:(ZZMovingGridView *)grid
{
    [self bounceAnimationToAngle:angle onCarouselView:grid withVelocity:self.velocityOfBounce];
}

- (void)bounceAnimationToAngle:(CGFloat)angle onCarouselView:(ZZMovingGridView *)grid withVelocity:(CGFloat)velocity
{
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

- (void)stopDecayAnimationIfNeeded:(POPAnimation *)anim onGrid:(ZZMovingGridView *)grid
{
    if ([[anim class] isSubclassOfClass:[POPDecayAnimation class]])
    {
        CGFloat velocity = [((POPDecayAnimation *) anim).velocity floatValue];
        if (fabs(velocity) < grid.rotator.velocityOfBounce * 7.5f)
        {
            CGFloat angle = [((POPDecayAnimation *) anim).toValue floatValue];
            angle = [ZZGeometryHelper normalizedAngle:angle onGrid:grid];
            if (angle - grid.cellsOffset < M_PI_4) {
                angle = [ZZGeometryHelper nextFixedPositionFrom:angle withDirection:velocity > 0 ? ZZSpinDirectionClockwise : ZZSpinDirectionCounterClockwise];

                if (angle >= grid.cellsOffset -0.09f || angle <= grid.cellsOffset +0.09f)
                {
                    [self stopAnimationsOnGrid:grid];
                    [grid.rotator bounceAnimationToAngle:angle onCarouselView:grid withVelocity:velocity];
                }
            }
        }
    }
}

- (void)stopDecayAnimationOnGrid:(ZZMovingGridView *)grid
{
    [grid pop_removeAnimationForKey:self.decayAnimationName];
}

- (void)stopBounceAnimationOnGrid:(ZZMovingGridView *)grid
{
    [grid pop_removeAnimationForKey:self.bounceAnimationName];
}

- (void)stopAnimationsOnGrid:(ZZMovingGridView *) grid
{
    [self stopBounceAnimationOnGrid:grid];
    [self stopDecayAnimationOnGrid:grid];
}

- (BOOL)isDecayAnimationActiveOnGrid:(ZZMovingGridView *)grid
{
    return [grid pop_animationForKey:self.decayAnimationName] != nil;
}

- (BOOL)isBounceAnimationActiveOnGrid:(ZZMovingGridView *)grid
{
    return [grid pop_animationForKey:self.bounceAnimationName] != nil;
}


- (NSString *)decayAnimationName
{
    return @"CarouselViewDecay";
}

- (NSString *)bounceAnimationName
{
    return @"CarouselViewBounce";
}


- (CGFloat)decelerationValue
{
    return 0.998f;
}

- (CGFloat)velocityOfBounce
{
    return 0.2f;
}

#pragma mark - Private

- (CGRect)frameForCellAtIndex:(NSUInteger)index withOffset:(CGFloat)offset withGrid:(ZZGridHelper *)grid
{
    CGRect frame = CGRectZero;

    frame.size = [grid cellSize];
    CGPoint center = [grid centerOfCellWithIndex:index];
    if (index != 8)
    {
        [grid moveCellCenter:&center byAngle:offset];
    }

    frame.origin = CGPointMake(center.x - frame.size.width / 2, center.y - frame.size.height / 2);

    return frame;
}

- (POPAnimatableProperty *)animatableProperty
{
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