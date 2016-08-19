//
//  ZZNotificationDomainModel.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZNotificationDomainModel.h"
#import "FEMObjectMapping.h"

const struct ZZNotificationDomainModelAttributes ZZNotificationDomainModelAttributes = {
        .type = @"type",
        .typeValue = @"typeValue",
        .videoID = @"videoID",
        .fromUserMKey = @"fromUserMKey",
        .toUserMKey = @"toUserMKey",
        .status = @"status",
};

@implementation ZZNotificationDomainModel

+ (FEMObjectMapping *)mapping
{
    return [FEMObjectMapping mappingForClass:[self class] configuration:^(FEMObjectMapping *mapping) {
        [mapping addAttributesFromDictionary:
                @{ZZNotificationDomainModelAttributes.fromUserMKey : @"from_mkey",
                        ZZNotificationDomainModelAttributes.type : @"type",
                        ZZNotificationDomainModelAttributes.videoID : @"video_id",
                        ZZNotificationDomainModelAttributes.status : @"status",
                        ZZNotificationDomainModelAttributes.toUserMKey : @"to_mkey"}];
    }];
}


#pragma mark - Setters / Getters

- (ZZNotificationType)typeValue
{
    return ZZNotificationTypeEnumValueFromString(self.type);
}

- (void)setTypeValue:(ZZNotificationType)typeValue
{
    self.type = ZZNotificationTypeStringFromEnumValue(typeValue);
}

@end
