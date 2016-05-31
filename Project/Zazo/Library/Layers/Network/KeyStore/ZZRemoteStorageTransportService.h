//
//  ZZRemoteStorageTransportService.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 9/2/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "ZZRemoteStorageConstants.h"

@interface ZZRemoteStorageTransportService : NSObject


#pragma mark - Videos

+ (RACSignal *)addRemoteOutgoingVideoWithItemID:(NSString *)itemID
                                     friendMkey:(NSString *)friendMkey
                                     friendCKey:(NSString *)friendCKey;

+ (RACSignal *)deleteRemoteIncomingVideoWithItemID:(NSString *)itemID
                                        friendMkey:(NSString *)friendMkey
                                        friendCKey:(NSString *)friendCKey;

+ (RACSignal *)updateRemoteStatusForVideoWithItemID:(NSString *)itemID
                                           toStatus:(ZZRemoteStorageVideoStatus)status
                                         friendMkey:(NSString *)friendMkey
                                         friendCKey:(NSString *)friendCKey;


#pragma mark - Load

+ (RACSignal *)loadAllIncomingVideoIds;

+ (RACSignal *)loadAllOutgoingVideoStatuses;

+ (RACSignal *)loadRemoteEverSentFriendsIDsForUserMkey:(NSString *)mKey;

+ (RACSignal *)loadSettingsForUserMKey:(NSString *)mKey;


#pragma mark - Update

+ (RACSignal *)updateRemoteSettings:(NSDictionary *)settings
                        forUserMkey:(NSString *)mKey;

+ (RACSignal *)updateRemoteEverSentKVForFriendMkeys:(NSArray *)mkeys
                                        forUserMkey:(NSString *)mKey;


#pragma mark - Basic

+ (RACSignal *)updateKey1:(NSString *)key1
                     key2:(NSString *)key2
                    value:(NSString *)value;

+ (RACSignal *)deleteValueWithKey1:(NSString *)key1
                              key2:(NSString *)key2;

+ (RACSignal *)loadValueWithKey1:(NSString *)key1;

@end
