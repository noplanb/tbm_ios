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

@implementation TBMPhoneUtils

+ (NSString *)phone:(NSString *)phone withFormat:(int)format{
    if (phone == nil)
        return nil;
    
    NBPhoneNumberUtil *pu = [NBPhoneNumberUtil sharedInstance];
    NSError *err = nil;
    NSString *r;
    NBPhoneNumber *pn = [pu parse:phone defaultRegion:@"US" error:&err];
    
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


+ (BOOL) isValidPhone:(NSString *)phone{
    NBPhoneNumberUtil *pu = [NBPhoneNumberUtil sharedInstance];
    NSError *error;
    NBPhoneNumber *pn = [pu parse:phone defaultRegion:[TBMUser phoneRegion] error:&error];
    if (error == nil){
        if ([pu isValidNumber:pn])
            return true;
        else
            return false;
    } else {
        OB_ERROR(@"TBMPhoneUtils: isValidPhone: %@", [error localizedDescription]);
        return false;
    }
}

+ (BOOL) isNumberMatch:(NSString *)n1 secondNumber:(NSString *)n2{
    NBPhoneNumberUtil *pu = [NBPhoneNumberUtil sharedInstance];
    
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
