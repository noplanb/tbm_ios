//
//  NSString+NSStringExtensions.m
//  Zazo
//
//  Created by Sani Elfishawy on 2/26/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "NSString+NSStringExtensions.h"
#import <CommonCrypto/CommonDigest.h> 

@implementation NSString (NSStringExtensions)
- (NSString *)md5
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

- (BOOL)isEmpty {

    if ([self isKindOfClass:[NSNull class]]) {
        return YES;
    }

    if ([self length] <= 0) {
        return YES;
    }

    return NO;
}
@end

NSString* boolToStr(BOOL value) {
    return value?@"true":@"false";
}

NSString* intToStr(NSInteger value) {
    return [NSString stringWithFormat:@"%ld", value];
}