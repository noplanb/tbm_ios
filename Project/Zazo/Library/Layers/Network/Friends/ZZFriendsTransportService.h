//
//  ZZFriendsTransportService.h
//  Zazo
//
//  Created by ANODA on 8/11/15.
//  Copyright (c) 2015 ANODA. All rights reserved.
//

@interface ZZFriendsTransportService : NSObject

+ (RACSignal *)loadFriendList;

+ (RACSignal *)changeModelContactStatusForUser:(NSString *)userKey toVisible:(BOOL)visible;


#pragma mark - Invitations

+ (RACSignal *)checkIsUserHasProfileWithPhoneNumber:(NSString *)phoneNumber;

+ (RACSignal *)inviteUserWithPhoneNumber:(NSString *)phoneNumber
                               firstName:(NSString *)firstName
                             andLastName:(NSString *)lastName;

+ (RACSignal *)updateUser:(NSString *)mKey withEmails:(NSArray *)emails;

@end
