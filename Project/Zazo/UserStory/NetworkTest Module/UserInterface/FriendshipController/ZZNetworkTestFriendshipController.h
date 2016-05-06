//
//  ZZNetworkTestFriendshipController.h
//  Zazo
//
//  Created by ANODA on 12/11/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//


@interface ZZNetworkTestFriendshipController : NSObject

+ (void)updateFriendShipIfNeededWithCompletion:(void (^)(NSString *actualFriendID))completion;

@end
