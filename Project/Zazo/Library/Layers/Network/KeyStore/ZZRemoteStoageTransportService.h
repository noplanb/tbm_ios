//
//  ZZRemoteStoageTransportService.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/2/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZRemoteStorageConstants.h"

@interface ZZRemoteStoageTransportService : NSObject


#pragma mark - Videos

+ (RACSignal*)addRemoteOutgoingVideoWithItemID:(NSString*)itemID
                                    friendMkey:(NSString*)friendMkey
                                    friendCKey:(NSString*)friendCKey;

+ (RACSignal*)deleteRemoteIncomingVideoWithItemID:(NSString*)itemID
                                       friendMkey:(NSString*)friendMkey
                                       friendCKey:(NSString*)friendCKey;

+ (RACSignal*)updateRemoteStatusForVideoWithItemID:(NSString*)itemID
                                          toStatus:(ZZRemoteStorageVideoStatus)status
                                        friendMkey:(NSString*)friendMkey
                                        friendCKey:(NSString*)friendCKey;


#pragma mark - Load

+ (RACSignal*)loadRemoteIncomingVideoIDsWithFriendMkey:(NSString*)friendMkey
                                            friendCKey:(NSString*)friendCKey;

+ (RACSignal*)loadRemoteOutgoingVideoStatusForFriendMkey:(NSString*)friendMkey
                                              friendCKey:(NSString*)friendCKey;

+ (RACSignal*)loadRemoteEverSentFriendsIDsForUserMkey:(NSString*)mKey;


#pragma mark - Update

+ (RACSignal*)updateRemoteEverSentKVForFriendMkeys:(NSArray *)mkeys forUserMkey:(NSString*)mKey;


#pragma mark - Basic

+ (RACSignal*)updateKey1:(NSString*)key1 key2:(NSString*)key2 value:(NSString*)value;
+ (RACSignal*)deleteValueWithKey1:(NSString*)key1 key2:(NSString*)key2;
+ (RACSignal*)loadValueWithKey1:(NSString*)key1;

@end
