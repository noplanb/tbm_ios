//
//  ZZGridTransportService.m
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/23/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

#import "ZZGridTransportService.h"
#import "ZZFriendsTransportService.h"
#import "ZZContactDomainModel.h"
#import "ZZFriendDomainModel.h"
#import "FEMObjectDeserializer.h"

@implementation ZZGridTransportService

+ (RACSignal *)inviteUserToApp:(ZZContactDomainModel *)contact
{
    return [[ZZFriendsTransportService inviteUserWithPhoneNumber:contact.primaryPhone.contact
                                                       firstName:[NSObject an_safeString:contact.firstName]
                                                     andLastName:[NSObject an_safeString:contact.lastName]] map:^id(id value) {

        ZZFriendDomainModel *friend = [FEMObjectDeserializer deserializeObjectExternalRepresentation:value
                                                                                        usingMapping:[ZZFriendDomainModel mapping]];

        return friend;
    }];
}

+ (RACSignal *)updateContactEmails:(ZZContactDomainModel *)contact friend:(ZZFriendDomainModel *)friendModel
{
    return [ZZFriendsTransportService updateUser:friendModel.mKey withEmails:contact.emails];
}

+ (RACSignal *)checkIsUserHasApp:(ZZContactDomainModel *)contact
{
    return [[ZZFriendsTransportService checkIsUserHasProfileWithPhoneNumber:contact.primaryPhone.contact] map:^id(id value) {

        return @(![[value objectForKey:@"has_app"] isEqualToString:@"false"]);
    }];
}

@end
