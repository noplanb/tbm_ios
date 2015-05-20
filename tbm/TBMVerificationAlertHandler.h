//
//  TBMVerficationAlertHandler.h
//  Zazo
//
//  Created by Sani Elfishawy on 5/15/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMAlertController.h"


@interface TBMVerificationAlertHandler: NSObject

@property (nonatomic) NSString *phoneNumber;
@property (nonatomic) UIButton *callMeButton;

- (instancetype) initWithPhoneNumber:(NSString *)phoneNumber;
- (void)presentAlert;

@end
