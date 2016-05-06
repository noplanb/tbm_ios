//
//  ZZPhoneHelper.m
//  Zazo
//
//  Created by ANODA on 9/9/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZPhoneHelper.h"
#import "ZZContactDomainModel.h"
#import "ZZStoredSettingsManager.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"

static NSString *const kDefaultRegion = @"US";

@implementation ZZPhoneHelper

+ (NSArray *)validatePhonesFromContactModel:(ZZContactDomainModel *)model
{
    model.phones = [[model.phones.rac_sequence map:^id(ZZCommunicationDomainModel *communicationModel) {

        communicationModel.contact = [self clearPhone:communicationModel.contact];
        return ANIsEmpty(communicationModel.contact) ? nil : communicationModel;

    }] array];
    return model.phones;
}

+ (NSString *)clearPhone:(NSString *)phone
{
    NSString *result = nil;
    if ([self _isValidPhone:phone])
    {
        NSString *formattedPhone = [self phone:phone withFormat:ZZPhoneFormatTypeInternational];
        result = formattedPhone;
    }
    return result;
}

+ (NSString *)formatMobileNumberToE164AndServerFormat:(NSString *)number
{
    NSString *formatNumberToE164 = [self phone:number withFormat:ZZPhoneFormatTypeE164];
    NSRange range = NSMakeRange(0, 1);
    NSString *newNumber = [formatNumberToE164 stringByReplacingCharactersInRange:range withString:@"%2B"];

    return newNumber;
}


+ (NSString *)phone:(NSString *)phone withFormat:(ZZPhoneFormatType)format
{
    if (phone == nil)
    {
        return nil;
    }

    NBPhoneNumberUtil *pu = [[NBPhoneNumberUtil alloc] init];
    NSError *err = nil;
    NSString *r;

    NSString *region = [self _phoneRegionFromNumber:phone]; //TODO: authenticated user have no mobile number
    if (ANIsEmpty(region))
    {
        region = [self _phoneRegionFromNumber:[self _savedMobileNumber]];
    }
    if (ANIsEmpty(region))
    {
        region = kDefaultRegion;
    }

    NBPhoneNumber *pn = [pu parse:phone defaultRegion:region error:&err];

    if (err != nil)
    {
        ZZLogError(@"%@", [NSObject an_safeString:[err localizedDescription]]);
        return nil;
    }
    r = [pu format:pn numberFormat:(NBEPhoneNumberFormat)format error:&err];
    if (err == nil)
    {
        return r;
    }
    else
    {
        ZZLogError(@"%@", [NSObject an_safeString:[err localizedDescription]]);
        return nil;
    }
}


#pragma mark - Private

+ (BOOL)_isValidPhone:(NSString *)phone
{
    NBPhoneNumberUtil *phoneUtil = [[NBPhoneNumberUtil alloc] init];

    NSString *region = [self _phoneRegionFromNumber:phone];
    if (ANIsEmpty(region))
    {
        region = [self _phoneRegionFromNumber:[self _savedMobileNumber]];
    }
    if (ANIsEmpty(region))
    {
        region = kDefaultRegion;
    }

    ZZLogDebug(@"User region: %@", region);

    NSError *error;
    NBPhoneNumber *phoneNumber = [phoneUtil parse:phone defaultRegion:region error:&error];
    if (error == nil)
    {
        if ([phoneUtil isValidNumber:phoneNumber])
        {
            ZZLogDebug(@"valid number");
            return YES;
        }
        else
        {
            ZZLogDebug(@"error was nil but invalid phone");
            return NO;
        }
    }
    else
    {
        ZZLogError(@"TBMPhoneUtils: isValidPhone: %@", [error localizedDescription]);
        return NO;
    }
}

+ (NSString *)_phoneRegionFromNumber:(NSString *)phone
{
    NBPhoneNumberUtil *phoneNumberUtil = [NBPhoneNumberUtil sharedInstance];

    NSError *err = nil;
    NBPhoneNumber *phoneNumber = [phoneNumberUtil parse:phone defaultRegion:kDefaultRegion error:&err];

    if (err != nil)
    {
        return kDefaultRegion;
    }
    return [phoneNumberUtil getRegionCodeForNumber:phoneNumber];
}

+ (NSString *)_savedMobileNumber
{
    return [ZZStoredSettingsManager shared].mobileNumber;
}

@end
