//
//  ZZRemoteStorageValueGenerator.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/19/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@interface ZZRemoteStorageValueGenerator : NSObject


#pragma mark - Filename

+ (NSString*)incomingVideoRemoteFilenameWithFriendMkey:(NSString*)friendMkey
                                            friendCKey:(NSString*)friendCkey
                                               videoId:(NSString *)videoId;

+ (NSString*)outgoingVideoRemoteFilenameWithFriendMkey:(NSString*)friendMkey
                                            friendCKey:(NSString*)friendCkey
                                               videoId:(NSString *)videoId;


#pragma mark - Video ID

+ (NSString*)incomingVideoIDRemoteKVKeyWithFriendMKey:(NSString*)friendMKey
                                           friendCKey:(NSString*)friendCKey;

+ (NSString*)outgoingVideoIDRemoteKVWithFriendMKey:(NSString*)friendMKey
                                        friendCKey:(NSString*)friendCKey;


#pragma mark - Video Status

+ (NSString*)incomingVideoStatusRemoteKVKeyWithFriendMKey:(NSString*)friendMKey
                                               friendCKey:(NSString*)friendCKey;

+ (NSString*)outgoingVideoStatusRemoteKVKeyWithFriendMKey:(NSString*)friendMKey
                                               friendCKey:(NSString*)friendCKey;

@end
