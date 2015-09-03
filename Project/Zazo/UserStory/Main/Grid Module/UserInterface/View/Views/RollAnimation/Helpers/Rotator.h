//
// Created by Maksim Bazarov on 13/07/15.
// Copyright (c) 2015 Maksim Bazarov. All rights reserved.
//

@class POPDecayAnimation;
@class Grid;
@class GridHelper;

/**
Вращатель - вращать ячейки, на входе подается массив ячеек
_ответсвенность:_
- Рассчитать скорость, угасание и прочее
- Изменить нужным целам их позиции
- Запустить анимацию вращения
- Хранить признак анимация идет или нет (для отсечения срабатывания лонгтапа и тапа во время вращения)
*/
@interface Rotator : NSObject

@property(assign, nonatomic, readonly) CGFloat decelerationValue;
@property(assign, nonatomic, readonly) CGFloat velocityOfBounce;


- (instancetype)initWithAnimationCompletionBlock:(void(^)())completionBlock;

/**
* rotating cells. For each cell recalculates frame and setting that frame to cell
*  @param cells Array of cells to spin
*  @param angle angle from initial position
*  @grid grid GridHelper to use
*/
- (void)rotateCells:(NSArray *)cells onAngle:(CGFloat)angle withGrid:(GridHelper *)grid;

/**
* animate inertial spinning on view
* @param velocity Initial angle velocity, with which animation will start
* @param grid Grid to animate
*/
- (void)decayAnimationWithVelocity:(CGFloat)velocity onCarouselView:(Grid *)grid;

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
- (void)bounceAnimationToAngle:(CGFloat)angle onCarouselView:(Grid *)grid;

/**
* animate bounce on view with speed
* @param angle Angle to which bounce should be performed
* @param grid Grid to animate
* @param velocity Velocity to bounce
*/
- (void)bounceAnimationToAngle:(CGFloat)angle onCarouselView:(Grid *)grid withVelocity:(CGFloat)velocity;

/**
* Deciding whether it is necessary to stop decay animation and stopping it
* @param anim Animation that needs to be checked
* @param grid Grid that is animated
*/
- (void)stopDecayAnimationIfNeeded:(POPAnimation *)anim onGrid:(Grid *)grid;

/**
* stopping decay animation
* @param grid Grid on which animation should be stopped
*/
- (void)stopDecayAnimationOnGrid:(Grid *)grid;

/**
* stopping bounce animation
* @param grid Grid view on which animation should be stopped
*/
- (void)stopBounceAnimationOnGrid:(Grid *)grid;

/**
* Stop all animations on grid
* @param grid Grid to be un animated
*/
- (void)stopAnimationsOnGrid:(Grid *)grid;

/**
* check is decay animation active on carousel view
*/
- (BOOL)isDecayAnimationActiveOnGrid:(Grid *)grid;

/**
* check is bounce animation active on carousel view
*/
- (BOOL)isBounceAnimationActiveOnGrid:(Grid *)grid;

@end