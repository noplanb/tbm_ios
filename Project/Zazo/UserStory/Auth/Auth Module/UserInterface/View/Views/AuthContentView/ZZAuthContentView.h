//
//  ZZAuthContentView.h
//  Zazo
//
//  Created by ANODA on 10/08/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZAuthRegistrationView.h"

@interface ZZAuthContentView : UIView

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) ZZAuthRegistrationView* registrationView;
@property (nonatomic, strong) MASConstraint* registrationScrollBottomConstraint;

- (void)scrollToBottom;

@end
