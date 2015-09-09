//
//  ZZPhoneHelper.h
//  Zazo
//
//  Created by Oleg Panforov on 9/9/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

@class ZZContactDomainModel;

@interface ZZPhoneHelper : NSObject

+ (NSArray *)getValidPhonesFromContactModel:(ZZContactDomainModel *)model;
    
@end
