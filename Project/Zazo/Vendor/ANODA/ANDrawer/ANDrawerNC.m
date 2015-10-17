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

static CGFloat const kDefaultDrawerVelocityTrigger = 350;
static CGFloat const kStatusBarHeight = 20;

@interface ANDrawerNC () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) BOOL isOpen;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) MASConstraint* animatedConstraint;
@property (nonatomic, strong) MASConstraint* topConstraint;

@property (nonatomic, strong) UIView *drawerView;
@property (nonatomic, assign) CGFloat drawerWidth;
@property (nonatomic, assign) ANDrawerOpenDirection openDirection;
@property (nonatomic, strong) UIPanGestureRecognizer* panGesure;
@property (nonatomic, assign) CGPoint startPoint;

@property (nonatomic, strong) NSArray* additionalPans;

@end

@implementation ANDrawerNC

+ (instancetype)drawerWithView:(UIView*)view width:(CGFloat)width direction:(ANDrawerOpenDirection)direction
{
    ANDrawerNC* instance = [ANDrawerNC new];
    [instance setupDrawerView:view width:width openDirection:direction];
    return instance;
}

#pragma mark - Setters/Getters

- (void)setupDrawerView:(UIView *)drawerView width:(CGFloat)drawerWidth openDirection:(ANDrawerOpenDirection)direction
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
    
    [_drawerView addGestureRecognizer:self.panGesure];
    
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
        
        [_backgroundView addGestureRecognizer:self.panGesure];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] init];
        [[tap.rac_gestureSignal deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
            [self updateStateToOpened:NO];
        }];
        [_backgroundView addGestureRecognizer:tap];
    }
    return _backgroundView;
}

- (UIPanGestureRecognizer *)panGesure
{
    if (!_panGesure)
    {
        _panGesure = [UIPanGestureRecognizer new];
        [self attachPanRecognizer:_panGesure];
    }
    return _panGesure;
}

- (void)attachPanRecognizer:(UIPanGestureRecognizer*)recognizer
{
    [recognizer addTarget:self action:@selector(_moveDrawer:)];
    recognizer.delegate = self;
    self.additionalPans = [self.additionalPans arrayByAddingObject:recognizer];
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

- (void)_moveDrawer:(UIPanGestureRecognizer *)recognizer
{
    [self.view endEditing:YES]; // hack for keyboard;
    CGPoint translation = [recognizer translationInView:self.view];
    CGPoint velocity = [recognizer velocityInView:self.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        self.startPoint = [recognizer locationInView:self.view];
        
        if (recognizer != self.panGesure)
        {
            if (velocity.x > kDefaultDrawerVelocityTrigger && !self.isOpen)
            {
                [self updateStateToOpened:YES];
            }
            else if (velocity.x < -kDefaultDrawerVelocityTrigger && self.isOpen)
            {
                [self updateStateToOpened:NO];
            }
        }
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGFloat startOffset = self.isOpen ? [self _offsetForOpenState] : 0;
        CGFloat newOffset = startOffset + translation.x;
        
        if (self.openDirection == ANDrawerOpenDirectionFromLeft)
        {
            newOffset = MAX(0, MIN([self _offsetForOpenState], newOffset));
        }
        else
        {
            newOffset = MIN(0, MAX([self _offsetForOpenState], newOffset));
        }
        
        self.animatedConstraint.offset(newOffset);
        self.backgroundView.hidden = NO;
        
        CGFloat alpha = 0;
        if (self.openDirection == ANDrawerOpenDirectionFromLeft)
        {
            alpha =  1 / self.drawerWidth * newOffset + 0.5;
        }
        else
        {
            alpha = 1 - (1 / self.drawerWidth * newOffset + 0.5);
        }
        self.backgroundView.alpha = alpha;
        self.drawerView.alpha = alpha;
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded ||
             recognizer.state == UIGestureRecognizerStateCancelled)
    {
        CGFloat padding = 0;
        if (self.openDirection == ANDrawerOpenDirectionFromRight)
        {
            padding = self.view.center.x;
        }
        BOOL newState = ((self.drawerView.center.x - padding) < ((self.drawerWidth - 10) / 2));
        if (newState == NO)
        {
            [self updateStateToOpened:newState];
        }
        else if (recognizer == self.panGesure)
        {
            [self updateStateToOpened:newState];
        }
        else
        {
            [self updateStateToOpened:YES];
        }
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)panGestureRecognizer
{
    if (panGestureRecognizer != self.panGesure)
    {
        CGPoint point = [panGestureRecognizer locationInView:panGestureRecognizer.view];
        BOOL isInBounds = point.x > (self.view.bounds.size.width - 40); //TODO: this only for rifht side
        return isInBounds;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([self.additionalPans containsObject:gestureRecognizer])
    {
        CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
        BOOL isInBounds = point.x > (self.view.bounds.size.width - 40); //TODO: this only for rifht side
        return isInBounds;
    }
    return NO;
}


#pragma mark - Lazy Load

- (NSArray *)additionalPans
{
    if (!_additionalPans)
    {
        _additionalPans = [NSArray new];
    }
    return _additionalPans;
}

@end

