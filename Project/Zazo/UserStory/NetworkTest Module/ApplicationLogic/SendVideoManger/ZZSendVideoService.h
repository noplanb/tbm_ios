//
//  ZZSendVideoService.h
//  Zazo
//
//  Created by ANODA on 12/8/15.
//  Copyright © 2015 No Plan B. All rights reserved.
//

@interface ZZSendVideoService : NSObject

- (void)configureActionFriendID:(NSString *)friendID;

- (NSString *)sendVideo;

- (NSString *)sendedFriendID;

@end
