//
//  TBMRemoteStorageHandler.h
//  tbm
//
//  Created by Sani Elfishawy on 7/29/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMVideo.h"

@class TBMFriend;

@interface TBMRemoteStorageHandler : NSObject

// Convenience setters
+ (void) addRemoteOutgoingVideoId:(NSString *)videoId friend:(TBMFriend *)friend;
+ (void) deleteRemoteIncomingVideoId:(NSString *)videoId friend:(TBMFriend *)friend;
+ (void) setRemoteIncomingVideoStatus:(NSString *)status videoId:(NSString *)videoId friend:(TBMFriend *)friend;

// Convenience getters
+ (void)getRemoteIncomingVideoIdsWithFriend:(TBMFriend *)friend gotVideoIds:(void (^)(NSArray *videoIds))gotVideoIds;
+ (void) getRemoteOutgoingVideoStatus:(TBMFriend *)friend success:(void(^)(NSDictionary *response))success failure:(void(^)(NSError *error))failure;

+ (void)getRemoteEverSentFriendsWithSuccess:(void (^)(NSArray *response))success failure:(void (^)(NSError *error))failure;
+ (void)setRemoteEverSentKVForFriendMkeys:(NSArray *)mkeys;
// Conversion of status
+ (int)outgoingVideoStatusWithRemoteStatus:(NSString *)remoteStatus;
@end
