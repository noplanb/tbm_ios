//
//  ZZPhoneHelper.h
//  Zazo
//
//  Created by ANODA on 9/9/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@class ZZContactDomainModel;

@interface ZZPhoneHelper : NSObject

+ (NSArray *)validatePhonesFromContactModel:(ZZContactDomainModel *)model;
+ (NSString *)formatMobileNumberToE164AndServerFormat:(NSString *)number;

@end
