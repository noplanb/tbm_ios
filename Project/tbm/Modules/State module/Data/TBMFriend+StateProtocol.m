//
//  TBMFriend+StateProtocol.m
//  Zazo
//
//  Created by Sema Belokovsky on 17/08/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMFriend+StateProtocol.h"
#import "ZZThumbnailGenerator.h"
#import "ZZFriendDataProvider.h"

static NSString *TBMFriendLastVideStatusTypeNameIn = @"IN";
static NSString *TBMFriendLastVideStatusTypeNameOut = @"OUT";

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

+ (NSInteger)tbm_stateColumnsCount {
    return [self tbm_stateHeaderItems].count;
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
    [items addObject:boolToStr(self.hasAppValue)];
    [items addObject:[TBMVideo nameForStatus:self.lastIncomingVideoStatusValue]];
    [items addObject:tbm_stateRowItemForString(self.outgoingVideoId)];
    [items addObject:[self OVStatusName]];
    NSString *item = TBMFriendLastVideStatusTypeNameIn;
    if (self.lastVideoStatusEventTypeValue == OUTGOING_VIDEO_STATUS_EVENT_TYPE) {
        item = TBMFriendLastVideStatusTypeNameOut;
    }
    [items addObject:item];
    
    ZZFriendDomainModel* model = [ZZFriendDataProvider modelFromEntity:self];
    [items addObject:boolToStr(![ZZThumbnailGenerator isThumbNoPicForUser:model])];
    [items addObject:boolToStr(![self hasDownloadingVideo])];
    
    return tbm_stateRowForItems(items);
}

@end
