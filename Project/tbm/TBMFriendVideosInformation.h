//
// Created by Maksim Bazarov on 28.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMFriend.h"

@class TBMVideoObject;

@interface TBMFriendVideosInformation : NSObject

@property(nonatomic, strong) NSString *name;

/**
* Outgoing object
*/
@property(nonatomic, strong) NSArray *outgoingObjects;

/**
* Array of TBMVideoObject (incoming objects)
*/
@property(nonatomic, strong) NSArray *incomingObjects;



@end