//
//  ZZPhoneHelper.h
//  Zazo
//
//  Created by ANODA on 9/9/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@class ZZContactDomainModel;

typedef NS_ENUM(NSInteger, ZZPhoneFormatType)
{
    ZZPhoneFormatTypeE164,
    ZZPhoneFormatTypeInternational,
    ZZPhoneFormatTypeNational,
    ZZPhoneFormatTypeRFC3966
};

@interface ZZPhoneHelper : NSObject

+ (NSArray*)validatePhonesFromContactModel:(ZZContactDomainModel*)model;
+ (NSString*)formatMobileNumberToE164AndServerFormat:(NSString*)number;
+ (NSString*)clearPhone:(NSString*)phone;

+ (NSString*)phone:(NSString *)phone withFormat:(ZZPhoneFormatType)format;
+ (BOOL)isNumberMatch:(NSString*)firstNumber secondNumber:(NSString*)secondNumber;

@end
