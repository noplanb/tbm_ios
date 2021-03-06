//
//  ZZDebugVideoStateDomainModel.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 8/27/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ANBaseDomainModel.h"

extern const struct ZZDebugVideoStateDomainModelAttributes
{
    __unsafe_unretained NSString *itemID;
    __unsafe_unretained NSString *status;
} ZZDebugVideoStateDomainModelAttributes;

@interface ZZDebugVideoStateDomainModel : ANBaseDomainModel

@property (nonatomic, copy) NSString *itemID;
@property (nonatomic, copy) NSString *status;

+ (instancetype)itemWithItemID:(NSString *)itemID status:(NSString *)status;

@end
