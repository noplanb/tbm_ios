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
    model.phones = [[model.phones.rac_sequence map:^id(ZZCommunicationDomainModel* communicationModel) {
        
        communicationModel.contact = [self clearPhone:communicationModel.contact];
        return ANIsEmpty(communicationModel.contact) ? nil : communicationModel;
        
    }] array];
    return model.phones;
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
