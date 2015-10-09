//
//  ZZGridTransportService.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/23/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class ZZContactDomainModel;
@class ZZFriendDomainModel;

@interface ZZGridTransportService : NSObject

+ (RACSignal*)inviteUserToApp:(ZZContactDomainModel*)contact;
+ (RACSignal*)checkIsUserHasApp:(ZZContactDomainModel*)contact;
+ (RACSignal*)updateContactEmails:(ZZContactDomainModel*)contact friend:(ZZFriendDomainModel*)friendModel;

@end
