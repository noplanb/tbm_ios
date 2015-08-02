//
// Created by Maksim Bazarov on 28.05.15.
// Copyright (c) 2015 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMFriend.h"
#import "TBMDispatchProtocol.h"

@class TBMVideoObject;

@interface TBMFriendVideosInformation : NSObject <TBMDispatchProtocol>

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