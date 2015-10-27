//
//  ZZPhoneHelper.m
//  Zazo
//
//  Created by ANODA on 9/9/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZPhoneHelper.h"
#import "ZZContactDomainModel.h"
#import "ZZCommunicationDomainModel.h"
#import "ZZUserDataProvider.h"
#import "ZZStoredSettingsManager.h"
#import "NBPhoneNumberUtil.h"
#import "NBPhoneNumber.h"

static NSString* const kDefaultRegion = @"US";

@implementation ZZPhoneHelper

+ (NSArray*)validatePhonesFromContactModel:(ZZContactDomainModel *)model
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
    if ([self _isValidPhone:phone])
    {
        NSString *formattedPhone = [self phone:phone withFormat:ZZPhoneFormatTypeInternational];
        result = formattedPhone;
    }
    return result;
}

+ (NSString*)formatMobileNumberToE164AndServerFormat:(NSString*)number
{
    NSString *formatNumberToE164 = [self phone:number withFormat:ZZPhoneFormatTypeE164];
    NSRange range = NSMakeRange(0,1);
    NSString *newNumber = [formatNumberToE164 stringByReplacingCharactersInRange:range withString:@"%2B"];
    
    return newNumber;
}


+ (NSString*)phone:(NSString *)phone withFormat:(ZZPhoneFormatType)format
{
    if (phone == nil)
    {
        return nil;
    }
    
    NBPhoneNumberUtil *pu = [[NBPhoneNumberUtil alloc] init];
    NSError *err = nil;
    NSString *r;
    
    NSString* region = [self _phoneRegionFromNumber:[self _savedMobileNumber]]; //TODO: authenticated user have no mobile number
   
    if (ANIsEmpty(region))
    {
        region = @"US";
    }
    
    NBPhoneNumber *pn = [pu parse:phone defaultRegion:region error:&err];
    
    if (err != nil)
    {
        OB_ERROR(@"TBMPhoneUtils: phoneWithFormat: %@", [err localizedDescription]);
        return nil;
    }
    r = [pu format:pn numberFormat:(NBEPhoneNumberFormat)format error:&err];
    if (err == nil)
    {
        return r;
    }
    else
    {
        OB_ERROR(@"TBMPhoneUtils: phoneWithFormat: %@", [err localizedDescription]);
        return nil;
    }
}


+ (BOOL)isNumberMatch:(NSString*)firstNumber secondNumber:(NSString*)secondNumber
{
    NBPhoneNumberUtil *pu = [[NBPhoneNumberUtil alloc] init];
    NSError *error;
    
    NBPhoneNumber *pn1 = [pu parse:firstNumber defaultRegion:[self _phoneRegion] error:&error];
    if (error != nil)
    {
        return NO;
    }
    
    NBPhoneNumber *pn2 = [pu parse:secondNumber defaultRegion:[self _phoneRegion] error:&error];
    if (error != nil)
    {
        return NO;
    }
    
    NBEMatchType match = [pu isNumberMatch:pn1 second:pn2 error:&error];
    if (error != nil)
    {
        return NO;
    }
    if (match == NBEMatchTypeEXACT_MATCH)
    {
        return YES;
    }
    return NO;
}


#pragma mark - Private

+ (BOOL)_isValidPhone:(NSString *)phone
{
    NBPhoneNumberUtil* phoneUtil = [[NBPhoneNumberUtil alloc] init];
    
    NSString* region = [self _phoneRegionFromNumber:[self _savedMobileNumber]];
    if (ANIsEmpty(region))
    {
        region = kDefaultRegion;
    }
    
    OB_DEBUG(@"User region: %@", region);
    
    NSError *error;
    NBPhoneNumber *phoneNumber = [phoneUtil parse:phone defaultRegion:region error:&error];
    if (error == nil)
    {
        if ([phoneUtil isValidNumber:phoneNumber])
        {
            OB_DEBUG(@"valid number");
            return true;
        }
        else
        {
            OB_DEBUG(@"error was nil but invalid phone");
            return false;
        }
    }
    else
    {
        OB_ERROR(@"TBMPhoneUtils: isValidPhone: %@", [error localizedDescription]);
        return false;
    }
}

+ (NSString*)_phoneRegionFromNumber:(NSString*)phone
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

+ (NSString*)_savedMobileNumber
{
    return [ZZStoredSettingsManager shared].mobileNumber;
}

+ (NSString*)_phoneRegion
{
    NBPhoneNumberUtil *pu = [NBPhoneNumberUtil sharedInstance];

    ZZUserDomainModel *user = [ZZUserDataProvider authenticatedUser]; //TODO: ????
    if (user == nil)
    {
        return @"US";
    }
    
    NSError *err = nil;
    NBPhoneNumber *pn = [pu parse:user.mobileNumber defaultRegion:@"US" error:&err];
    
    if (err != nil)
        return @"US";
    
    return [pu getRegionCodeForNumber:pn];
}

@end
