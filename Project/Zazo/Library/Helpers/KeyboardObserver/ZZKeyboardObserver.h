//
//  ZZKeyboardObserver.h
//  Zazo
//
//  Created by ANODA on 11/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@protocol ZZKeyboardObserverProtocol <NSObject>

- (void)keyboardChangeFrameWithAnimationDuration:(NSNumber *)animationDuration
                              withKeyboardHeight:(CGFloat)keyboardHeight
                               withKeyboardFrame:(CGRect)keyboarFrame;

- (void)keyboardWillHide;

@end

@interface ZZKeyboardObserver : NSObject

- (instancetype)initWithDelegate:(id <ZZKeyboardObserverProtocol>)delegate;
- (void)removeKeyboardNotification;

@end
