//
//  ZZPhoneHelper.m
//  Zazo
//
//  Created by Oleg Panforov on 9/9/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZPhoneHelper.h"
#import "ZZContactDomainModel.h"
#import "TBMPhoneUtils.h"

@implementation ZZPhoneHelper

+ (NSArray *)getValidPhonesFromContactModel:(ZZContactDomainModel *)model
{
    NSMutableArray *validNumbers = [NSMutableArray new];
    
    if (model.phones.allObjects.count > 0)
    {
        [model.phones.allObjects enumerateObjectsUsingBlock:^(NSString* phoneNumber, NSUInteger idx, BOOL *stop) {
            
            if ([TBMPhoneUtils isValidPhone:phoneNumber])
            {
                NSString *formattedPhone = [TBMPhoneUtils phone:phoneNumber withFormat:NBEPhoneNumberFormatINTERNATIONAL];
                [validNumbers addObject:formattedPhone];
            }

        }];
    }
    
    return validNumbers;
    
}



@end
