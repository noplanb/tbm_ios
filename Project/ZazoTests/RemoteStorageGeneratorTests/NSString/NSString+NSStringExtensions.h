//
//  NSString+NSStringExtensions.h
//  Zazo
//
//  Created by Sani Elfishawy on 2/26/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (NSStringExtensions)
- (NSString *)md5;

- (BOOL)isEmpty;

@end

NSString* boolToStr(BOOL value);
NSString* intToStr(NSInteger value);
NSString* ullToShortStr(unsigned long long ull);