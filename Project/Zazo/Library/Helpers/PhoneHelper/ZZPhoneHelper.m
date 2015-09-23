//
//  ZZPhoneHelper.m
//  Zazo
//
//  Created by ANODA on 9/9/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZPhoneHelper.h"
#import "ZZContactDomainModel.h"
#import "TBMPhoneUtils.h"

@implementation ZZPhoneHelper

+ (NSArray *)validatePhonesFromContactModel:(ZZContactDomainModel *)model
{
    NSMutableArray *validNumbers = [NSMutableArray new];
    
    if (model.phones.count > 0)
    {
        [model.phones enumerateObjectsUsingBlock:^(NSString* phoneNumber, NSUInteger idx, BOOL *stop) {
            
            if ([TBMPhoneUtils isValidPhone:phoneNumber])
            {
                NSString *formattedPhone = [TBMPhoneUtils phone:phoneNumber withFormat:NBEPhoneNumberFormatINTERNATIONAL];
                [validNumbers addObject:formattedPhone];
            }
        }];
    }
    return validNumbers;
}

+ (NSString *)formatMobileNumberToE164AndServerFormat:(NSString *)number
{
    NSString *formatNumberToE164 = [TBMPhoneUtils phone:number withFormat:NBEPhoneNumberFormatE164];
    NSRange range = NSMakeRange(0,1);
    NSString *newNumber = [formatNumberToE164 stringByReplacingCharactersInRange:range withString:@"%2B"];
    
    return newNumber;
}

@end
