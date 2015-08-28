//
//  TBMVideo+StateProtocol.m
//  Zazo
//
//  Created by Sema Belokovsky on 17/08/15.
//  Copyright (c) 2015 No Plan B. All rights reserved.
//

#import "TBMVideo+StateProtocol.h"
#import "TBMFriend.h"

@implementation TBMVideo (StateProtocol)

+ (NSArray *)tbm_stateHeaderItems {
    NSMutableArray *items = [NSMutableArray new];
    [items addObject:@"ID"];
    [items addObject:@"From"];
    [items addObject:@"IV status"];
    [items addObject:@"Exists"];
    [items addObject:@"Size"];
    return items;
}

+ (int)tbm_stateColumnsCount {
    return (int)[self tbm_stateHeaderItems].count;
}

+ (NSString *)tbm_stateTitlerStr {
    return tbm_stateTitleForTableName(@"Videos", (int)[self tbm_stateColumnsCount]);
}

+ (NSString *)tbm_stateHeaderStr {
    
    return tbm_stateRowForItems([self tbm_stateHeaderItems]);
}

- (NSString *)tbm_stateRowStr {
    
    NSMutableArray *items = [NSMutableArray new];
    // format according to COLUMN_WIDTH
    [items addObject:tbm_stateRowItemForString(self.videoId)];
    [items addObject:tbm_stateRowItemForString(self.friend.idTbm)];
    [items addObject:[self statusName]];
    [items addObject:boolToStr([self videoFileExists])];
    [items addObject:ullToShortStr(self.videoFileSize)];
    
    return tbm_stateRowForItems(items);
}

@end
