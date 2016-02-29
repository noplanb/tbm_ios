//
//  TBMVerficationAlertHandler.h
//  Zazo
//
//  Created by Sani Elfishawy on 5/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMAlertController.h"
@protocol TBMVerificationAlertDelegate <NSObject>

- (void)didEnterVerificationCode:(NSString *)code;
- (void)didTapCallMe;

@end


@interface TBMVerificationAlertHandler: NSObject

@property (nonatomic) NSString *phoneNumber;

- (instancetype)initWithPhoneNumber:(NSString *)phoneNumber delegate:(id <TBMVerificationAlertDelegate>)delegate;
- (void)presentAlert;
- (void)dismissAlertWithCompletion:(ANCodeBlock)completion;

@end

