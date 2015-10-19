//
//  ZZRemoteStorageValueGenerator.h
//  Zazo
//
//  Created by Oksana Kovalchuk on 10/19/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@class TBMFriend;
@class TBMVideo;

@interface ZZRemoteStorageValueGenerator : NSObject

+ (NSString*)outgoingVideoRemoteFilename:(TBMFriend *)friend videoId:(NSString *)videoId;
+ (NSString*)incomingVideoRemoteFilename:(TBMVideo *)video;


+ (NSString *)outgoingVideoIDRemoteKVKey:(TBMFriend *)friend;
+ (NSString *)incomingVideoIDRemoteKVKey:(TBMFriend *)friend;
+ (NSString *)incomingVideoStatusRemoteKVKey:(TBMFriend *)friend;
+ (NSString *)outgoingVideoStatusRemoteKVKey:(TBMFriend *)friend;


@end
