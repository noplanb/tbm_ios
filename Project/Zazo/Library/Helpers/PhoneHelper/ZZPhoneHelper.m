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
#import "ZZCommunicationDomainModel.h"

@implementation ZZPhoneHelper

+ (NSArray *)validatePhonesFromContactModel:(ZZContactDomainModel *)model
{
    NSMutableArray *validNumbers = [NSMutableArray new];
    
    if (model.phones.count > 0)
    {
        [model.phones enumerateObjectsUsingBlock:^(ZZCommunicationDomainModel* communicationModel, NSUInteger idx, BOOL *stop) {
            communicationModel.contact = [self clearPhone:communicationModel.contact];
            [validNumbers addObject:communicationModel];
        }];
    }
    return validNumbers;
}

+ (NSString*)clearPhone:(NSString*)phone
{
    NSString* result = nil;
    if ([TBMPhoneUtils isValidPhone:phone])
    {
        NSString *formattedPhone = [TBMPhoneUtils phone:phone withFormat:NBEPhoneNumberFormatINTERNATIONAL];
        result = formattedPhone;
    }
    return result;
}

+ (NSString *)formatMobileNumberToE164AndServerFormat:(NSString *)number
{
    NSString *formatNumberToE164 = [TBMPhoneUtils phone:number withFormat:NBEPhoneNumberFormatE164];
    NSRange range = NSMakeRange(0,1);
    NSString *newNumber = [formatNumberToE164 stringByReplacingCharactersInRange:range withString:@"%2B"];
    
    return newNumber;
}

@end
