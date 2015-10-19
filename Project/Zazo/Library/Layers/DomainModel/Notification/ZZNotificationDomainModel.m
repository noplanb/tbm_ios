//
//  ZZNotificationDomainModel.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/20/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZNotificationDomainModel.h"
#import "FEMObjectMapping.h"

@implementation ZZNotificationDomainModel

+ (FEMObjectMapping*)mapping
{
    return [FEMObjectMapping mappingForClass:[self class] configuration:^(FEMObjectMapping *mapping) {
        
    }];
}



#pragma mark - Setters / Getters

- (ZZNotificationType)typeValue
{
    return ZZNotificationTypeEnumValueFromSrting(self.type);
}

- (void)setTypeValue:(ZZNotificationType)typeValue
{
    self.type = ZZNotificationTypeStringFromEnumValue(typeValue);
}

@end
