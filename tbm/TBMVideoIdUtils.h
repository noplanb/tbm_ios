//
//  TBMVideoIdUtils.h
//  tbm
//
//  Created by Sani Elfishawy on 5/27/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMFriend.h"

@interface TBMVideoIdUtils : NSObject

+ (NSString *)generateOutgoingVideoIdWithFriend:(TBMFriend *)friend;
+ (NSDictionary *)senderAndReceiverIdsWithVideoId:(NSString *)videoId;
+ (NSString *)senderIdWithVideoId:videoId;
+ (NSString *)receiverIdWithVideoId:videoId;

@end
