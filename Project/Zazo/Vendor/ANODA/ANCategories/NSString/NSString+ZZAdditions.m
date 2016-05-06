//
//  NSString+ANAdditions.m
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "NSString+ZZAdditions.h"
#import "NSObject+ANSafeValues.h"
#import <CommonCrypto/CommonDigest.h> 

@implementation NSString (ZZAdditions)

+ (NSString *)an_concatenateString:(NSString *)firstString withString:(NSString *)endString delimenter:(NSString *)string
{
    NSString *result = [NSObject an_safeString:firstString];
    if (result.length)
    {
        result = [result stringByAppendingString:[NSObject an_safeString:string]];
    }
    return [result stringByAppendingString:[NSObject an_safeString:endString]];
}

- (NSString *)an_md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
    ];
}

@end
