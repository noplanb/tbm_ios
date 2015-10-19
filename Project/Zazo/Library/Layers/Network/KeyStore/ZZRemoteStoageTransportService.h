//
//  ZZRemoteStoageTransportService.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/2/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZRemoteStorageConstants.h"

@class TBMFriend;

@interface ZZRemoteStoageTransportService : NSObject


#pragma mark - Videos

+ (RACSignal*)addRemoteOutgoingVideoWithItemID:(NSString*)itemID friend:(TBMFriend*)friend;
+ (RACSignal*)deleteRemoteIncomingVideoWithItemID:(NSString*)itemID friend:(TBMFriend*)friend;

+ (RACSignal*)updateRemoteStatusForVideoWithItemID:(NSString*)itemID
                                          toStatus:(ZZRemoteStorageVideoStatus)status
                                            friend:(TBMFriend*)friend;


#pragma mark - Load

+ (RACSignal*)loadRemoteIncomingVideoIDsWithFriend:(TBMFriend*)friend;
+ (RACSignal*)loadRemoteOutgoingVideoStatusForFriend:(TBMFriend*)friend;
+ (RACSignal*)loadRemoteEverSentFriendsIDsForUserMkey:(NSString*)mKey;


#pragma mark - Update

+ (RACSignal*)updateRemoteEverSentKVForFriendMkeys:(NSArray *)mkeys forUserMkey:(NSString*)mKey;


#pragma mark - Basic

+ (RACSignal*)updateKey1:(NSString*)key1 key2:(NSString*)key2 value:(NSString*)value;
+ (RACSignal*)deleteValueWithKey1:(NSString*)key1 key2:(NSString*)key2;
+ (RACSignal*)loadValueWithKey1:(NSString*)key1;

@end
