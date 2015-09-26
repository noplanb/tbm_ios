//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class POPDecayAnimation;
@class ZZMovingGridView;
@class ZZGridHelper;

@interface ZZRotator : NSObject

@property(assign, nonatomic, readonly) CGFloat decelerationValue;
@property(assign, nonatomic, readonly) CGFloat velocityOfBounce;
@property (nonatomic, strong) POPDecayAnimation *decayAnimation;

- (instancetype)initWithAnimationCompletionBlock:(void(^)())completionBlock;

/**
* rotating cells. For each cell recalculates frame and setting that frame to cell
*  @param cells Array of cells to spin
*  @param angle angle from initial position
*  @grid grid GridHelper to use
*/
- (void)rotateCells:(NSArray *)cells onAngle:(CGFloat)angle withGrid:(ZZGridHelper *)grid;

/**
* animate inertial spinning on view
* @param velocity Initial angle velocity, with which animation will start
* @param grid Grid to animate
 */
- (void)decayAnimationWithVelocity:(CGFloat)velocity onCarouselView:(ZZMovingGridView *)grid;

/**
* decay animation name
*/
- (NSString *)decayAnimationName;

/**
* bounce animation name
*/
- (NSString *)bounceAnimationName;

/**
* animate bounce on view
* @param angle Angle to which bounce should be performed
* @param grid Grid to animate
*/
- (void)bounceAnimationToAngle:(CGFloat)angle onCarouselView:(ZZMovingGridView *)grid;

/**
* animate bounce on view with speed
* @param angle Angle to which bounce should be performed
* @param grid Grid to animate
* @param velocity Velocity to bounce
*/
- (void)bounceAnimationToAngle:(CGFloat)angle onCarouselView:(ZZMovingGridView *)grid withVelocity:(CGFloat)velocity;

/**
* Deciding whether it is necessary to stop decay animation and stopping it
* @param anim Animation that needs to be checked
* @param grid Grid that is animated
*/
- (void)stopDecayAnimationIfNeeded:(POPAnimation *)anim onGrid:(ZZMovingGridView *)grid;

/**
* stopping decay animation
* @param grid Grid on which animation should be stopped
*/
- (void)stopDecayAnimationOnGrid:(ZZMovingGridView *)grid;

/**
* stopping bounce animation
* @param grid Grid view on which animation should be stopped
*/
- (void)stopBounceAnimationOnGrid:(ZZMovingGridView *)grid;

/**
* Stop all animations on grid
* @param grid Grid to be un animated
*/
- (void)stopAnimationsOnGrid:(ZZMovingGridView *)grid;

/**
* check is decay animation active on carousel view
*/
- (BOOL)isDecayAnimationActiveOnGrid:(ZZMovingGridView *)grid;

/**
* check is bounce animation active on carousel view
*/
- (BOOL)isBounceAnimationActiveOnGrid:(ZZMovingGridView *)grid;

@end