//
//  ANDrawerNC.m
//
//  Created by Oksana Kovalchuk on 6/17/14.
//  Copyright (c) 2014 ANODA. All rights reserved.
//

#import "ANDrawerNC.h"
#import "MSSPopMasonry.h"
#import "FrameAccessor.h"
#import "ReactiveCocoa.h"

static CGFloat const kStatusBarHeight = 20;

@interface ANDrawerNC () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) MASConstraint* animatedConstraint;
@property (nonatomic, strong) MASConstraint* topConstraint;

@property (nonatomic, strong) UIView *drawerView;
@property (nonatomic, assign) CGFloat drawerWidth;
@property (nonatomic, assign) ANDrawerOpenDirection openDirection;
@property (nonatomic, assign) CGPoint startPoint;

@end

@implementation ANDrawerNC

+ (instancetype)drawerWithView:(UIView *)view
                         width:(CGFloat)width
                     direction:(ANDrawerOpenDirection)direction
{
    ANDrawerNC* instance = [ANDrawerNC new];
    [instance setupDrawerView:view width:width openDirection:direction];
    return instance;
}

#pragma mark - Setters/Getters

- (void)setupDrawerView:(UIView *)drawerView
                  width:(CGFloat)drawerWidth
          openDirection:(ANDrawerOpenDirection)direction
{
    self.drawerWidth = drawerWidth;
    self.openDirection = direction;
    self.drawerView = drawerView;
}

- (void)setDrawerView:(UIView *)drawerView
{
    if (_drawerView)
    {
        [_drawerView removeFromSuperview];
    }
    _drawerView = drawerView;
    _drawerView.alpha = 0;
    
    [self.view addSubview:_drawerView];
    [self.view bringSubviewToFront:self.navigationBar];
    
    [_drawerView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.bottom.equalTo(self.view);
        make.width.equalTo(@(self.drawerWidth));
        
        self.topConstraint = make.top.equalTo(self.view).offset([self _topOffsetFromPinType:self.topPin]);
        
        if (self.openDirection == ANDrawerOpenDirectionFromLeft)
        {
            self.animatedConstraint = make.right.equalTo(self.view.mas_left).offset(0);
        }
        else
        {
            self.animatedConstraint = make.left.equalTo(self.view.mas_right).offset(0);
        }
    }];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    _backgroundColor = backgroundColor;
    self.useBackground = YES;
    self.backgroundView.backgroundColor = backgroundColor;
}

- (CGFloat)_topOffsetFromPinType:(ANDrawerTopPin)pinType
{
    CGFloat topOffset = 0;
    if (pinType == ANDrawerTopPinStatusBar)
    {
        topOffset = kStatusBarHeight;
    }
    else if (pinType == ANDrawerTopPinNavigationBar)
    {
        CGFloat navigationBarHeight = self.navigationBarHidden ? 0 : self.navigationBar.height;
        topOffset = kStatusBarHeight + navigationBarHeight;
    }
    else if (pinType == ANDrawerTopPinCustomOffset)
    {
        topOffset = self.customTopPadding;
    }
    return topOffset;
}

- (void)setTopPin:(ANDrawerTopPin)topPin
{
    _topPin = topPin;
    if (self.topConstraint)
    {
        self.topConstraint.offset([self _topOffsetFromPinType:topPin]);
        [self.view layoutIfNeeded];
    }
}

- (void)setUseBackground:(BOOL)useBackground
{
    _useBackground = useBackground;
    if (_backgroundView && !useBackground)
    {
        [_backgroundView removeFromSuperview];
    }
    [self backgroundColor];
}

- (UIView *)backgroundView
{
    if (!_backgroundView && self.useBackground)
    {
        _backgroundView = [UIView new];
        _backgroundView.hidden = YES;
        [self.view insertSubview:_backgroundView belowSubview:self.drawerView];
        
        [_backgroundView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _backgroundView;
}

#pragma mark - Global Opening State

- (void)toggle
{
    [self updateStateToOpened:!self.isOpen];
}

- (void)updateStateToOpened:(BOOL)isOpen
{
    if (isOpen)
    {
        self.backgroundView.hidden = NO;
    }
    if (self.avoidKeyboard)
    {
        [self.view endEditing:YES]; // hack for keyboard;
    }
    
    CGFloat newOffset = isOpen ? [self _offsetForOpenState] : 0;
    
    POPSpringAnimation *leftSideAnimation = [POPSpringAnimation new];
    leftSideAnimation.toValue = @(newOffset);
    leftSideAnimation.property = [POPAnimatableProperty mas_offsetProperty];
    leftSideAnimation.springBounciness = 4;
    leftSideAnimation.completionBlock =   ^(POPAnimation *anim, BOOL finished) {
        if (finished)
        {
            self.isOpen = isOpen;
        }
    };
    
    [self.animatedConstraint pop_addAnimation:leftSideAnimation forKey:@"offset"];
    
    POPSpringAnimation *alphaAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
    alphaAnimation.toValue = isOpen ? @(1) : @(0); //HACK: for POP
    alphaAnimation.springBounciness = 4;
    alphaAnimation.completionBlock = ^(POPAnimation* animation, BOOL isCompleted) {
        if (!isOpen && isCompleted) self.backgroundView.hidden = YES;
    };
    [self.backgroundView pop_addAnimation:alphaAnimation forKey:@"alpha"];
    
    POPSpringAnimation *drawerAlphaAnimation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewAlpha];
    drawerAlphaAnimation.toValue = isOpen ? @(1) : @(0); //HACK: for POP
    drawerAlphaAnimation.springBounciness = 4;
    
    [self.drawerView pop_addAnimation:drawerAlphaAnimation forKey:@"drawerAlphaAnimation"];
    
    self.isOpen = isOpen;
}

#pragma mark - Private

- (CGFloat)_offsetForOpenState
{
    return (self.openDirection == ANDrawerOpenDirectionFromLeft) ? self.drawerWidth : -self.drawerWidth;
}

@end

