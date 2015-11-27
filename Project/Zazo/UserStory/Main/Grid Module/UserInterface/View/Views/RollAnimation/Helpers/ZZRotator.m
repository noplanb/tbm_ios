//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import <pop/POPDecayAnimation.h>
#import <pop/POPSpringAnimation.h>
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

- (void)rotateCells:(NSArray*)cells onAngle:(CGFloat)angle withGrid:(ZZGridHelper*)grid
{
    [cells enumerateObjectsUsingBlock:^(UIView*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect frame = [self _frameForCellAtPosition:idx withOffset:angle withGrid:grid];
        obj.frame = frame;
    }];
}

- (void)decayAnimationWithVelocity:(CGFloat)velocity onCarouselView:(UIView*)grid
{
    self.decayAnimation = [POPDecayAnimation animation];
    
    self.decayAnimation.property = [self animatableProperty];
    self.decayAnimation.velocity = @(velocity);
    self.decayAnimation.deceleration = self.decelerationValue;
    
    self.decayAnimation.name = self.decayAnimationName;
    self.decayAnimation.delegate = self.delegate;
    
    [grid pop_addAnimation:self.decayAnimation forKey:self.decayAnimationName];
}

- (void)bounceAnimationToAngle:(CGFloat)angle onCarouselView:(UIView *)grid
{
    [self bounceAnimationToAngle:angle onCarouselView:grid withVelocity:self.velocityOfBounce];
}

- (void)bounceAnimationToAngle:(CGFloat)angle onCarouselView:(UIView *)grid withVelocity:(CGFloat)velocity
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

- (void)stopDecayAnimationIfNeeded:(POPAnimation*)anim onGrid:(ZZGridView*)grid
{
    if ([[anim class] isSubclassOfClass:[POPDecayAnimation class]])
    {
        
        CGFloat velocity = [((POPDecayAnimation *) anim).velocity floatValue];
        
        if (fabs(velocity) < self.velocityOfBounce * 7.5f)
        {
            CGFloat angle = [((POPDecayAnimation *) anim).toValue floatValue];
            angle = [ZZGeometryHelper normalizedAngle:angle withMaxCellOffset:[grid maxCellsOffset]];
            
            if ((angle - grid.calculatedCellsOffset) < M_PI_4)
            {      //TODO: add better determining direction
                ZZSpinDirection direction = velocity > 0 ? ZZSpinDirectionClockwise : ZZSpinDirectionCounterClockwise;
                angle = [ZZGeometryHelper nextFixedPositionFrom:angle withDirection:direction];
                
                if ((angle >= (grid.calculatedCellsOffset - 0.09f)) || (angle <= (grid.calculatedCellsOffset + 0.09f)))
                {
                    [self stopAnimationsOnGrid:grid];
                    [self bounceAnimationToAngle:angle onCarouselView:grid withVelocity:velocity];
                }
                
            }
        }
    }
}

- (void)stopAnimationsOnGrid:(UIView*) grid
{
    [grid pop_removeAnimationForKey:self.bounceAnimationName];
    [grid pop_removeAnimationForKey:self.decayAnimationName];
}

- (BOOL)isDecayAnimationActiveOnGrid:(UIView*)grid
{
    return ([grid pop_animationForKey:self.decayAnimationName] != nil);
}

- (BOOL)isBounceAnimationActiveOnGrid:(UIView*)grid
{
    return ([grid pop_animationForKey:self.bounceAnimationName] != nil);
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

- (CGRect)_frameForCellAtPosition:(ZZGridSpinPositionType)position withOffset:(CGFloat)offset withGrid:(ZZGridHelper *)grid
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
    POPAnimatableProperty *prop = [POPAnimatableProperty propertyWithName:@"spin.cellsOffset"
                                                              initializer:^(POPMutableAnimatableProperty *local_prop) {
                                                                  // read value
                                                                  local_prop.readBlock = ^(id obj, CGFloat values[]) {
                                                                      values[0] = [obj calculatedCellsOffset];
                                                                  };
                                                                  // write value
                                                                  local_prop.writeBlock = ^(ZZGridView* obj, const CGFloat values[]) {
                                                                      [obj setCalculatedCellsOffset:values[0]];
                                                                  };
                                                                  // dynamics threshold
                                                                  local_prop.threshold = 0.01;
                                                              }];

    return prop;
}

@end