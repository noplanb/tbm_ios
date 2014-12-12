//
//  TBMLongPressTouchHandler.h
//  Touch
//
//  Created by Sani Elfishawy on 4/25/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TBMLongPressTouchHandlerCallback <NSObject>
- (void)LPTHClickWithTargetView:(UIView *)view;
- (void)LPTHStartLongPressWithTargetView:(UIView *)view;
- (void)LPTHEndLongPressWithTargetView:(UIView *)view;
- (void)LPTHCancelLongPressWithTargetView:(UIView *)view;
@end

@interface TBMLongPressTouchHandler : NSObject

@property NSArray *targetViews;

@property BOOL gestureCanceled;
@property BOOL isLongPress;
@property CGPoint beginPoint;
@property UIView *beginView;
@property id<TBMLongPressTouchHandlerCallback> instantiator;

- (id)initWithTargetViews:(NSArray *)targetViews instantiator:(NSObject*)instantiator;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;

@end
