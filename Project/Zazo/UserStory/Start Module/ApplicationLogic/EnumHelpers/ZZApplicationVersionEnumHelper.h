//
//  ZZApplicationVersionEnumHelper.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/24/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

typedef NS_ENUM(NSInteger, ZZApplicationVersionState)
{
    ZZApplicationVersionStateCurrent,
    ZZApplicationVersionStateUpdateOptional,
    ZZApplicationVersionStateUpdateSchemaRequired,
    ZZApplicationVersionStateUpdateRequired,
    ZZApplicationVersionStateTotalCount
};

NSString* ZZApplicationVersionStateStringFromEnumValue(ZZApplicationVersionState);
ZZApplicationVersionState ZZApplicationVersionStateEnumValueFromString(NSString*);
