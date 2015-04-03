//
//  TBMLongPressTouchHandler.m
//  Touch
//
//  Created by Sani Elfishawy on 4/25/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import "TBMLongPressTouchHandler.h"
#import "TBMGeometryUtils.h"
#import "TBMViewUtils.h"

@implementation TBMLongPressTouchHandler

- (id)initWithTargetViews:(NSArray *)targetViews instantiator:(id)instantiator{
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
    // DebugLog(@"touches began");
    // Cancel any gesture that becomes multitouch.
    if ([[event allTouches] count] > 1){
        [self cancelGesture:@"Two finger touch"];
        return;
    }
    _gestureCanceled = NO;
    [self startLongPressTimer];
    UITouch *touch = [touches anyObject];
    _beginPoint = [touch locationInView:nil];
    _beginView = [touch view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    // DebugLog(@"touchesMoved");
    if (_gestureCanceled){
        return;
    }
    if ([[event allTouches] count] > 1){
        [self cancelGesture:@"Two finger touch"];
        return;
    }
    
    UITouch *touch = [touches anyObject];
    if ([self moveTouchIsLongSwipe:touch]){
        [self cancelGesture:@"Dragged finger away"];
    }
}

- (BOOL)moveTouchIsLongSwipe:(UITouch *)touch{
    CGPoint p = [touch locationInView:nil];
    float d = [TBMGeometryUtils distanceFromPoint:_beginPoint toPoint:p];
    return d > 80;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    // DebugLog(@"touchesEnded");
    if (_gestureCanceled) {
        //        DebugLog(@"touchesEnded: in canceled state");
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
    DebugLog(@"touchesCancelled");
    [self cancelGesture:nil];
}


- (void)cancelGesture:(NSString *)reason{
    DebugLog(@"cancelGesture");
    _gestureCanceled = YES;
    [self cancelLongPressTimer];
    if (_isLongPress) {
        _isLongPress = NO;
        [self cancelLongPress:reason];
    }
}

- (void)startLongPressTimer{
    //    DebugLog(@"startLongPressTimer");
    [self performSelector:@selector(startLongPress) withObject:nil afterDelay: (NSTimeInterval)0.2];
}

- (void)cancelLongPressTimer{
    //    DebugLog(@"cancelLongPressTimer");
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(startLongPress) object:nil];
}

- (UIView *)targetView
{
    for (UIView *targetCandidate in _targetViews) {
        if (targetCandidate == _beginView ||
            [TBMViewUtils isChildViewASubview:_beginView ofParentView:(UIView *)targetCandidate]) {
            return targetCandidate;
        }
        // Check to see if any parent of the _begin view is superimposed with the same frame on the target candidate and consider this
        // a match. This was included to catch the case where user clicks on movie player that is on top of the grid element.
        UIView *parent = _beginView;
        while (parent != nil) {
            if (CGRectEqualToRect(targetCandidate.frame, parent.frame)){
                return targetCandidate;
            }
            parent = parent.superview;
        }
    }
    return nil;
}

- (void)click{
    UIView *targetView = [self targetView];
    if (targetView){
        //    DebugLog(@"click %ld", (long)[self targetView].tag);
        [_instantiator LPTHClickWithTargetView:[self targetView]];
    }
}

- (void)startLongPress{
    UIView *targetView = [self targetView];
    if (targetView){
        //    DebugLog(@"startLongPress %ld", (long)[self targetView].tag);
        _isLongPress = YES;
        [_instantiator LPTHStartLongPressWithTargetView:[self targetView]];
    }
}

- (void)endLongPress{
    UIView *targetView = [self targetView];
    if (targetView){
        //    DebugLog(@"endLongPress %ld", (long)[self targetView].tag);
        _isLongPress = NO;
        [_instantiator LPTHEndLongPressWithTargetView:[self targetView]];
    }
}

- (void)cancelLongPress:(NSString *)reason{
    UIView *targetView = [self targetView];
    if (targetView){
        //    DebugLog(@"cancelLongPress %ld", (long)[self targetView].tag);
        [_instantiator LPTHCancelLongPressWithTargetView:[self targetView] reason:reason];
    }
}


@end
