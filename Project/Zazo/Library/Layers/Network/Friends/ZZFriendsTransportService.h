//
//  ZZFriendsTransportService.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZFriendsTransportService : NSObject

+ (RACSignal*)loadFriendList;
+ (RACSignal*)loadFriendProfileWithPhone:(NSString*)phone firstName:(NSString*)firstName lastName:(NSString*)lastName;

+ (RACSignal*)checkIsUserHasProfileWithPhoneNumber:(NSString*)phoneNumber;
+ (RACSignal*)changeModelContactStatusForUser:(NSString *)userKey toVisible:(BOOL)visible;

@end
