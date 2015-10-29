//
//  ZZApplicationVersionEnumHelper.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/24/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

typedef NS_ENUM(NSInteger, ZZApplicationVersionState)
{
    ZZApplicationVersionStateNone,
    ZZApplicationVersionStateCurrent,
    ZZApplicationVersionStateUpdateOptional,
    ZZApplicationVersionStateUpdateSchemaRequired,
    ZZApplicationVersionStateUpdateRequired,
    ZZApplicationVersionStateTotalCount
};

NSString* ZZApplicationVersionStateStringFromEnumValue(ZZApplicationVersionState);
ZZApplicationVersionState ZZApplicationVersionStateEnumValueFromString(NSString*);



NSString* ANStateStringFromEnumValue(ZZApplicationVersionState, __unsafe_unretained NSString* []);
NSInteger ANStateEnumValueFromString(NSString*, __unsafe_unretained NSString* []);