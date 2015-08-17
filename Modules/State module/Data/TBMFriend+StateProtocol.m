//
//  TBMFriend+StateProtocol.m
//  Zazo
//
//  Created by Sema Belokovsky on 17/08/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMFriend+StateProtocol.h"

@implementation TBMFriend (StateProtocol)

+ (NSArray *)tbm_stateHeaderItems {
    NSMutableArray *items = [NSMutableArray new];
    [items addObject:@"Name"];
    [items addObject:@"ID"];
    [items addObject:@"Has app"];
    [items addObject:@"IV status"];
    [items addObject:@"OV ID"];
    [items addObject:@"OV status"];
    [items addObject:@"Last event"];
    [items addObject:@"Has thumb"];
    [items addObject:@"Download"];
    return items;
}

+ (int)tbm_stateColumnsCount {
    return (int)[self tbm_stateHeaderItems].count;
}

+ (NSString *)tbm_stateTitlerStr {
    return tbm_stateTitleForTableName(@"Friends", (int)[self tbm_stateColumnsCount]);
}

+ (NSString *)tbm_stateHeaderStr {
    
    return tbm_stateRowForItems([self tbm_stateHeaderItems]);
}

- (NSString *)tbm_stateRowStr {
    
    NSMutableArray *items = [NSMutableArray new];
    // format according to COLUMN_WIDTH
    [items addObject:[self fullName]];
    [items addObject:tbm_stateRowItemForString(self.idTbm)];
    [items addObject:boolToStr(self.hasApp)];
    [items addObject:[TBMVideo nameForStatus:self.lastIncomingVideoStatus]];
    [items addObject:tbm_stateRowItemForString(self.outgoingVideoId)];
    [items addObject:[self OVStatusName]];
    NSString *item = @"IN";
    if (self.lastVideoStatusEventType == OUTGOING_VIDEO_STATUS_EVENT_TYPE) {
        item = @"OUT";
    }
    [items addObject:item];
    [items addObject:boolToStr(![self isThumbNoPic])];
    [items addObject:boolToStr(![self hasDownloadingVideo])];
    
    return tbm_stateRowForItems(items);
}

@end
