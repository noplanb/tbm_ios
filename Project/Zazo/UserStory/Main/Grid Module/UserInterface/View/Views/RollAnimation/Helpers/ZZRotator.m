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
    CGFloat maximumVelocity = 18.0f;
    velocity = MIN(maximumVelocity, MAX(-maximumVelocity, velocity)); // we don't wan't to spin it too fast
    
    self.decayAnimation = [POPDecayAnimation animation];

    self.decayAnimation.property = [self animatableProperty];
    self.decayAnimation.velocity = @(velocity);
    self.decayAnimation.deceleration = self.decelerationValue;

    self.decayAnimation.name = self.decayAnimationName;
    self.decayAnimation.delegate = self.delegate;

    [self.gridView pop_addAnimation:self.decayAnimation forKey:self.decayAnimationName];
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
    
    CGFloat position = self.gridView.calculatedCellsOffset;
    
    CGFloat nearestClockwise =
    [ZZGeometryHelper nextFixedPositionFrom:position
                              withDirection:ZZSpinDirectionClockwise];
    CGFloat nearestCounterClockwise =
    [ZZGeometryHelper nextFixedPositionFrom:position
                              withDirection:ZZSpinDirectionCounterClockwise];

    CGFloat clockwiseDistantion = nearestClockwise - position;
    CGFloat counterDistantion = position - nearestCounterClockwise;
    
    CGFloat neededVelocity = clockwiseDistantion > counterDistantion ? -0.1 : 0.1;
    [self decayAnimationWithVelocity:neededVelocity];
    
}

- (ZZSpinDirection)_currentDirection
{
    CGFloat velocity = [self.decayAnimation.velocity floatValue];
    
    if (velocity == 0)
    {
        return ZZSpinDirectionNone;
    }
    
    ZZSpinDirection direction = velocity < 0 ? ZZSpinDirectionClockwise : ZZSpinDirectionCounterClockwise;
    return direction;
}

- (void)stopDecayAnimationIfNeeded
{
    CGFloat velocity = [self.decayAnimation.velocity floatValue];
    
    CGFloat toAngle = self.gridView.calculatedCellsOffset;
    CGFloat normalizedToAngle = [ZZGeometryHelper normalizedAngle:toAngle withMaxCellOffset:[self.gridView maxCellsOffset]];
    CGFloat nextFixedAngle = [ZZGeometryHelper nextFixedPositionFrom:normalizedToAngle withDirection:[self _currentDirection]];
    
    if ((normalizedToAngle - self.gridView.calculatedCellsOffset) >= M_PI_4) // to avoid jumping over position
    {
        return;
    }
    
    if (ABS(velocity) > 3.0f) // do not stop if it is spinning fast enough
    {
        return;
    }

    [self stopAnimations];
    [self bounceAnimationToAngle:nextFixedAngle withVelocity:velocity];
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
    return 0.997f;
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
//            NSLog(@"offset = %1.2f", values[0]);
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