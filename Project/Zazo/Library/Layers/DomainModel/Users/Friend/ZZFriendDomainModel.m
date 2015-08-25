//
//  ZZFriendDomainModel.m
//  Zazo
//
//  Created by ANODA on 8/10/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

#import "ZZFriendDomainModel.h"
#import "FEMObjectMapping.h"

const struct ZZFriendDomainModelAttributes ZZFriendDomainModelAttributes = {
    .firstName = @"firstName",
    .lastName = @"lastName",
    .mobileNumber = @"mobileNumber",
    .mKey = @"mKey",
    .cKey = @"cKey",
    .uploadRetryCount = @"uploadRetryCount",
    .lastActionTimestamp = @"lastActionTimestamp",
    .lastVideoStatusEventType = @"lastVideoStatusEventType",
    .lastIncomingVideoStatus = @"lastIncomingVideoStatus",
    .outgoingVideoItemID = @"outgoingVideoItemID",
    .outgoingVideoStatus = @"outgoingVideoStatus",
    .hasApp = @"hasApp",
};

@implementation ZZFriendDomainModel
//        TODO:
//        friend.timeOfLastAction = [NSDate date];
//        friend.hasApp = servHasApp;

+ (FEMObjectMapping*)mapping
{
    return [FEMObjectMapping mappingForClass:[self class] configuration:^(FEMObjectMapping *mapping) {
        
        [mapping addAttributesFromDictionary:@{ZZFriendDomainModelAttributes.firstName      : @"first_name",
                                               ZZFriendDomainModelAttributes.lastName       : @"last_name",
                                               ZZFriendDomainModelAttributes.mobileNumber   : @"mobile_number",
                                               ZZBaseDomainModelAttributes.idTbm            : @"id",
                                               ZZFriendDomainModelAttributes.mKey           : @"mkey",
                                               ZZFriendDomainModelAttributes.cKey           : @"ckey"}];
    }];
}

- (NSString*)photoURLString
{
    return nil; // TODO:
}

@end
