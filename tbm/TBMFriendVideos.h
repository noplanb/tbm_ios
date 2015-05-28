//
// Created by Maksim Bazarov on 28.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMFriend.h"

@interface TBMFriendVideos : NSObject
@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *outgoingVideoId;
@property(nonatomic, assign) TBMOutgoingVideoStatus outgoingVideoStatus;

@property(nonatomic, strong) NSArray *incomingVideos;
@end