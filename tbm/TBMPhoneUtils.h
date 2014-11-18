//
//  TBMPhoneUtils.h
//  tbm
//
//  Created by Sani Elfishawy on 11/4/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NBPhoneNumberUtil.h"

@interface TBMPhoneUtils : NSObject
+ (NSString *)phone:(NSString *)phone withFormat:(int)format;
+ (BOOL) isValidPhone:(NSString *)phone;
@end
