//
//  ZZAuthContentView.m
//  Zazo
//
//  Created by ANODA on 10/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAuthContentView.h"
#import "TPKeyboardAvoidingScrollView.h"

@implementation ZZAuthContentView

- (instancetype)init
{
    if (self = [super init])
    {
        [self scrollView];
        [self registrationView];
    }
    return self;
}

- (ZZAuthRegistrationView *)registrationView
{
    if (!_registrationView)
    {
        _registrationView = [ZZAuthRegistrationView new];
        [self.scrollView addSubview:_registrationView];
        [_registrationView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.scrollView);
            make.height.equalTo(@(CGRectGetHeight([UIScreen mainScreen].bounds)));
            make.centerX.equalTo(self.scrollView.mas_centerX);
        }];
    }
    
    return _registrationView;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView)
    {
        _scrollView = [TPKeyboardAvoidingScrollView new];
        _scrollView.scrollEnabled = NO;
        _scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeInteractive;
        [self addSubview:_scrollView];
        
        [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            self.registrationScrollBottomConstraint = make.bottom.equalTo(self).with.offset(0);
        }];
    }
    return _scrollView;
}


- (void)scrollToBottom
{
    CGPoint bottomOffset = CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height);
    [self.scrollView setContentOffset:bottomOffset animated:YES];
}

@end
