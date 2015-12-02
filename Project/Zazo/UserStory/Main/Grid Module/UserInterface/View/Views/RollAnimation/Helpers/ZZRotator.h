//  Zazo
//
//  Created by Oksana Kovalchuk on 1/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@class POPDecayAnimation;
@class UIView;
@class ZZGridHelper;
@class ZZGridView;

@protocol ZZRotatorDelegate <NSObject>

@end

@interface ZZRotator : NSObject

@property(assign, nonatomic, readonly) CGFloat decelerationValue;
@property(assign, nonatomic, readonly) CGFloat velocityOfBounce;
@property (nonatomic, strong) POPDecayAnimation *decayAnimation;
@property (nonatomic, strong) ZZGridView* gridView;

@property (nonatomic, weak) id<ZZRotatorDelegate> delegate;

- (instancetype)initWithAnimationCompletionBlock:(ANCodeBlock)completionBlock;

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
* @param grid Grid to animatze
 */
- (void)decayAnimationWithVelocity:(CGFloat)velocity onCarouselView:(UIView *)grid;

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
- (void)bounceAnimationToAngle:(CGFloat)angle onCarouselView:(UIView *)grid;

/**
* animate bounce on view with speed
* @param angle Angle to which bounce should be performed
* @param grid Grid to animate
* @param velocity Velocity to bounce
*/
- (void)bounceAnimationToAngle:(CGFloat)angle onCarouselView:(UIView *)grid withVelocity:(CGFloat)velocity;

/**
* Deciding whether it is necessary to stop decay animation and stopping it
* @param anim Animation that needs to be checked
* @param grid Grid that is animated
*/
- (void)stopDecayAnimationIfNeeded:(POPAnimation *)anim onGrid:(ZZGridView*)grid;

/**
* Stop all animations on grid
* @param grid Grid to be un animated
*/
- (void)stopAnimationsOnGrid:(UIView *)grid;

/**
* check is decay animation active on carousel view
*/
- (BOOL)isDecayAnimationActiveOnGrid:(UIView *)grid;

/**
* check is bounce animation active on carousel view
*/
- (BOOL)isBounceAnimationActiveOnGrid:(UIView *)grid;

@end