//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@import pop;

#import "ZZRotator.h"
#import "ZZGridHelper.h"
#import "ZZGeometryHelper.h"
#import "ZZGridView.h"

@interface ZZRotator ()

@property (nonatomic, copy) ANCodeBlock completionBlock;

@end

@implementation ZZRotator

- (instancetype)initWithAnimationCompletionBlock:(ANCodeBlock)completionBlock
{
    self = [super init];
    if (self)
    {
        self.completionBlock = [completionBlock copy];
    }
    return self;
}

- (void)rotateCells:(NSArray *)cells onAngle:(CGFloat)angle withGrid:(ZZGridHelper *)grid
{
    [cells enumerateObjectsUsingBlock:^(UIView *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        CGRect frame = [self _frameForCellAtPosition:idx
                                          withOffset:angle
                                            withGrid:grid];
        obj.frame = frame;
    }];

}

- (void)decayAnimationWithVelocity:(CGFloat)velocity
{
    self.decayAnimation = [POPDecayAnimation animation];

    self.decayAnimation.property = [self animatableProperty];
    self.decayAnimation.velocity = @(velocity);
    self.decayAnimation.deceleration = self.decelerationValue;

    self.decayAnimation.name = self.decayAnimationName;
    self.decayAnimation.delegate = self.delegate;

    [self.gridView pop_addAnimation:self.decayAnimation forKey:self.decayAnimationName];
}

- (void)bounceAnimationToAngle:(CGFloat)angle
{
    [self bounceAnimationToAngle:angle withVelocity:self.velocityOfBounce];
}

- (void)bounceAnimationToAngle:(CGFloat)angle withVelocity:(CGFloat)velocity
{
    POPSpringAnimation *springAnimation = [POPSpringAnimation animation];
    springAnimation.property = [self animatableProperty];
    springAnimation.velocity = @(velocity);
    springAnimation.toValue = @(angle);
    [self.gridView pop_addAnimation:springAnimation forKey:self.bounceAnimationName];
    springAnimation.completionBlock = ^(POPAnimation *anim, BOOL finished) {
        if (finished)
        {
            if (self.completionBlock)
            {
                self.completionBlock();
            }
        }
    };
}

- (void)jumpToNearest
{
    [self stopAnimations];
    
    CGFloat nearestAngle =
    [ZZGeometryHelper nextFixedPositionFrom:self.gridView.calculatedCellsOffset
                              withDirection:[self _currentDirection]];

//    CGFloat currentAngle = 
    
    self.gridView.calculatedCellsOffset = nearestAngle;
}

- (ZZSpinDirection)_currentDirection
{
    CGFloat velocity = [self.decayAnimation.velocity floatValue];
    
    if (velocity == 0)
    {
        return ZZSpinDirectionNone;
    }
    
    ZZSpinDirection direction = velocity > 0 ? ZZSpinDirectionClockwise : ZZSpinDirectionCounterClockwise;
    return direction;
}

- (void)stopDecayAnimationIfNeeded
{
    CGFloat velocity = [self.decayAnimation.velocity floatValue];

    if (fabs(velocity) >= self.velocityOfBounce * 7.5f)
    {
        return;
    }
    
    CGFloat angle = [self.decayAnimation.toValue floatValue];
    angle = [ZZGeometryHelper normalizedAngle:angle withMaxCellOffset:[self.gridView maxCellsOffset]];

    if ((angle - self.gridView.calculatedCellsOffset) >= M_PI_4)
    {
        return;
    }
    
    //TODO: add better determining direction
    velocity = [self.decayAnimation.velocity floatValue];
    
    angle = [self.decayAnimation.toValue floatValue];
    angle = [ZZGeometryHelper nextFixedPositionFrom:angle withDirection:[self _currentDirection]];
    
    if ((angle >= (self.gridView.calculatedCellsOffset - 0.09f)) || (angle <= (self.gridView.calculatedCellsOffset + 0.09f)))
    {
        NSLog(@"Bounce");
        [self stopAnimations];
        [self bounceAnimationToAngle:angle withVelocity:velocity];
    }
}

- (void)stopAnimations
{
    [self.gridView pop_removeAnimationForKey:self.bounceAnimationName];
    [self.gridView pop_removeAnimationForKey:self.decayAnimationName];
}

- (BOOL)isDecayAnimationActive
{
    return ([self.gridView pop_animationForKey:self.decayAnimationName] != nil);
}

- (BOOL)isBounceAnimationActive
{
    return ([self.gridView pop_animationForKey:self.bounceAnimationName] != nil);
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

- (CGRect)_frameForCellAtPosition:(ZZGridSpinPositionType)position
                       withOffset:(CGFloat)offset
                         withGrid:(ZZGridHelper *)grid
{
    CGRect frame = (CGRect){CGPointZero, [grid cellSize]};

    CGPoint center = [grid centerCellPointWithNormalIndex:position];

    if (position != ZZGridSpinPositionTypeCamera)
    {
        [grid moveCellCenter:&center byAngle:offset];
    }

    frame.origin = CGPointMake(center.x - frame.size.width / 2, center.y - frame.size.height / 2);
    return frame;
}

- (POPAnimatableProperty *)animatableProperty
{
    void (^initializer)(POPMutableAnimatableProperty *prop) = ^(POPMutableAnimatableProperty *property) {

        property.readBlock = ^(id obj, CGFloat values[]) {
            values[0] = [obj calculatedCellsOffset];
        };
        
        property.writeBlock = ^(ZZGridView *obj, const CGFloat values[]) {
            
            [obj setCalculatedCellsOffset:values[0]];
        };
        
        property.threshold = 0.01;
    };
    
    POPAnimatableProperty *prop =
    [POPAnimatableProperty propertyWithName:@"spin.cellsOffset"
                                initializer:initializer];

    return prop;
}

@end