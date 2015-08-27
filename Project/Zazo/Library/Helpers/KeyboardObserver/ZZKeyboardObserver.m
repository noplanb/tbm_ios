//
//  ZZKeyboardObserver.m
//  Zazo
//
//  Created by ANODA on 11/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZKeyboardObserver.h"

@interface ZZKeyboardObserver ()

@property (nonatomic, strong) id <ZZKeyboardObserverProtocol> delegate;

@end

@implementation ZZKeyboardObserver

- (instancetype)initWithDelegate:(id <ZZKeyboardObserverProtocol>)delegate {
    if (self = [super init]) {
        _delegate = delegate;
        [self configureNotification];
    }
    return self;
}

- (void)configureNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillChangeFrameNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_keyboardHidden)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
}

- (void)removeKeyboardNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    CGRect kKeyBoardFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardHeight = CGRectGetHeight(kKeyBoardFrame);
    NSNumber *animationDuration = info[UIKeyboardAnimationDurationUserInfoKey];
    [self.delegate keyboardChangeFrameWithAnimationDuration:animationDuration
                                         withKeyboardHeight:keyboardHeight
                                          withKeyboardFrame:kKeyBoardFrame];
}


- (void)_keyboardHidden;
{
    [self.delegate keyboardWillHide];
}


@end
