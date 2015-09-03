//
//  ZZErrorHandler.h
//  Zazo
//
//  Created by ANODA on 8/17/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZErrorHandler : NSObject

+ (void)showErrorAlertWithLocalizedTitle:(NSString*)title message:(NSString*)message;
+ (void)showAlertWithError:(NSError*)error;

@end
