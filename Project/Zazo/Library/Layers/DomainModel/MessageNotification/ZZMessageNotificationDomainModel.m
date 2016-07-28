//
//  ZZMessageNotificationDomainModel.m
//  Zazo
//
//  Created by Server on 28/07/16.
//  Copyright © 2016 No Plan B. All rights reserved.
//

#import "ZZMessageNotificationDomainModel.h"
#import "FEMObjectMapping.h"

@implementation ZZMessageNotificationDomainModel

+ (FEMObjectMapping *)mapping
{
    return [FEMObjectMapping mappingForClass:[self class] configuration:^(FEMObjectMapping *mapping) {
        [mapping addAttributesFromDictionary:
         @{@"body": @"body",
           @"content_type": @"content_type",
           @"from_mkey": @"from_mkey",
           @"host": @"host",
           @"message_id": @"message_id",
           @"owner_mkey": @"owner_mkey",
           @"type": @"type"}];
    }];
}

@end
