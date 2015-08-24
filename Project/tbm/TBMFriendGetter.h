//
//  TBMFriendGetter.h
//  tbm
//
//  Created by Sani Elfishawy on 11/4/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TBMFriendGetterCallback <NSObject>
- (void)gotFriends;
- (void)friendGetterServerError;
@end


@interface TBMFriendGetter : NSObject

- (instancetype)initWithDelegate:(id<TBMFriendGetterCallback>)delegate;
- (void)getFriends;

@end
