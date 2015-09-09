//
//  TBMPhoneUtils.m
//  tbm
//
//  Created by Sani Elfishawy on 11/4/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//
#import "TBMUser.h"
#import "TBMPhoneUtils.h"
#import "OBLogger.h"
#import "ZZUserDataProvider.h"
#import "ZZUserDomainModel.h"

@implementation TBMPhoneUtils

+ (NSString *)phone:(NSString *)phone withFormat:(int)format{
    if (phone == nil)
        return nil;
    
    NBPhoneNumberUtil *pu = [[NBPhoneNumberUtil alloc] init];
    NSError *err = nil;
    NSString *r;
    
    NSString* region = [self phoneRegionFromNumber:@"+380930880008"]; //TODO: authenticated user have no mobile number
    
    NBPhoneNumber *pn = [pu parse:phone defaultRegion:region error:&err];
    
    if (err != nil){
        OB_ERROR(@"TBMPhoneUtils: phoneWithFormat: %@", [err localizedDescription]);
        return nil;
    }

    r = [pu format:pn numberFormat:format error:&err];
    if (err == nil){
        return r;
    } else {
        OB_ERROR(@"TBMPhoneUtils: phoneWithFormat: %@", [err localizedDescription]);
        return nil;
    }
}


+ (BOOL) isValidPhone:(NSString *)phone
{
    NBPhoneNumberUtil* phoneUtil = [[NBPhoneNumberUtil alloc] init];
    
    ZZUserDomainModel* authenticatedUser = [ZZUserDataProvider authenticatedUser];
    
    NSString* region = [self phoneRegionFromNumber:@"+380930880008"]; //TODO: authenticated user have no mobile number
    
    OB_DEBUG(@"User region: %@", region);
    
    NSError *error;
    NBPhoneNumber *phoneNumber = [phoneUtil parse:phone defaultRegion:region error:&error];
    if (error == nil)
    {
        if ([phoneUtil isValidNumber:phoneNumber])
        {
            OB_DEBUG(@"valid number");
            return true;
        } else {
            OB_DEBUG(@"error was nil but invalid phone");
            return false;
        }
    } else {
        OB_ERROR(@"TBMPhoneUtils: isValidPhone: %@", [error localizedDescription]);
        return false;
    }
}

+ (NSString *)phoneRegionFromNumber:(NSString*)phone
{
    NBPhoneNumberUtil *phoneNumberUtil = [NBPhoneNumberUtil sharedInstance];
    
    NSError *err = nil;
    NBPhoneNumber *phoneNumber = [phoneNumberUtil parse:phone defaultRegion:@"US" error:&err];
    
    if (err != nil)
    {
        return @"US";
    }
    
    return [phoneNumberUtil getRegionCodeForNumber:phoneNumber];
}

+ (BOOL) isNumberMatch:(NSString *)n1 secondNumber:(NSString *)n2{
    NBPhoneNumberUtil *pu = [[NBPhoneNumberUtil alloc] init];
    
    NSError *error;
    
    NBPhoneNumber *pn1 = [pu parse:n1 defaultRegion:[TBMUser phoneRegion] error:&error];
    if (error != nil)
        return NO;
    
    NBPhoneNumber *pn2 = [pu parse:n2 defaultRegion:[TBMUser phoneRegion] error:&error];
    if (error != nil)
        return NO;
    
    NBEMatchType match = [pu isNumberMatch:pn1 second:pn2 error:&error];
    if (error != nil)
        return NO;
    
    if (match == NBEMatchTypeEXACT_MATCH)
        return YES;
    
    return NO;
}

@end
