//
//  TBMGridManager.h
//  tbm
//
//  Created by Sani Elfishawy on 11/5/14.
//  Copyright (c) 2014 No Plan B. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBMFriend.h"
#import "TBMVideoPlayer.h"

@protocol GridEventCallback <NSObject>
- (void)gridDidChange;
@end

@interface TBMGridManager : NSObject
+ (TBMVideoPlayer *)videoPlayerWithFriend:(TBMFriend *)friend;
+ (void)updateAll;
+ (NSMutableArray *)friendsOnGrid;
+ (NSMutableArray *)friendsOnBench;
+ (void)moveFriendToGrid:(TBMFriend *)friend;
@end
