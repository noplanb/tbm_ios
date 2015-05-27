//
//  TBMRegisterForm.h
//  FormUsingCode
//
//  Created by Sani Elfishawy on 11/12/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMTextfield.h"

@class TBMRegisterViewController;

@protocol TBMRegisterFormDelegate <NSObject>
- (void) didClickSubmit;
- (void) didClickDebug;
@end

@interface TBMRegisterForm : NSObject <UITextFieldDelegate>
@property (nonatomic) TBMTextField *firstName;
@property (nonatomic) TBMTextField *lastName;
@property (nonatomic) TBMTextField *mobileNumber;
@property (nonatomic) TBMTextField *countryCode;
@property (nonatomic) UIActivityIndicatorView *spinner;

@property(nonatomic, weak) TBMRegisterViewController *controller;

- (instancetype)initWithView:(UIView *)view delegate:(id)delegate;

- (void)startWaitingForServer;
- (void)stopWaitingForServer;
@end
