//
//  TBMLongPressTouchHandler.m
//  Touch
//
//  Created by Sani Elfishawy on 4/25/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMLongPressTouchHandlerCallback.h"
#import "TBMLongPressTouchHandler.h"
#import "TBMGeometryUtils.h"
#import "TBMViewUtils.h"

@implementation TBMLongPressTouchHandler

- (id)initWithTargetViews:(NSArray *)targetViews instantiator:(id)instantiator
{
    self = [super init];
    if (self){
        _targetViews = targetViews;
        _isLongPress = NO;
        _gestureCanceled = NO;
        _instantiator = instantiator;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    // Cancel any gesture that becomes multitouch.
    if ([[event allTouches] count] > 1){
        [self cancelGesture];
        return;
    }
    _gestureCanceled = NO;
    [self startLongPressTimer];
    UITouch *touch = [touches anyObject];
    _beginPoint = [touch locationInView:nil];
    _beginView = [touch view];
}



- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //    NSLog(@"touchesMoved");
    if (_gestureCanceled){
        return;
    }
    if ([[event allTouches] count] > 1){
        [self cancelGesture];
        return;
    }
    
    UITouch *touch = [touches anyObject];
    if ([self moveTouchIsLongSwipe:touch]){
        [self cancelGesture];
    }
}

- (BOOL)moveTouchIsLongSwipe:(UITouch *)touch{
    CGPoint p = [touch locationInView:nil];
    float d = [TBMGeometryUtils distanceFromPoint:_beginPoint toPoint:p];
    return d > 80;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //    NSLog(@"touchesEnded");
    if (_gestureCanceled) {
        //        NSLog(@"touchesEnded: in canceled state");
        return;
    }
    if (_isLongPress) {
        [self endLongPress];
    } else {
        [self click];
    }
    [self cancelLongPressTimer];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    //    NSLog(@"touchesCancelled");
    [self cancelGesture];
}


- (void)cancelGesture{
    //    NSLog(@"cancelGesture");
    _gestureCanceled = YES;
    [self cancelLongPressTimer];
    if (_isLongPress) {
        _isLongPress = NO;
        [self cancelLongPress];
    }
}

- (void)startLongPressTimer{
    //    NSLog(@"startLongPressTimer");
    [self performSelector:@selector(startLongPress) withObject:nil afterDelay: (NSTimeInterval)0.2];
}

- (void)cancelLongPressTimer{
    //    NSLog(@"cancelLongPressTimer");
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(startLongPress) object:nil];
}

- (UIView *)targetView
{
    for (UIView *targetCandidate in _targetViews) {
        if (targetCandidate == _beginView || [TBMViewUtils isChildViewASubview:_beginView ofParentView:(UIView *)targetCandidate]) {
            return targetCandidate;
        }
    }
    return nil;
}

- (void)click{
    UIView *targetView = [self targetView];
    if (targetView){
        //    NSLog(@"click %ld", (long)[self targetView].tag);
        [_instantiator LPTHClickWithTargetView:[self targetView]];
    }
}

- (void)startLongPress{
    UIView *targetView = [self targetView];
    if (targetView){
        //    NSLog(@"startLongPress %ld", (long)[self targetView].tag);
        _isLongPress = YES;
        [_instantiator LPTHStartLongPressWithTargetView:[self targetView]];
    }
}

- (void)endLongPress{
    UIView *targetView = [self targetView];
    if (targetView){
        //    NSLog(@"endLongPress %ld", (long)[self targetView].tag);
        _isLongPress = NO;
        [_instantiator LPTHEndLongPressWithTargetView:[self targetView]];
    }
}

- (void)cancelLongPress{
    UIView *targetView = [self targetView];
    if (targetView){
        //    NSLog(@"cancelLongPress %ld", (long)[self targetView].tag);
        [_instantiator LPTHCancelLongPressWithTargetView:[self targetView]];
    }
}


@end
