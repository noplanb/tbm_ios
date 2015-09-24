//
//  TBMFriendGetter.h
//  tbm
//
//  Created by Sani Elfishawy on 11/4/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

@protocol TBMFriendGetterCallback <NSObject>

- (void)gotFriends;
- (void)friendGetterServerError;

@optional

- (void)gotFriendsArray:(NSArray*)friendsArray;

@end


@interface TBMFriendGetter : NSObject

- (instancetype)initWithDelegate:(id<TBMFriendGetterCallback>)delegate;
- (void)getFriends;

@end
